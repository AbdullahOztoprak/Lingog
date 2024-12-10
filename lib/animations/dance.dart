import 'package:flutter/material.dart';

class Dance extends StatefulWidget {
  final Widget child;
  final bool animate;
  final int delay;

  const Dance({
    required this.animate,
    required this.delay,
    required this.child,
    super.key,
  });

  @override
  State<Dance> createState() => _DanceState();
}

class _DanceState extends State<Dance> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, 0), end: const Offset(0, -0.80)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, -0.80), end: const Offset(0, 0)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, 0), end: const Offset(0, -0.30)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, -0.30), end: const Offset(0, 0)),
        weight: 8,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void didUpdateWidget(Dance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
