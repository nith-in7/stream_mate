import 'dart:io';
import 'dart:ui';

import 'package:stream_mate/model/post_model.dart';
import 'package:stream_mate/widgets/helper_methods.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:stream_mate/widgets/post_top_tile.dart';
import 'package:stream_mate/widgets/pots_bottom_tile.dart';

class PostContainer extends StatefulWidget {
  const PostContainer({
    required this.showLikes,
    super.key,
    required this.post,
    required this.videoPath,
    required this.navigate,
    required this.width,
  });

  final VideoPost post;
  final File videoPath;
  final bool showLikes;

  final bool navigate;

  final double width;

  @override
  State<PostContainer> createState() => _PostContainerState();
}

class _PostContainerState extends State<PostContainer> {
  late VideoPlayerController videoController;
  bool isMute = false;
  bool isPLaying = false;

  @override
  void initState() {
    super.initState();

    videoController = VideoPlayerController.file(widget.videoPath)
      ..initialize().then((value) {
        videoController.setLooping(true);
        videoController.setVolume(1);
        setState(() {});
      });
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(4),
              width: widget.width,
              height: 620,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(40)),
                child: InkWell(
                  customBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  onDoubleTap: () async {
                    await likeThePost(widget.post.postId);
                  },
                  child: VideoPlayer(videoController),
                ),
              ),
            ),
            Positioned(
              top: 6,
              child: SizedBox(
                height: 70,
                width: widget.width,
                child: PostTopTile(
                  navigate: widget.navigate,
                  uid: widget.post.userId,
                  diff: widget.post.dateDiff,
                  username: widget.post.username,
                  locationText: widget.post.location,
                  imageUrl: widget.post.imageURl,
                ),
              ),
            ),
            Visibility(
              visible: widget.showLikes,
              child: Positioned(
                bottom: 12,
                child: SizedBox(
                    width: 130,
                    height: 50,
                    child: PostBottomTile(
                      postId: widget.post.postId,
                    )),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(77, 0, 0, 0),
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(),
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            isMute = !isMute;
                            if (isMute) {
                              videoController.setVolume(0);
                            } else {
                              videoController.setVolume(1);
                            }
                          });
                        },
                        child: isMute
                            ? const Icon(
                                Icons.volume_off_outlined,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.volume_up_outlined,
                                color: Colors.white,
                              )),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(77, 0, 0, 0),
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(),
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            isPLaying = !isPLaying;
                            if (isPLaying) {
                              videoController.play();
                            } else {
                              videoController.pause();
                            }
                          });
                        },
                        child: isPLaying
                            ? const Icon(
                                Icons.pause,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.play_arrow_outlined,
                                color: Colors.white,
                              )),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: widget.post.imageURl,
                imageBuilder: (context, imageProvider) {
                  return CircleAvatar(
                    radius: 18,
                    foregroundImage: imageProvider,
                  );
                },
              ),
              const SizedBox(
                width: 8,
              ),
              SizedBox(
                width: widget.width - 56,
                child: Text(
                  widget.post.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
        Visibility(
          visible: widget.showLikes,
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("post")
                  .doc(widget.post.postId)
                  .snapshots(),
              builder: (context, snapshot) {
                List result = [];
                if (snapshot.hasData &&
                    snapshot.data!.exists &&
                    snapshot.data!.data()!.containsKey('likedBy')) {
                  result = snapshot.data!.data()!['likedBy'] ?? [];
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 8, top: 12),
                  child: snapshot.hasData
                      ? Text("${result.length} likes")
                      : const Text(""),
                );
              }),
        )
      ],
    );
  }
}
