import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String url;
  final double? radius;

  const Avatar(this.url, {super.key, this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: NetworkImage(url),
      radius: radius,
    );
  }
}
