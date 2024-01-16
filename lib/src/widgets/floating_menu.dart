import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/create_screen.dart';

class FloatingMenu extends StatefulWidget{

  final int? magazineId;
  final String? magazineName;

  const FloatingMenu({
    this.magazineId,
    this.magazineName,
    super.key
  });

  @override
  State<FloatingMenu> createState() => _FloatingMenuState();

}

class _FloatingMenuState extends State<FloatingMenu> with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final Animation<Offset> _slideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero
  ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut
  ));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => CreateScreen(
                          CreateType.entry,
                          magazineId: widget.magazineId,
                          magazineName: widget.magazineName,
                        )
                    )
                );
              },
              heroTag: null,
              child: const Text("Entry"),
            ),
          ),
        ),
        SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => CreateScreen(
                          CreateType.link,
                          magazineId: widget.magazineId,
                          magazineName: widget.magazineName,
                        )
                    )
                );
              },
              heroTag: null,
              child: const Text("Link"),
            ),
          ),
        ),
        SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => CreateScreen(
                          CreateType.image,
                          magazineId: widget.magazineId,
                          magazineName: widget.magazineName,
                        )
                    )
                );
              },
              heroTag: null,
              child: const Text("Image"),
            ),
          ),
        ),
        SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => CreateScreen(
                          CreateType.post,
                          magazineId: widget.magazineId,
                          magazineName: widget.magazineName,
                        )
                    )
                );
              },
              heroTag: null,
              child: const Text("Post"),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: FloatingActionButton(
              onPressed: () {
                if (_animationController.isDismissed) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              child: const Icon(Icons.add)
          ),
        )
      ],
    );
  }
}