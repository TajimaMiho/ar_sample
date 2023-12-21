import 'package:ar_sample/class/3d_object_class.dart';
import 'package:ar_sample/main_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedObjectProvider =
    StateNotifierProvider<SelectedObjectController, ARObject>(
  (ref) => SelectedObjectController(arObjects.first),
);

class SelectedObjectController extends StateNotifier<ARObject> {
  SelectedObjectController(ARObject value) : super(value);

  void setSelectedObject(ARObject arObject) {
    state = arObject;
  }
}
