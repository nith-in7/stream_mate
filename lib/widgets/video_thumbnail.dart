import 'dart:typed_data';

import 'package:stream_mate/model/post_model.dart';
import 'package:stream_mate/widgets/helper_methods.dart';
import 'package:stream_mate/widgets/post_container.dart';
import 'package:stream_mate/widgets/shimmer_container.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoPreview extends StatelessWidget {
  const VideoPreview({super.key, required this.post});
  final VideoPost post;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getThumbnail(post.videoUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return InkWell(
            onTap: () async {
              await getDialogBox(context);
            },
            child: SizedBox(
              width: 100,
              height: 100,
              child:
               Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        return Container(
          color: Colors.grey.shade900,
          width: 100,
          height: 100,
        );
      },
    );
  }

  Future<Uint8List?>? getThumbnail(final String videoUrl) async {
    
    final Uint8List? data = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 100,
        quality: 75);
    return data;
  }

  Future<void> getDialogBox(context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          surfaceTintColor: Colors.grey.shade900,
          shadowColor: Colors.black,
          insetPadding: const EdgeInsets.only(top: 40, bottom: 40),
          contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
          content: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder(
                    future: cacheVideo(post.videoUrl),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return PostContainer(
                          post: post,
                          navigate: false,
                          width: MediaQuery.of(context).size.width < 450
                              ? MediaQuery.of(context).size.width
                              : 400,
                          showLikes: true,
                          videoPath: snapshot.data!,
                        );
                      }
                      return const ShimmerContainer();
                    }),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    width: 100,
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Close")),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
