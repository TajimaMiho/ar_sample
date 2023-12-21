import 'package:ar_sample/themes/app_theme.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Christmas Decorations',
      theme: appTheme(context),
      home: const MyArApp(),
    );
  }
}

class MyArApp extends StatefulWidget {
  const MyArApp({Key? key}) : super(key: key);
  @override
  State<MyArApp> createState() => _MyArAppState();
}

class _MyArAppState extends State<MyArApp> {
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
      body: Stack(
        children: [
          ARKitSceneView(
            showFeaturePoints: true, //特徴点を表示（オブジェクトを置ける場所）
            enableTapRecognizer: true, //タップ認識を有効にする
            planeDetection:
                ARPlaneDetection.horizontalAndVertical, //垂直方向と平面方向の両方で平面を検出
            onARKitViewCreated:
                onARKitViewCreated, //ARKitViewが作成されたときに呼ばれるコールバック関数
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [objectSelection(), objectSelection()],
            ),
          )
        ],
      ));

  //ARKitViewが作成されたときの処理
  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    //特徴点を取得
    this.arkitController.onARTap = (ar) {
      final point = ar.firstWhereOrNull(
        (o) => o.type == ARKitHitTestResultType.featurePoint,
      );
      //特徴点が取得できたら
      if (point != null) {
        _onARTapHandler(point);
      }
    };
  }

  void _onARTapHandler(ARKitTestResult point) {
    //タップされた座標を取得
    final position = vector.Vector3(
      point.worldTransform.getColumn(3).x,
      point.worldTransform.getColumn(3).y,
      point.worldTransform.getColumn(3).z,
    );
    final node = _getNodeFromFlutterAsset(position); //ARオブジェクトを作成
    arkitController.add(node); //ARオブジェクトを追加
  }

  ARKitGltfNode _getNodeFromFlutterAsset(vector.Vector3 position) =>
      ARKitGltfNode(
        //ARオブジェクトの設定
        assetType: AssetType.flutterAsset, //アセットタイプ
        url: 'assets/glb/Gifts.glb', //モデルデータ
        scale: vector.Vector3(0.5, 0.5, 0.5), //拡大率
        position: position, //位置
      );
}

Widget objectSelection() {
  return Container(
    width: 150,
    height: 150,
    margin: const EdgeInsets.all(20),
    decoration: BoxDecoration(
        border: Border.all(),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)),
    child: const Text("ああああ"),
  );
}
