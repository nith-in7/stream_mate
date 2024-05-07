import 'package:stream_mate/model/post_model.dart';
import 'package:stream_mate/widgets/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListOfPostNotifier extends StateNotifier<List<VideoPost>> {
  ListOfPostNotifier(super.state);

  void add(VideoPost newData) {
    state = [...state, newData];
  }

  void addFirst(VideoPost newData) {
    state = [newData, ...state];
  }

  Future<List<VideoPost>> getData() async {
    final QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore
        .instance
        .collection("post")
        .orderBy("date", descending: true)
        .get();

    state = data.docs.map((e) {
      final Timestamp uploadDate = e.data()['date'];
      final diff = getDateDifference(uploadDate.toDate());
      return VideoPost(
          caption: e.data()['caption'],
          imageURl: e.data()['imageUrl'],
          postId: e.data()['postId'],
          location: e.data()['location'],
          userId: e.data()['userId'],
          username: e.data()['username'],
          videoUrl: e.data()['videoUrl'],
          dateDiff: diff);
    }).toList();
    return state;
  }

  // void likePost({required String postId}) async {
  //   final index = state.indexWhere((element) => element.postId == postId);

  //   if (!state[index].likedBy.contains(currentUuser.uid)) {
  //     final VideoPost tobeEdited = state[index];
  //     final updatedPost = tobeEdited
  //         .copyWith(likedBy: [...tobeEdited.likedBy, currentUuser.uid]);
  //     final List<VideoPost> newData = state;
  //     newData.removeAt(index);
  //     newData.insert(index, updatedPost);
  //     state = newData;
  //   }
  //   state = [...state];
  //   await FirebaseFirestore.instance.collection("post").doc(postId).update({
  //     "likedBy": [currentUuser.uid, currentUuser.uid]
  //   });
  // }

  // void dislikePost({required String postId}) async {
  //   final index = state.indexWhere((element) => element.postId == postId);

  //   if (state[index].likedBy.contains(currentUuser.uid)) {
  //     state[index]
  //         .likedBy
  //         .removeWhere((element) => element == currentUuser.uid);
  //   }

  //   state = [...state];
  //   final  result = await FirebaseFirestore
  //       .instance
  //       .collection("post")
  //       .doc(postId).update({"likedBy":})
  //   if (result.docs.isNotEmpty) {
  //     for (var element in result.docs) {
  //       await element.reference.delete();
  //     }
  //   }
  // }
}

final listOfPostProvider =
    StateNotifierProvider<ListOfPostNotifier, List<VideoPost>>((ref) {
  return ListOfPostNotifier([]);
});
