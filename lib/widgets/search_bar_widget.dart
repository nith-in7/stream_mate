import 'package:stream_mate/widgets/librabry_window.dart';
import 'package:stream_mate/widgets/profile_image_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late SearchController searchController;
  late FocusNode focusNode;
  late Future<QuerySnapshot<Map<String, dynamic>>> usernameList;

  List<Widget> listWidgets = [];
  @override
  void initState() {
    searchController = SearchController();
    focusNode = FocusNode();
    usernameList = FirebaseFirestore.instance.collection("username_list").get();
    super.initState();
  }

  void onTap(String uid) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return Scaffold(
            backgroundColor: Colors.black, body: LibraryWindow(uid: uid));
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
        viewBackgroundColor: Colors.black,
        viewSurfaceTintColor: Colors.black,
        viewLeading: IconButton(
            onPressed: () {
              searchController.clear();
              searchController.closeView(null);
              focusNode.unfocus();
            },
            icon: const Icon(Icons.arrow_back)),
        searchController: searchController,
        builder: (BuildContext context, SearchController controller) {
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: SearchBar(
              focusNode: focusNode,
              backgroundColor: const MaterialStatePropertyAll(Colors.black),
              surfaceTintColor: const MaterialStatePropertyAll(Colors.black),
              hintText: "Search",
              hintStyle: MaterialStatePropertyAll(
                  TextStyle(color: Colors.grey.shade500)),
              controller: controller,
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 0)),
              onTap: () {
                controller.openView();
              },
              onChanged: (value) async {
                if (!controller.isOpen) {
                  controller.openView();
                }
              },
              leading: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              trailing: const <Widget>[Icon(Icons.tune)],
            ),
          );
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) async {
          final QuerySnapshot<Map<String, dynamic>> data = await usernameList;
          print("helooooo ${data.docs.length}");
          final List<UserDetailes> userList = data.docs
              .map((e) => UserDetailes(
                  displayName: e.data()["displayName"] ?? "",
                  imageUrl: e.data()["imageUrl"],
                  uid: e.data()["uid"],
                  username: e.data()["username"]))
              .toList();

          return userList
              .where((element) => element.username
                  .contains(controller.text == "" ? " " : controller.text))
              .map((e) => ListTile(
                    onTap: () {
                      onTap(e.uid);
                    },
                    leading: ProfileImage(radius: 20, imageUrl: e.imageUrl),
                    subtitle: Text(e.displayName),
                    title: Text(e.username),
                  ));
        });
  }
}

// class UsernameSuggestion extends StatefulWidget {
//   const UsernameSuggestion(
//       {super.key, required this.searchController, required this.query});
//   final String query;
//   final SearchController searchController;
//   @override
//   State<UsernameSuggestion> createState() => _UsernameSuggestionState();
// }

// class _UsernameSuggestionState extends State<UsernameSuggestion> {
//   late Stream<QuerySnapshot<Map<String, dynamic>>> usernameStream;
//   @override
//   void initState() {
//     usernameStream = FirebaseFirestore.instance
//         .collection("username_list")
//         .where('username', isGreaterThanOrEqualTo: widget.query)
//         .where('username', isLessThan: '${widget.query}z')
//         .snapshots();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: usernameStream,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           print("hellloo oooo ${snapshot.data!.docs.length}");
//           final e = snapshot.data!.docs[0];
//           return ListTile(
//             leading: ProfileImage(radius: 20, imageUrl: e.data()['imageUrl']),
//             subtitle: Text(e.data()['uid']),
//             title: Text(e.data()["username"]),
//           );
//         }

//         return const [ListTile(
//           title: Text("data"),
//         );]
//       },
//     );
//   }
// }

class UserDetailes {
  UserDetailes(
      {required this.displayName,
      required this.imageUrl,
      required this.uid,
      required this.username});
  final String username;
  final String displayName;
  final String uid;
  final String imageUrl;
}
