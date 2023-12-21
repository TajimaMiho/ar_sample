import 'package:ar_sample/class/3d_object_class.dart';
import 'package:ar_sample/controller/arObjects_controller.dart';
import 'package:ar_sample/themes/app_theme.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

final List<ARObject> arObjects = [
  ARObject('tree', 'assets/imgs/tree.png', 'assets/glb/Tree.glb', 0.5),
  ARObject('presents', 'assets/imgs/gifts.png', 'assets/glb/Gifts.glb', 0.3),
  ARObject('snowman', 'assets/imgs/snowman.png', 'assets/glb/Snowman.glb', 0.1),
  ARObject('socks', 'assets/imgs/socks.png', 'assets/glb/Socks.glb', 0.1),
];

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        body: Center(
          child: HookConsumer(
            builder: (context, ref, _) {
              final selectedObject = ref.watch(selectedObjectProvider);
              return Stack(
                children: [
                  ARKitSceneView(
                    showFeaturePoints: true, //特徴点を表示（オブジェクトを置ける場所）
                    enableTapRecognizer: true, //タップ認識を有効にする
                    planeDetection: ARPlaneDetection
                        .horizontalAndVertical, //垂直方向と平面方向の両方で平面を検出
                    onARKitViewCreated: (controller) => onARKitViewCreated(
                        controller, ref), //ARKitViewが作成されたときに呼ばれるコールバック関数
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var arObject in arObjects)
                          objectSelection(arObject, selectedObject),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
      );

  //ARKitViewが作成されたときの処理
  void onARKitViewCreated(ARKitController arkitController, WidgetRef ref) {
    this.arkitController = arkitController;
    //特徴点を取得
    this.arkitController.onARTap = (ar) {
      final point = ar.firstWhereOrNull(
        (o) => o.type == ARKitHitTestResultType.featurePoint,
      );
      //特徴点が取得できたら
      if (point != null) {
        _onARTapHandler(point, ref.watch(selectedObjectProvider));
      }
    };
  }

  void _onARTapHandler(ARKitTestResult point, ARObject selectedObject) {
    //タップされた座標を取得
    final position = vector.Vector3(
      point.worldTransform.getColumn(3).x,
      point.worldTransform.getColumn(3).y,
      point.worldTransform.getColumn(3).z,
    );
    final node =
        _getNodeFromFlutterAsset(position, selectedObject); //ARオブジェクトを作成
    arkitController.add(node); //ARオブジェクトを追加
  }

  ARKitGltfNode _getNodeFromFlutterAsset(
      vector.Vector3 position, ARObject selectedObject) {
    return ARKitGltfNode(
      assetType: AssetType.flutterAsset,
      url: selectedObject.modelURL,
      scale: vector.Vector3(
          selectedObject.vector, selectedObject.vector, selectedObject.vector),
      position: position,
    );
  }
}

Widget objectSelection(ARObject arObject, ARObject selectedObject) {
  return HookConsumer(
    builder: (context, ref, _) {
      return GestureDetector(
        onTap: () => ref
            .read(selectedObjectProvider.notifier)
            .setSelectedObject(arObject),
        child: Container(
          width: 150,
          height: 180,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: arObject == selectedObject ? Colors.red : Colors.white,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Text(arObject.text),
              SizedBox(
                width: 150,
                height: 150,
                child: Image(
                  image: AssetImage(arObject.imgURL),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
