import 'dart:io';
import 'package:stream_mate/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class UserDetails extends ConsumerStatefulWidget {
  const UserDetails({super.key});

  @override
  ConsumerState<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends ConsumerState<UserDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController profileController;
  late TextEditingController nameController;
  late TextEditingController usernameController;
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  final List<String> usernameList = [];
  File? selectedImage;
  bool imageError = false;
  bool isLoading = false;
  bool usernameUsed = false;
  @override
  void initState() {
    nameController = TextEditingController();
    usernameController = TextEditingController();
    profileController = AnimationController(vsync: this);

    profileController.addListener(() {
      if (profileController.value >= .94) {
        profileController.stop();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    profileController.dispose();
    usernameController.dispose();
    nameController.dispose();
    super.dispose();
  }

  onSubmit() async {
    if (selectedImage == null) {
      setState(() {
        imageError = true;
      });
      profileController.value = .46;
      profileController.forward();
    }
    final isvalid = formKey.currentState!.validate();
    if (!isvalid || selectedImage == null) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    user.updateDisplayName(usernameController.text);
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child(user.uid)
        .child("profile_image.jpg");
    await storageRef.putFile(selectedImage!);
    final imageUrl = await storageRef.getDownloadURL();
    user.updatePhotoURL(imageUrl);
    await firestore.collection(user.uid).doc('user_details').set({
      "username": usernameController.text,
      "displayName": nameController.text,
      "imageUrl": imageUrl
    });
    await firestore.collection("username_list").add({
      "username": usernameController.text,
      "uid": user.uid,
      "displayName": nameController.text,
      "imageUrl": imageUrl
    });
    setState(() {
      isLoading = false;
    });
    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          Visibility(
              visible: isLoading,
              child: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: CircularProgressIndicator(),
              ))
        ],
        leading: IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.logout,
              size: 28,
            )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: CircleAvatar(
                    radius: 62,
                    backgroundColor:
                        imageError ? Colors.redAccent : Colors.white,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () async {
                        setState(() {
                          imageError = false;
                        });
                        final XFile? image = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 50,
                            maxWidth: 150);
                        if (image == null) {
                          return;
                        }
                        final tempImagePath = File(image.path);
                        setState(() {
                          selectedImage = tempImagePath;
                        });
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.black,
                        foregroundImage: selectedImage == null
                            ? null
                            : FileImage(selectedImage!),
                        child: LottieBuilder.asset(
                          width: MediaQuery.of(context).size.width,
                          onLoaded: (p0) {
                            profileController.duration = p0.duration;
                            profileController.forward();
                          },
                          controller: profileController,
                          repeat: false,
                          "assets/lottie/profilr_placeholder_animation.json",
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: imageError,
                    child: Text(
                      "Upload profile pic.",
                      style: TextStyle(color: Colors.redAccent.shade700),
                    )),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: nameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null) {
                      return "Enter valid profile name.";
                    }
                    if (value.trim().isEmpty) {
                      return "Profile name cannot be empty.";
                    }
                    return null;
                  },
                  maxLength: 20,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))
                  ],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    counter: Offstage(),
                    prefixIcon: Icon(
                      Icons.badge,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    constraints: BoxConstraints(maxWidth: 350),
                    label: Text("Profile Name"),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null) {
                      return "Enter valid username.";
                    }
                    if (value.trim().isEmpty) {
                      return "Username cannot be empty.";
                    }
                    if (usernameUsed) {
                      return "${usernameController.text} is already used, Try different";
                    }
                    return null;
                  },
                  controller: usernameController,
                  onChanged: (value) async {
                    final QuerySnapshot<Map<String, dynamic>> data =
                        await firestore
                            .collection("username_list")
                            .where('username',
                                isEqualTo: usernameController.text)
                            .get();
                    setState(() {
                      usernameUsed = data.size > 0;
                    });
                  },
                  maxLength: 20,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp('_{2}')),
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z_]'))
                  ],
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    helperStyle: TextStyle(fontSize: 11),
                    helperText:
                        "Can be alphanumeric, can't have consecutive underscores",
                    counter: Offstage(),
                    prefixIcon: Icon(
                      Icons.person,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    constraints: BoxConstraints(maxWidth: 350),
                    label: Text("Username"),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 254, 139, 144),
                        foregroundColor: Colors.white),
                    onPressed: !isLoading ? onSubmit : null,
                    child: const Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
