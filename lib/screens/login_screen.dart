import 'package:flutter/cupertino.dart';
import 'package:stream_mate/screens/verify_otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController phoneTextController;
  bool isValid = false;
  bool isLoading = false;

  @override
  void initState() {
    phoneTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    phoneTextController.dispose();
    super.dispose();
  }

  onSubmit() async {
    final firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: "+91${phoneTextController.text.trim()}",
      verificationCompleted: (phoneAuthCredential) async {
        await firebaseAuth.signInWithCredential(phoneAuthCredential);
      },
      verificationFailed: (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? "An error occured")));
      },
      codeSent: (verificationId, forceResendingToken) async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return VerifyOTP(
                number: "+91${phoneTextController.text.trim()}",
                verificationId: verificationId,
                resendTokenId: forceResendingToken);
          },
        ));
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width < 450
        ? MediaQuery.of(context).size.width
        : 400;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8, left: 40, right: 40),
            reverse: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Image.asset(
                  "assets/Images/logo.png",
                  width: 150,
                ),
                const SizedBox(
                  height: 20,
                ),
                LottieBuilder.asset(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  "assets/lottie/login_animation.json",
                ),
                const Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      if (value.length < 10) {
                        isValid = false;
                      } else {
                        isValid = true;
                      }
                    });
                  },
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  controller: phoneTextController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    suffixIcon: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(),
                          )
                        : null,
                    prefix: const Text("+91 "),
                    counter: const Offstage(),
                    prefixIcon: const Icon(
                      Icons.phone,
                    ),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    constraints: BoxConstraints(
                        maxWidth: width),
                    label: const Text("Phone no."),
                  ),
                ),
                Container(
                  width: width,
                  alignment: Alignment.centerRight,
                  constraints: const BoxConstraints(minWidth: 250),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 254, 139, 144),
                          foregroundColor: Colors.white),
                      onPressed: isValid && !isLoading
                          ? () {
                              setState(() {
                                isLoading = true;
                              });
                              onSubmit();
                              setState(() {
                                isLoading = false;
                              });
                            }
                          : null,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Get OTP"),
                          SizedBox(
                            width: 8,
                          ),
                          Icon(
                            Icons.keyboard_arrow_right_outlined,
                          )
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
