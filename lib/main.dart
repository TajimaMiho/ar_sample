import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ARKitController arkitController;

  //初期化
  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Christmas Decorations')),
        body: ARKitSceneView(
          showFeaturePoints: true, //特徴点を表示（オブジェクトを置ける場所）
          enableTapRecognizer: true, //タップ認識を有効にする
          planeDetection:
              ARPlaneDetection.horizontalAndVertical, //垂直方向と平面方向の両方で平面を検出
          onARKitViewCreated:
              onARKitViewCreated, //ARKitViewが作成されたときに呼ばれるコールバック関数
        ),
      );

  //ARKitViewが作成されたときの処理
  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    //タップされた時座標を取得
    this.arkitController.onARTap = (ar) {
      final point = ar.firstWhereOrNull(
        (o) => o.type == ARKitHitTestResultType.featurePoint,
      );

      if (point != null) {
        _onARTapHandler(point);
      }
    };
  }

  void _onARTapHandler(ARKitTestResult point) {
    final position = vector.Vector3(
      point.worldTransform.getColumn(3).x,
      point.worldTransform.getColumn(3).y,
      point.worldTransform.getColumn(3).z,
    );
    final node = _getNodeFromFlutterAsset(position);
    arkitController.add(node);
  }

  ARKitGltfNode _getNodeFromFlutterAsset(vector.Vector3 position) =>
      ARKitGltfNode(
        assetType: AssetType.flutterAsset,
        url: 'assets/Tree.glb',
        scale: vector.Vector3(0.1, 0.1, 0.1),
        position: position,
      );
}
