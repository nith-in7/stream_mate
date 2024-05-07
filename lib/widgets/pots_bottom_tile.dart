import 'dart:ui';

import 'package:stream_mate/widgets/comment_sheet_widgets.dart';
import 'package:stream_mate/widgets/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostBottomTile extends ConsumerStatefulWidget {
  const PostBottomTile({super.key, required this.postId});

  final String postId;
  @override
  ConsumerState<PostBottomTile> createState() => _PostBottomTileState();
}

class _PostBottomTileState extends ConsumerState<PostBottomTile> {
  @override
  void initState() {
    super.initState();
  }

  bool isLiked = false;
  List result = [];
  final _currentUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("post")
            .doc(widget.postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data!.exists &&
              snapshot.data!.data()!.containsKey('likedBy')) {
            result = snapshot.data!.data()!['likedBy'] ?? [];
            isLiked = result.contains(_currentUser.uid);
          }
          return Container(
            width: 130,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1, color: const Color.fromARGB(0, 255, 255, 255)),
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                color: const Color.fromARGB(126, 0, 0, 0)),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (isLiked == false) {
                              await likeThePost(widget.postId);
                            } else {
                              await removeLike(widget.postId);
                            }
                          },
                          icon: isLiked
                              ? const Icon(
                                  Icons.favorite,
                                  size: 32,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.favorite_border,
                                  size: 32,
                                  color: Colors.white,
                                ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          elevation: 0,
                          
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return CommentSheet(postId:widget.postId);
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.mode_comment_outlined,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
