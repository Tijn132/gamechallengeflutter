import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:gamechallenge/collision_object.dart';
import 'package:gamechallenge/flag.dart';
import 'package:gamechallenge/player.dart';

class Level extends World {
  late TiledComponent level;
  late Player player;
  late Flag flag;
  List<CollisionObject> collisionObjects = [];
  late SpriteComponent gameOverSprite;
  late SpriteComponent winSprite;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('Level-01.tmx', Vector2.all(16));
    add(level);

    gameOverSprite = SpriteComponent(
      sprite: await Sprite.load('sprites/game_over.png'),
      size: Vector2(200, 100),
      position: Vector2(200, 50),
    );
    winSprite = SpriteComponent(
      sprite: await Sprite.load('sprites/win.png'),
      size: Vector2(200, 100),
      position: Vector2(200, 50),
    );

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player = Player(position: Vector2(spawnPoint.x, spawnPoint.y));
            add(player);
            break;
            case 'Flag':
            flag = Flag(position: Vector2(spawnPoint.x + 16, spawnPoint.y + 16), size : Vector2(spawnPoint.width, spawnPoint.height));
            add(flag);
            break;
          default:
        }
      }
    }

    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        final collisionObject = CollisionObject(
          position: Vector2(collision.x, collision.y),
          size: Vector2(collision.width, collision.height),
        );
        collisionObjects.add(collisionObject);
        add(collisionObject);
      }

      player.collisionObjects = collisionObjects;
      return super.onLoad();
    }
  }
}
