import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeductionFormController extends GetxController {
  final TextEditingController nosController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController breadthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  var nos = ''.obs;
  var length = ''.obs;
  var breadth = ''.obs;
  var height = ''.obs;

  @override
  void onInit() {
    super.onInit();
    nosController.addListener(() => nos.value = nosController.text);
    lengthController.addListener(() => length.value = lengthController.text);
    breadthController.addListener(() => breadth.value = breadthController.text);
    heightController.addListener(() => height.value = heightController.text);
  }

  @override
  void onClose() {
    nosController.dispose();
    lengthController.dispose();
    breadthController.dispose();
    heightController.dispose();
    super.onClose();
  }

  Future<void> onRefresh() async {
    nosController.clear();
    lengthController.clear();
    breadthController.clear();
    heightController.clear();
    nos.value = '';
    length.value = '';
    breadth.value = '';
    height.value = '';
  }

  void submitForm() {
    // Add logic to handle form submission
    print('Nos: $nos, Length: $length, Breadth: $breadth, Height: $height');
  }
}