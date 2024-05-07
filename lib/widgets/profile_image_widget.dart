import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.radius,
    required this.imageUrl,
  });
  final String imageUrl;

  final double radius;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      placeholder: (context, url) {
        return Container(
          width: radius*2,
          height: radius*2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
        );
      },
      imageBuilder: (context, imageProvider) {
        return Container(
          width: radius*2,
          height: radius*2,
          decoration:  BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200
                  ),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: CircleAvatar(
              foregroundImage: imageProvider,
            ),
          ),
        );
      },
      filterQuality: FilterQuality.low,
      errorWidget: (context, url, error) => Container(
        color: Colors.black,
      ),
      fit: BoxFit.cover,
      imageUrl: imageUrl,
    );
  }
}
