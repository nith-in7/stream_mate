import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final currentUuser = FirebaseAuth.instance.currentUser!;

Future<File> cacheVideo(String videoUrl) async {
  return await DefaultCacheManager().getSingleFile(videoUrl);
}

String getDateDifference(DateTime uploadDate) {
  final Duration diff = DateTime.now().difference(uploadDate);
  if (diff.inSeconds < 60) {
    return "${diff.inSeconds}s";
  }
  if (diff.inMinutes < 60) {
    return "${diff.inMinutes}m";
  }
  if (diff.inHours < 24) {
    return "${diff.inHours}h";
  }
  if (diff.inDays < 7) {
    return "${diff.inDays}d";
  }
  return "${(diff.inDays / 7).ceil()}w";
}

Future<void> likeThePost(String postId) async {
  await FirebaseFirestore.instance.collection("post").doc(postId).update({
    'likedBy': FieldValue.arrayUnion([currentUuser.uid])
  });
}

Future<void> removeLike(String postId) async {
  await FirebaseFirestore.instance.collection("post").doc(postId).update({
    'likedBy': FieldValue.arrayRemove([currentUuser.uid])
  });
}
