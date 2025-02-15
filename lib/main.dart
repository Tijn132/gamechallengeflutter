import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:gamechallenge/game_challenge.dart';

void main() {
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  GameChallenge game = GameChallenge();
  runApp(GameWidget(game: game));
}