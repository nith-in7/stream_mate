import 'package:stream_mate/widgets/librabry_window.dart';
import 'package:stream_mate/widgets/profile_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentContainer extends StatelessWidget {
  const CommentContainer(
      {super.key,
      required this.comment,
      required this.username,
      required this.imageUrl,
      required this.uid});
  final String imageUrl;
  final String uid;
  final String comment;
  final String username;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width < 450
        ? MediaQuery.of(context).size.width
        : 400;

    void onTap() {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return Scaffold(
              backgroundColor: Colors.black, body: LibraryWindow(uid: uid));
        },
      ));
    }

    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 6.0, left: 6),
              child: InkWell(
                  onTap: onTap,
                  child: ProfileImage(radius: 14, imageUrl: imageUrl))),
          SizedBox(
            width: width - 40,
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: "$username ",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(255, 255, 255, 255)),
                ),
                TextSpan(
                  text: comment,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: Color.fromARGB(255, 255, 255, 255)),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }
}
