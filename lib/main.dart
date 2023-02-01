import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:tiled/tiled.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      showPerformanceOverlay: true,
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
    camera.zoom = 0.3;
    add(FpsTextComponent(position: Vector2.all(300)));
    final contents = await Flame.bundle.loadString(
      'assets/tiles/exterior_map_ko.tmx',
    );
    final tiledMap = await TiledMap.fromString(
      contents,
      FlameTsxProvider.parse,
    );

    final layerIds = [
      17,
      87,
      64,
      86,
      12,
      84,
      30,
      93,
      55,
      96,
      99,
      39,
    ];
    for (var layer in tiledMap.layers) {
      if (layer.type != LayerType.tileLayer) continue;
      if (layer.id == layerIds[5]) continue;
      layer.visible = false;
    }
    add(
      MyTiledComponent(
        await RenderableTiledMap.fromTiledMap(
          tiledMap,
          Vector2.all(32),
          useMine: false,
        ),
      ),
    );
    add(Joystick());
    return super.onLoad();
  }
}

class MyTiledComponent extends TiledComponent<AppGame> {
  // final Stopwatch watch = Stopwatch();
  // final fps = FpsComponent();
  MyTiledComponent(super.tileMap);

  @override
  Future<void>? onLoad() {
    for (var element in tileMap.map.layers) {
      if (element.type != LayerType.tileLayer) continue;
      // print(element.id);
      // print(element.name);
    }
    gameRef.camera.snapTo(Vector2.all(1200));
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    Flame.images;
    // watch.reset();
    // watch.start();
    super.render(canvas);
    // fps.adding(watch.elapsedMicroseconds);
  }

  @override
  void update(double dt) {
    // print(fps.fps);
    super.update(dt);
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
    parent.camera.translateBy(delta * 3);
    parent.camera.snap();
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

class FpsComponent {
  FpsComponent({
    this.windowSize = 60,
  });

  /// The sliding window size, i.e. the number of game ticks over which the fps
  /// measure will be averaged.
  final int windowSize;

  /// The queue of the recent game tick durations.
  /// The length of this queue will not exceed [windowSize].
  final Queue<int> window = Queue();

  /// The sum of all values in the [window] queue.
  int _sum = 0;

  void adding(int dt) {
    window.addLast(dt);
    _sum += dt;
    if (window.length > windowSize) {
      _sum -= window.removeFirst();
    }
  }

  /// Get the current average FPS over the last [windowSize] frames.
  int get fps {
    return window.isEmpty ? 0 : _sum ~/ window.length;
  }
}
