import 'package:stream_mate/model/post_model.dart';
import 'package:stream_mate/provider/providers.dart';
import 'package:stream_mate/widgets/profile_image_widget.dart';
import 'package:stream_mate/widgets/video_thumbnail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryWindow extends ConsumerWidget {
  const LibraryWindow({super.key, required this.uid});
  final String uid;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double width = MediaQuery.of(context).size.width < 450
        ? MediaQuery.of(context).size.width
        : 400;

    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection(uid)
            .doc("user_details")
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ProfileView(
                width: width,
                uid: uid,
                imageUrl: snapshot.data!.data()!["imageUrl"],
                displayName: snapshot.data!.data()!["displayName"],
                username: snapshot.data!.data()!['username']);
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        });
  }
}

class ProfileView extends ConsumerWidget {
  const ProfileView({
    super.key,
    required this.width,
    required this.uid,
    required this.username,
    required this.displayName,
    required this.imageUrl,
  });

  final double width;
  final String uid;
  final String username;
  final String displayName;
  final String imageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<VideoPost> providerRef = ref
        .watch(listOfPostProvider)
        .where((element) => element.userId == uid)
        .toList();
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          
          titleTextStyle: const TextStyle(fontSize: 16),
          toolbarHeight: 60,
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(username),
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
                border: Border.symmetric(
                    horizontal:
                        BorderSide(width: .6, color: Colors.grey.shade700))),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            width: width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ProfileImage(radius: 45, imageUrl: imageUrl),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text("Posts : ${providerRef.length}")
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(width: .6, color: Colors.grey.shade700))),
            width: width,
            child: Icon(
              Icons.grid_on,
              size: 36,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        SliverGrid.builder(
          itemCount: providerRef.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 2, crossAxisCount: 3, mainAxisSpacing: 2),
          itemBuilder: (context, index) {
            return Container(
                color: Colors.grey,
                child: VideoPreview(post: providerRef[index]));
          },
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 150,
          ),
        )
      ],
    );
  }
}
