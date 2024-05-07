import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerContainer extends StatelessWidget {
  const ShimmerContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width < 450
        ? MediaQuery.of(context).size.width
        : 400;

    return SizedBox(
      child: Column(
        children: [
          Stack(
            children: [
              Shimmer.fromColors(
                
                baseColor: Colors.grey.shade900,
                highlightColor: Colors.grey.shade800,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.white),
                  width: width,
                  height: 630,
                ),
              ),
              Positioned(
                top: 10,
                child: Shimmer.fromColors(
                    baseColor: Colors.black.withOpacity(.5),
                    highlightColor: Colors.black.withOpacity(.1),
                    child: Container(
                      height: 70,
                      width: width - 24,
                      margin:
                          const EdgeInsets.only(top: 4, right: 12, left: 12),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: const Color.fromARGB(0, 255, 255, 255)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                          color: const Color.fromARGB(126, 0, 0, 0)),
                    )),
              ),
            ],
          ),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade900,
            highlightColor: Colors.grey.shade800,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 18,
                ),
                const SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      height: 10,
                      width: width - 65,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      height: 10,
                      width: width / 2,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
