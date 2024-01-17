import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/create_screen.dart';
import 'dart:math';

import 'package:media_kit/media_kit.dart';

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
  late final Animation<Offset> _slideAnimationPosts = Tween<Offset>(
    begin: const Offset(1.5, 0),
    end: Offset.zero
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: const Interval(
      0,
      0.8,
      curve: Curves.easeInOut
    ),
  ));

  late final Animation<Offset> _slideAnimationEntries = Tween<Offset>(
    begin: const Offset(1.5, 0),
    end: Offset.zero
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: const Interval(
      0.2,
      1,
      curve: Curves.easeInOut
    ),
  ));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SlideTransition(
          position: _slideAnimationEntries,
          child: Container(
            width: 45,
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: AspectRatio(
              aspectRatio: 1,
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
        ),
        SlideTransition(
          position: _slideAnimationPosts,
          child: Container(
            width: 45,
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: AspectRatio(
              aspectRatio: 1,
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
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
          child: FloatingActionButton(
            onPressed: () {
              if (_animationController.isDismissed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget? child) {
                return Transform(
                  transform: Matrix4.rotationZ(_animationController.value * 0.75 * pi),
                  alignment: FractionalOffset.center,
                  child: const Icon(Icons.add),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}