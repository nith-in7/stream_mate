// ignore_for_file: public_member_api_docs, sort_constructors_first
class VideoPost {
  const VideoPost(
      {required this.username,
      required this.imageURl,
      required this.postId,
      required this.caption,
      required this.dateDiff,
      required this.userId,
      required this.location,
      required this.videoUrl});

  final String username;
  final String userId;
  final String imageURl;
  final String postId;
  final String dateDiff;
  final String videoUrl;
  final String caption;
  final String location;

  VideoPost copyWith({
    String? username,
    String? userId,
    String? imageURl,
    String? postId,
    String? dateDiff,
    String? videoUrl,
    String? caption,
    String? location,
    List<String>? likedBy,
  }) {
    return VideoPost(
      username: username ?? this.username,
      userId: userId ?? this.userId,
      imageURl: imageURl ?? this.imageURl,
      postId: postId ?? this.postId,
      dateDiff: dateDiff ?? this.dateDiff,
      videoUrl: videoUrl ?? this.videoUrl,
      caption: caption ?? this.caption,
      location: location ?? this.location,
    );
  }
}

class Comments {
  Comments({required this.userId, required this.comment});
  final String userId;
  final String comment;
}

class PostLikes {
  PostLikes({required this.postId, required this.uid});
  final String postId;
  final List<String> uid;
}
