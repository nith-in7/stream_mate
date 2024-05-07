import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:timer_button/timer_button.dart';

class VerifyOTP extends ConsumerStatefulWidget {
  const VerifyOTP(
      {super.key,
      required this.number,
      required this.verificationId,
      this.resendTokenId});
  final String number;
  final int? resendTokenId;
  final String verificationId;
  @override
  ConsumerState<VerifyOTP> createState() => _VerifyOTPState();
}

class _VerifyOTPState extends ConsumerState<VerifyOTP> {
  late String verticationToken;
  late TextEditingController pinController;
  late FocusNode focusNode;
  bool isValid = false;
  bool isError = false;
  bool isLoading = false;
  String errorText = '';

  @override
  void initState() {
    verticationToken = widget.verificationId;
    focusNode = FocusNode();
    pinController = TextEditingController();
    pinController.addListener(() {
      setState(() {
        if (pinController.text.trim().length < 6) {
          isValid = false;
        } else {
          isValid = true;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  onSubmit() async {
    setState(() {
      isLoading = true;
    });
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verticationToken, smsCode: pinController.text.trim());

    try {
      final navContext = Navigator.of(context);
      final UserCredential user =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (user.user != null) {
        navContext.pop();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == "invalid-verification-code") {
          errorText = "The OTP you entered is invalid.";
        } else {
          errorText = "An error occured";
        }
        isError = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void resendOTP() async {
    final firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: widget.number,
      verificationCompleted: (phoneAuthCredential) {
        firebaseAuth.signInWithCredential(phoneAuthCredential);
      },
      verificationFailed: (error) {
        setState(() {
          if (error.code == "invalid-verification-code") {
            errorText = "The OTP you entered is invalid.";
          } else {
            errorText = "An error occured";
          }
          isError = true;
        });
      },
      codeSent: (verificationId, forceResendingToken) async {
        verticationToken = verificationId;
      },
      forceResendingToken: widget.resendTokenId,
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  getPinput() {
    const focusedBorderColor = Colors.black;
    const fillColor = Color.fromRGBO(255, 255, 255, 1);
    const borderColor = Colors.grey;
    final defaultPinTheme = PinTheme(
      width: 51,
      height: 51,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );
    return Pinput(
      length: 6,
      controller: pinController,
      focusNode: focusNode,
      defaultPinTheme: defaultPinTheme,
      separatorBuilder: (index) => const SizedBox(width: 6),
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      forceErrorState: isError,
      errorText: errorText,
      errorTextStyle: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w500),
      cursor: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 9),
            width: 22,
            height: 1,
            color: focusedBorderColor,
          ),
        ],
      ),
      onChanged: (value) {
        if (isError) {
          setState(() {
            isError = false;
          });
        }
      },
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration!.copyWith(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1.8, color: focusedBorderColor),
        ),
      ),
      submittedPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration!.copyWith(
          color: fillColor,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(width: 1.8, color: focusedBorderColor),
        ),
      ),
      errorPinTheme: defaultPinTheme.copyBorderWith(
        border:
            Border.all(width: 1.8, color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Visibility(
              visible: isLoading,
              child: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ))
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverList(
                delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    LottieBuilder.asset(
                      height: 230,
                      width: MediaQuery.of(context).size.width,
                      animate: true,
                      "assets/lottie/otp_animation.json",
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Verification",
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Enter the OTP sent to number\n${widget.number}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    getPinput(),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: isValid && !isLoading ? onSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 254, 139, 144),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Get Started"),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("Didn't receive code?"),
                    TimerButton.builder(
                      timeOutInSeconds: 29,
                      builder: (context, seconds) {
                        String text = "Retry in 00:${seconds + 1}";
                        TextStyle? textStyle;
                        if (seconds < 0) {
                          textStyle = TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary);
                          text = "Resend";
                        }
                        return Text(text, style: textStyle);
                      },
                      onPressed: () {
                        resendOTP();
                      },
                      resetTimerOnPressed: true,
                    ),
                  ],
                ),
              ),
            ]))
          ],
        ),
      ),
    );
  }
}
