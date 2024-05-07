import 'dart:ui';

import 'package:stream_mate/widgets/librabry_window.dart';
import 'package:stream_mate/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';

class PostTopTile extends StatefulWidget {
  const PostTopTile(
      {super.key,
      required this.diff,
      required this.imageUrl,
      required this.uid,
      required this.locationText,
      required this.username,
      required this.navigate});
  final String imageUrl;
  final String diff;
  final String locationText;
  final String username;
  final bool navigate;
  final String uid;
  @override
  State<PostTopTile> createState() => _PostTopTileState();
}

class _PostTopTileState extends State<PostTopTile> {
  void onTap() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return Scaffold(
            backgroundColor: Colors.black,
            body: LibraryWindow(uid: widget.uid));
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4, right: 12, left: 12),
      decoration: BoxDecoration(
          border: Border.all(
              width: 1, color: const Color.fromARGB(0, 255, 255, 255)),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          color: const Color.fromARGB(126, 0, 0, 0)),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(right: 6.0, left: 6),
                  child: InkWell(
                      onTap: widget.navigate ? onTap : null,
                      child:
                          ProfileImage(radius: 25, imageUrl: widget.imageUrl))),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: widget.navigate ? onTap : null,
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: "${widget.username} ",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        TextSpan(
                          text: widget.diff,
                          style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        )
                      ]),
                    ),
                  ),
                  Text(
                    textAlign: TextAlign.justify,
                    widget.locationText,
                    style: const TextStyle(
                        color: Color.fromARGB(221, 255, 255, 255)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
