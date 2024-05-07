import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class UploadVideo extends StatefulWidget {
  const UploadVideo(
      {super.key,
      required this.videoPath,
      required this.progress,
      required this.width,
      required this.onCancel});
  final File videoPath;
  final double progress;
  final double width;
  final void Function() onCancel;

  @override
  State<UploadVideo> createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {
  late VideoPlayerController videoController;
  @override
  void initState() {
    videoController = VideoPlayerController.file(widget.videoPath)
      ..initialize();
    super.initState();
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(width: 1, color: Colors.grey.shade200))),
      padding: const EdgeInsets.all(8),
      width: widget.width,
      height: 90,
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                child: VideoPlayer(videoController)),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 250),
                tween: Tween<double>(begin: 0.0, end: widget.progress),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    backgroundColor: Colors.grey.shade300,
                    value: value,
                    color: Colors.blueAccent,
                    minHeight: 2,
                  );
                }),
          )),
          InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onCancel,
              child: const Icon(Icons.cancel))
        ],
      ),
    );
  }
}
