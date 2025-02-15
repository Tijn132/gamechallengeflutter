import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:gamechallenge/level.dart';

class GameChallenge extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection{

  final World myWorld = Level();

  @override
  FutureOr<void> onLoad() async{

    await images.loadAllImages();

    final camera = CameraComponent.withFixedResolution(world: myWorld, width: 640, height: 360);
    camera.viewfinder.anchor = Anchor.topLeft;

    addAll([camera, myWorld]);
    return super.onLoad();
  }
}