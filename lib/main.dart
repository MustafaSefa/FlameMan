import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart';

class FlameMan extends FlameGame with PanDetector, TapDetector,KeyboardEvents {
  late Player player;
  late SpriteComponent background;
  int score = 0;
  double timer = 0.5;
  bool restart = false;
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await loadSprite('bg.png');
    background = SpriteComponent(
      sprite: sprite,
      size: size,
      
    );
    add(background);
    player = Player();

    add(player);
    add(EnemyManager());
  }
  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.global, player);
  }
  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    add(Flame(position: player.position));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final bullets = children.whereType<Flame>();
    final _player = children.whereType<Player>();
    for (final enemy in children.whereType<Enemy>()) {
      for (final bullet in bullets) {
        if (enemy.containsPoint(bullet.absoluteCenter)) {
          remove(enemy);
          remove(bullet);
          score++;
          break;
        }
      }
    }
    for (final enemy in children.whereType<Enemy>()) {
      for (final p in _player) {
        if (enemy.containsPoint(p.absoluteCenter)) {
          remove(enemy);
          remove(p);
          restart = true;
        }
      }
    }
    if(restart){
      timer += timer * 1;
      if(timer > 900000){
        runApp(GameWidget(
        game: FlameMan(),
        ));
      }
       
    }
    
  }
}

class Flame extends SpriteComponent with HasGameRef<FlameMan> {
  static const _speed = 550;

  Flame({required super.position});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('17.png'); // flame
    width = 100;
    height = 100;
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += _speed * dt;

    if (position.x > 2000) {
      gameRef.remove(this);
    }
  }
}

class EnemyManager extends TimerComponent with HasGameRef<FlameMan> {

  EnemyManager() : super(period: 1, repeat: true);

  @override
  void onTick() {
    super.onTick();

    _spawnEnemy();
  }

  void _spawnEnemy() {
    final enemy = Enemy(
      position: Vector2(1500, 2 * 220),
    );
    enemy.size = Vector2(100, 100);
    gameRef.add(enemy);
  }
}

class Enemy extends SpriteComponent with HasGameRef<FlameMan> {
  static const _speed = 250;

  Enemy({required super.position});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    sprite = await gameRef.loadSprite('water.png');
    width = 50;
    height = 50;
    anchor = Anchor.center;
  
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x -= _speed * dt;

    if (position.x > gameRef.size.x) {
      gameRef.remove(this);
    }
  }
}

class Player extends SpriteComponent with HasGameRef<FlameMan> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await gameRef.loadSprite('Idle4.png');
    position = Vector2(100, 450);
    width = 120;
    height = 120;
    anchor = Anchor.center;
  }

  void move(Vector2 delta, Player p) {
    delta.clamp(Vector2(0, -5), Vector2(0, 6));
      position.add(delta);

  }
}

void main() {
  runApp(GameWidget(
    game: FlameMan(),
  ));
}
