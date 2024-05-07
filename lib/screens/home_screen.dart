import 'dart:io';

import 'package:stream_mate/widgets/helper_methods.dart';
import 'package:stream_mate/widgets/search_bar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'package:stream_mate/model/post_model.dart';
import 'package:stream_mate/provider/providers.dart';
import 'package:stream_mate/screens/post_preview_screen.dart';
import 'package:stream_mate/widgets/explore_window.dart';
import 'package:stream_mate/widgets/librabry_window.dart';
import 'package:stream_mate/widgets/shimmer_container.dart';
import 'package:stream_mate/widgets/upload_video.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int selectedIndex = 0;
  bool postUploading = false;
  UploadTask? uploadTask;
  late ScrollController scrollController;
  double progress = 0;
  File postPath = File("path");
  final authInstance = FirebaseAuth.instance;
  late Future<List<VideoPost>> data;
  @override
  void initState() {
    data = ref.read(listOfPostProvider.notifier).getData();
    scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width < 450
        ? MediaQuery.of(context).size.width
        : 400;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SpeedDial(
          spacing: 10,
          spaceBetweenChildren: 10,
          direction: SpeedDialDirection.up,
          activeChild: const Icon(Icons.close),
          children: [
            SpeedDialChild(
              onTap: () async {
                await pickVideo(source: ImageSource.gallery);
              },
              child: const Icon(Icons.photo_library),
              label: "Gallery",
            ),
            SpeedDialChild(
              onTap: () {
                pickVideo(
                  source: ImageSource.camera,
                );
              },
              child: const Icon(Icons.camera),
              label: "Camera",
            ),
          ],
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomAppBar(
          shadowColor: Colors.transparent,
          height: 65,
          color: Colors.transparent,
          padding: const EdgeInsets.all(0),
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: BottomNavigationBar(
              unselectedItemColor: Colors.grey.shade600,
              selectedItemColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              onTap: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
              currentIndex: selectedIndex,
              backgroundColor: Colors.black,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.explore), label: "Explore"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark), label: "Library")
              ]),
        ),
        body: [
          CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              if (selectedIndex == 0)
                SliverAppBar(
                  toolbarHeight: 80,
                  surfaceTintColor: Colors.black,
                  floating: true,
                  pinned: false,
                  title: Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(32)),
                      child: const SearchBarWidget()),
                  actions: [
                    InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          authInstance.signOut();
                        },
                        child: const Icon(
                          color: Colors.white,
                          Icons.logout_outlined,
                          size: 28,
                        ))
                  ],
                  backgroundColor: Colors.black,
                  leading: UnconstrainedBox(
                    constrainedAxis: Axis.horizontal,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        scrollController.animateTo(0,
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.fastEaseInToSlowEaseOut);
                      },
                      child: Image.asset(
                        height: 45,
                        "assets/Images/logo.png",
                      ),
                    ),
                  ),
                ),
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await ref.read(listOfPostProvider.notifier).getData();
                },
              ),
              SliverToBoxAdapter(
                child: Visibility(
                    visible: postUploading,
                    child: UploadVideo(
                      onCancel: onCancel,
                      progress: progress,
                      width: width,
                      videoPath: postPath,
                    )),
              ),
              FutureBuilder(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return const ExploreWindow();
                  }

                  return const SliverToBoxAdapter(
                    child: ShimmerContainer(),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                ),
              )
            ],
          ),
          LibraryWindow(
            uid: authInstance.currentUser!.uid,
          )
        ][selectedIndex]);
  }

  Future<void> pickVideo({required ImageSource source}) async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: source,
    );
    if (video == null) {
      return;
    }
    final path = File(video.path);
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return PreviewPost(videoPath: path, onUpload: uploadPost);
        },
      ));
    }
  }

  void onCancel() async {
    await uploadTask!.cancel();
    Fluttertoast.showToast(msg: "Upload cancelled.");
    setState(() {
      progress = 0;
      postUploading = false;
    });
  }

  Future<void> uploadPost(
      {required String location,
      required String caption,
      required File videoPath,
      required String postID}) async {
    setState(() {
      postPath = videoPath;
      postUploading = true;
    });
    final User currentUser = authInstance.currentUser!;
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child("post")
        .child(currentUser.uid)
        .child(postID);
    uploadTask = storageRef.putFile(
        videoPath, SettableMetadata(contentType: "video/mp4"));

    uploadTask!.snapshotEvents.listen(
      (TaskSnapshot event) async {
        if (event.state == TaskState.running) {
          setState(() {
            progress = (event.bytesTransferred) / (event.totalBytes);
          });
        }
        if (event.state == TaskState.success) {
          String downloadUrl = await event.ref.getDownloadURL();
          await FirebaseFirestore.instance.collection("post").doc(postID).set({
            "username": currentUser.displayName,
            "imageUrl": currentUser.photoURL,
            "postId": postID,
            "likedBy": [],
            "comments": [],
            "userId": currentUser.uid,
            "date": Timestamp.now(),
            "videoUrl": downloadUrl,
            "caption": caption,
            "location": location,
          });

          Fluttertoast.showToast(msg: "Post uploaded suceesfully.");
          final newPost = VideoPost(
              username: currentUser.displayName!,
              imageURl: currentUser.photoURL!,
              postId: postID,
              caption: caption,
              dateDiff: getDateDifference(Timestamp.now().toDate()),
              userId: currentUser.uid,
              location: location,
              videoUrl: downloadUrl);

          setState(() {
            ref.read(listOfPostProvider.notifier).addFirst(newPost);
            progress = 0;
            postUploading = false;
          });
        }
        if (event.state == TaskState.error) {
          Fluttertoast.showToast(msg: "Error encountered, Unable to upload.");
          setState(() {
            progress = 0;
            postUploading = false;
          });
        }
        if (event.state == TaskState.canceled) {
          Fluttertoast.showToast(msg: "Upload cancelled.");
          setState(() {
            progress = 0;
            postUploading = false;
          });
        }
      },
    );
  }
}
