import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String image;
  final double? radius;

  const Avatar(this.image, {super.key, this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: NetworkImage(image),
      radius: radius,
    );
  }
}
