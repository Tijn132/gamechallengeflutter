import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/rendering.dart';
// ignore: implementation_imports
import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:gamechallenge/collision_object.dart';
import 'package:gamechallenge/flag.dart';
import 'package:gamechallenge/game_challenge.dart';
import 'package:gamechallenge/collision.dart';
import 'package:gamechallenge/level.dart';

enum PlayerState { idle }

enum PlayerDirection { left, right, up, leftUp, rightUp, none }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<GameChallenge>, KeyboardHandler, CollisionCallbacks {
  Player({position}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  final double stepTime = 0.1;
  final double gravity = 9.8;
  final double jumpForce = 300;
  final double terminalVelocity = 300;

  PlayerDirection playerDirection = PlayerDirection.none;
  double horizontalMovement = 0;
  double moveSpeed = 150;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  double lives = 2;
  double opacityGray = 0.6;
  List<CollisionObject> collisionObjects = [];
  bool hasFallenToDeath = false;

  late Sprite heartSprite;
  List<SpriteComponent> heartIcons = [];

  @override
  Future<void> onLoad() async {
    loadAllAnimations();
    add(RectangleHitbox.relative(
      Vector2(0.5, 0.7),
      parentSize: size,
    ));

    heartSprite = await gameRef.loadSprite('sprites/heart.png');
    updateUILives();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    updatePlayerMovement(dt);
    checkHorizontalCollisions();
    applyGravity(dt);
    checkVerticalCollisions();
    checkForPlayerDeath();
    updateUILives();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Flag) other.collidedWithPlayer();
    super.onCollision(intersectionPoints, other);
  }

  void loadAllAnimations() {
    idleAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('sprites/knight.png'),
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 32 * 2),
        ));

    animations = {PlayerState.idle: idleAnimation};

    current = PlayerState.idle;
  }

  void updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) {
      playerJump(dt);
    }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void playerJump(double dt) {
    velocity.y = -jumpForce;
    position.y += velocity.y * dt;
    hasJumped = false;
    isOnGround = false;
  }

  void checkHorizontalCollisions() {
    for (final object in collisionObjects) {
      if (checkCollision(this, object)) {
        final hitbox = children.whereType<RectangleHitbox>().first;
        final playerWidth = hitbox.size.x;

        if (velocity.x > 0) {
          velocity.x = 0;
          position.x = object.x - playerWidth - hitbox.position.x;
        }
        if (velocity.x < 0) {
          velocity.x = 0;
          position.x = object.x + object.width - hitbox.position.x;
        }
      }
    }
  }

  void applyGravity(double dt) {
    velocity.y += gravity;
    velocity.y = velocity.y.clamp(-jumpForce, terminalVelocity);
    position.y += velocity.y * dt;
    isOnGround = false;
  }

  void checkVerticalCollisions() {
    for (final object in collisionObjects) {
      if (checkCollision(this, object)) {
        final hitbox = children.whereType<RectangleHitbox>().first;
        final playerHeight = hitbox.size.y;

        if (velocity.y > 0) {
          velocity.y = 0;
          position.y = object.y - playerHeight - hitbox.position.y;
          isOnGround = true;
        }
        if (velocity.y < 0) {
          velocity.y = 0;
          position.y = object.y + object.height - hitbox.position.y;
        }
      }
    }
  }

  void updateOpacity() {
    decorator.addLast(PaintDecorator.grayscale(opacity: opacityGray));
  }

  void checkForPlayerDeath() {
    if (position.y >= 350 && !hasFallenToDeath) {
      hasFallenToDeath = true;
      lives -= 1;
      opacityGray = 0.5;
      updateOpacity();
      position = Vector2(32, 293);
      hasFallenToDeath = false;
    }

    if (lives <= 0) {
      gameRef.myWorld.add((gameRef.myWorld as Level).gameOverSprite);
      removeFromParent();
    }
  }

  void updateUILives() {
    for (final heart in heartIcons) {
      heart.removeFromParent();
    }
    heartIcons.clear();

    for (int i = 0; i < lives; i++) {
      final heart = SpriteComponent(
        sprite: heartSprite,
        size: Vector2(12, 12),
        position: Vector2(i * 20, -8),
      );

      heartIcons.add(heart);
      add(heart);
    }
  }
}
