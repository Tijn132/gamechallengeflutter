import 'package:flame/collisions.dart';

class CustomHitbox {
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;

  CustomHitbox({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });
}

bool checkCollision(player, object) {
  final hitbox = player.children.whereType<RectangleHitbox>().first;
  final playerX = player.position.x + hitbox.position.x;
  final playerY = player.position.y + hitbox.position.y;
  final playerWidth = hitbox.size.x;
  final playerHeight = hitbox.size.y;

  final objectX = object.x;
  final objectY = object.y;
  final objectWidth = object.width;
  final objectHeight = object.height;

  return (
    playerY < objectY + objectHeight &&
    playerY + playerHeight > objectY &&
    playerX < objectX + objectWidth &&
    playerX + playerWidth > objectX);
}