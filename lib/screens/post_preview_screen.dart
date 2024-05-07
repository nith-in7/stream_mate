import 'dart:async';
import 'dart:io';

import 'package:stream_mate/model/post_model.dart';
import 'package:stream_mate/widgets/post_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class PreviewPost extends StatefulWidget {
  const PreviewPost(
      {super.key, required this.videoPath, required this.onUpload});
  final File videoPath;
  final Future<void> Function(
      {required String caption,
      required String location,
      required String postID,
      required File videoPath}) onUpload;
  @override
  State<PreviewPost> createState() => _PreviewPostState();
}

class _PreviewPostState extends State<PreviewPost> {
  final String postId = uuid.v4();
  late TextEditingController captionController;
  late TextEditingController locationController;
  bool locationLoading = false;
  bool postLoading = false;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    captionController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });

    locationController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    captionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> onSubmit() async {
    if (locationController.text == "") {
      Fluttertoast.showToast(msg: "Set your current location");
      return;
    }
    if (captionController.text == "") {
      Fluttertoast.showToast(msg: "Enter your caption.");
      return;
    }
    widget.onUpload(
        location: locationController.text.trim(),
        caption: captionController.text.trim(),
        videoPath: widget.videoPath,
        postID: postId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width < 450
        ? MediaQuery.of(context).size.width
        : 400;

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          shadowColor: Colors.black,
          
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            postLoading
                ? const CircularProgressIndicator()
                : TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () async {
                      setState(() {
                        postLoading = true;
                      });
                      await onSubmit();
                      setState(() {
                        postLoading = false;
                      });
                    },
                    icon: const Icon(Icons.upload_outlined),
                    label: const Text("Post"))
          ],
          title: const Text("Preview"),
        ),
        body: ListView(
          
          children: [
            PostContainer(
              post: VideoPost(
                  username: currentUser.displayName!,
                  imageURl: currentUser.photoURL!,
                  postId: postId,
                  caption: captionController.text.trim() == ""
                      ? "Enter caption, to see here"
                      : captionController.text.trim(),
                  dateDiff: "",
                  userId: currentUser.uid,
                  location: locationController.text.trim() == ""
                      ? "Set your current location"
                      : locationController.text.trim(),
                  videoUrl: ""),
              navigate: false,
              width: width,
              showLikes: false,
              videoPath: widget.videoPath,
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Container(
                width: width,
                padding: const EdgeInsets.all(4),
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: TextField(
                  controller: captionController,
                  maxLines: 1,
                  decoration: InputDecoration(
                      hintText: "Enter your caption.",
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.text_format_outlined,
                        color: Colors.grey.shade200,
                      )),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                    bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Container(
                width: width,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: TextButton.icon(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade200),
                    onPressed: locationLoading
                        ? null
                        : () async {
                            setState(() {
                              locationLoading = true;
                            });
                            locationController.text = await chechPermission();
                            setState(() {
                              locationLoading = false;
                            });
                          },
                    icon: locationLoading
                        ? const Icon(
                            Icons.abc,
                            size: 0,
                          )
                        : const Icon(Icons.near_me),
                    label: locationLoading
                        ? LoadingAnimationWidget.prograssiveDots(
                            color: Colors.white, size: 33)
                        : const Text("Use my current location.")),
              ),
            )
          ],
        ));
  }
}

Future<String> chechPermission() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      Fluttertoast.showToast(msg: "Request Denied");
    }
  }
  if (permission == LocationPermission.deniedForever) {
    Fluttertoast.showToast(msg: "Request Denied, Enable it in the permissons.");
    await Geolocator.openAppSettings();
    return "";
  }
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
  }
  return await getLocation();
}

Future<String> getLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition();
    final List<Placemark> result =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    final address =
        "${result[0].name}, ${result[0].locality}, ${result[0].administrativeArea}";
    Fluttertoast.showToast(
      msg: "Location set successfully",
    );
    return address;
  } on TimeoutException {
    Fluttertoast.showToast(msg: "Location request timed out.");
    return "";
  } on LocationServiceDisabledException {
    Fluttertoast.showToast(msg: "Please turn on your location and try again.");
    return "";
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
    return "";
  }
}
