import 'package:stream_mate/widgets/comment_container.dart';
import 'package:stream_mate/widgets/profile_image_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Comments {
  Comments(
      {required this.commnet,
      required this.photoUrl,
      required this.uid,
      required this.username});
  final String photoUrl;
  final String username;
  final String commnet;
  final String uid;
}

const uuid = Uuid();

class CommentSheet extends StatefulWidget {
  const CommentSheet({super.key, required this.postId});
  final String postId;
  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  late ScrollController scrollController;
  late TextEditingController textEditingController;
  bool isUploading = false;
  bool isButtonEnabled = false;

  @override
  void initState() {
    textEditingController = TextEditingController();
    scrollController = ScrollController();
    super.initState();
  }

  void _onTap() async {
    setState(() {
      isUploading = true;
    });
    final text = textEditingController.text.trim();
    textEditingController.clear();
    await FirebaseFirestore.instance
        .collection("post")
        .doc(widget.postId)
        .update({
      "comments": FieldValue.arrayUnion([
        {
          "commentId": uuid.v4(),
          "comment": text,
          "photoUrl": FirebaseAuth.instance.currentUser!.photoURL!,
          "uid": FirebaseAuth.instance.currentUser!.uid,
          "username": FirebaseAuth.instance.currentUser!.displayName!
        }
      ])
    });

    setState(() {
      isButtonEnabled = false;
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width < 450
        ? MediaQuery.of(context).size.width
        : 400;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: GestureDetector(
        onTap: () {},
        child: DraggableScrollableSheet(
          maxChildSize: .9,
          minChildSize: .4,
          initialChildSize: .7,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.center,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.shade700, width: .5))),
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: const Text(
                        "Commnets",
                        style: TextStyle(fontSize: 16),
                      )),
                  Expanded(
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("post")
                              .doc(widget.postId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final data =
                                  snapshot.data!.data()!['comments'] ?? [];
                              if (data.isEmpty) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  alignment: Alignment.center,
                                  child: const Text.rich(
                                    textAlign: TextAlign.center,
                                    TextSpan(children: [
                                      TextSpan(
                                        text: "No comments yet.\n",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 26,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                      ),
                                      TextSpan(
                                        text: "Start the conversation",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                      )
                                    ]),
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return CommentContainer(
                                      comment: data[index]['comment'],
                                      username: data[index]['username'],
                                      imageUrl: data[index]['photoUrl'],
                                      uid: data[index]['uid']);
                                },
                              );
                            }

                            return const Center(
                                child: CircularProgressIndicator());
                          })),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                width: .5, color: Colors.grey.shade700))),
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      children: [
                        ProfileImage(
                            radius: 16,
                            imageUrl:
                                FirebaseAuth.instance.currentUser!.photoURL!),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                            child: TextFormField(
                          controller: textEditingController,
                          onChanged: (value) {
                            if (value.trim().isEmpty) {
                              setState(() {
                                isButtonEnabled = false;
                              });
                            } else {
                              setState(() {
                                isButtonEnabled = true;
                              });
                            }
                          },
                          keyboardType: TextInputType.multiline,
                          scrollController: scrollController,
                          minLines: 1,
                          maxLines: 3,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                              suffix: Visibility(
                                visible: isButtonEnabled,
                                child: InkWell(
                                    onTap: isUploading ? null : _onTap,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: isUploading
                                          ? const SizedBox(
                                              width: 19,
                                              height: 19,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                strokeWidth: 2,
                                              )))
                                          : const Text(
                                              "Post",
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 14),
                                            ),
                                    )),
                              ),
                              hintStyle: const TextStyle(
                                  fontWeight: FontWeight.normal),
                              hintText: "Add a commnet...",
                              border: InputBorder.none),
                        )),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
