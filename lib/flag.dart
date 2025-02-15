import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame/particles.dart';
import 'package:gamechallenge/collision.dart';
import 'package:gamechallenge/game_challenge.dart';
import 'package:gamechallenge/level.dart';

class Flag extends SpriteAnimationComponent
    with HasGameRef<GameChallenge>, CollisionCallbacks {
  Flag({position, size})
      : super(position: position, size: size, anchor: Anchor.center);

  late Timer particleTimer;

  bool collected = false;
  final double stepTime = 0.1;
  final hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 10,
    width: 12,
    height: 12,
  );

  @override
  void update(double dt) {
    particleTimer.update(dt);
    super.update(dt);
  }

  @override
  FutureOr<void> onLoad() {
    particleTimer = Timer(0.1, repeat: true, onTick: addEffectsToCoin);
    particleTimer.start();
    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive));
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('sprites/coin.png'),
        SpriteAnimationData.sequenced(
          amount: 12,
          stepTime: stepTime,
          textureSize: Vector2(16, 16),
        ));
    return super.onLoad();
  }

  void collidedWithPlayer() {
    if (!collected) {
      collected = true;
      gameRef.myWorld.add((gameRef.myWorld as Level).winSprite);
      removeFromParent();
    }
  }

  void addEffectsToCoin() {
    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 10,
        generator: (i) {
          final angle = (i / 10) * 2 * pi;
          const radius = 20.0;
          return MovingParticle(
            from: Vector2(radius * cos(angle), radius * sin(angle)),
            to: Vector2(radius * cos(angle + 2), radius * sin(angle + 2)),
            child: CircleParticle(
              radius: 1,
              lifespan: 1,
              paint: Paint()..color = Colors.yellow,
            ),
          );
        },
      ),
      position: size / 2,
      priority: 1,
    );

    final effect =
        ScaleEffect.to(Vector2.all(0.6), EffectController(duration: 0.5));

    add(effect);
    add(particleComponent);
  }
}
