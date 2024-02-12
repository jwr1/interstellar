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
        backgroundColor: radius == null || borderRadius == null ? Colors.transparent : null,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          foregroundImage: url != null ? NetworkImage(url!) : null,
          backgroundImage: url == null ? const AssetImage('assets/icons/logo.png') : null,
          radius: radius,
        )
    );
  }
}
