import 'package:stream_mate/model/post_model.dart';
import 'package:stream_mate/widgets/helper_methods.dart';
import 'package:stream_mate/widgets/post_container.dart';
import 'package:stream_mate/widgets/shimmer_container.dart';
import 'package:flutter/material.dart';

class DisplayListOfPost extends StatelessWidget {
  const DisplayListOfPost({
    super.key,
    required this.width,
    required this.snapshot,
  });
  final List<VideoPost> snapshot;
  final double width;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width < 450
        ? MediaQuery.of(context).size.width
        : 400;
    return SliverList.separated(
      separatorBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 30, top: 30),
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
          ),
          height: .5,
          width: width,
        );
      },
      itemBuilder: (context, index) {
        final VideoPost data = snapshot[index];
        return FutureBuilder(
            future: cacheVideo(data.videoUrl),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return PostContainer(
                  post: data,
                  navigate: true,
                  width: width,
                  key: ValueKey(data.postId),
                  showLikes: true,
                  videoPath: snapshot.data!,
                );
              }
              return const ShimmerContainer();
            });
      },
      itemCount: snapshot.length,
    );
  }
}
