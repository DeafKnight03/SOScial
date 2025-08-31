import 'package:flutter/material.dart';


class SimpleImageScroller extends StatelessWidget {
  final List<String> imageUrls;

  const SimpleImageScroller({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty || imageUrls.length == 0) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 100, // height of the scroller
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Image.network(
              imageUrls[index],
              width: 350,
              height: 250,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
