import 'package:stream_mate/provider/providers.dart';
import 'package:stream_mate/widgets/display_list_of_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreWindow extends ConsumerWidget {
  const ExploreWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double width = MediaQuery.of(context).size.width < 450
        ? MediaQuery.of(context).size.width
        : 400;
    final list = ref.watch(listOfPostProvider);
    return DisplayListOfPost(width: width, snapshot: list);
  }
}
