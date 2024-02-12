import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? url;
  final double? radius;
  final double? borderRadius;

  const Avatar(this.url, {super.key, this.radius, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius != null && borderRadius != null ? radius! + borderRadius! : radius,
      child: CircleAvatar(
        backgroundColor: url != null ? Colors.transparent : null,
        backgroundImage: url != null ? NetworkImage(url!) : null,
        radius: radius,
      )
    );
  }
}
