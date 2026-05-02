import 'package:flutter/material.dart';

enum PlayerState {
  idle(null),
  playing(Icons.pause),
  paused(Icons.play_arrow);

  const PlayerState(this.icon);

  final IconData? icon;
}
