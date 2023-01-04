import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GameWidget(
      game: AppGame(),
    ));
  }
}

class AppGame extends FlameGame with HasDraggables {
  @override
  bool get debugMode => false;

  @override
  Future<void>? onLoad() async {
    camera.zoom = 0.4;
    add(FpsTextComponent(position: Vector2.all(200)));
    add(await TiledComponent.load('exterior_map_2_ko.tmx', Vector2.all(32)));
    add(Joystick());
    return super.onLoad();
  }
}

class Joystick extends JoystickComponent with ParentIsA<AppGame> {
  Joystick()
      : super(
          size: 100,
          margin: const EdgeInsets.only(bottom: 40, left: 40),
          priority: 1000,
          knob: _Knob(),
        );

  @override
  void update(double dt) {
    parent.camera.translateBy(delta * 10000);
    super.update(dt);
  }
}

class _Knob extends CircleComponent with ParentIsA<Joystick> {
  _Knob()
      : super(
          paint: Paint()..color = Colors.white,
          priority: 100,
          radius: 50,
          anchor: Anchor.center,
        );
}
