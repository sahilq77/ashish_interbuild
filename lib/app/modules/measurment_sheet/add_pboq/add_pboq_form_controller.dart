import 'package:get/get.dart';

class FieldSet {
  var selectedZone = ''.obs;
  var planningStatus = 'Not Started'.obs; // Default read-only value
  var selectedLocation = ''.obs;
  var subLocation = ''.obs;
  var uom = 'Unit'.obs; // Default read-only value
  var nos = ''.obs;
  var length = ''.obs;
  var height = ''.obs;
  var remark = ''.obs;

  FieldSet();
}

class AddPboqFormController extends GetxController {
  // Reactive variables for form fields
  var selectedPackage = ''.obs;
  var selectedPboqName = ''.obs;
  var fieldSets = <FieldSet>[FieldSet()].obs; // Initialize with one empty set

  // Sample data for dropdowns (replace with actual data from your backend or API)
  final List<String> packageNames = ['Package 1', 'Package 2', 'Package 3'];
  final List<String> pboqNames = ['PBOQ A', 'PBOQ B', 'PBOQ C'];
  final List<String> zones = ['Zone 1', 'Zone 2', 'Zone 3'];
  final List<String> locations = ['Location A', 'Location B', 'Location C'];

  // Handlers for dropdown changes
  void onPackageChanged(String? value) {
    if (value != null) {
      selectedPackage.value = value;
    }
  }

  void onPboqNameChanged(String? value) {
    if (value != null) {
      selectedPboqName.value = value;
    }
  }

  void onZoneChanged(int index, String? value) {
    if (value != null) {
      fieldSets[index].selectedZone.value = value;
    }
  }

  void onLocationChanged(int index, String? value) {
    if (value != null) {
      fieldSets[index].selectedLocation.value = value;
    }
  }

  // Handlers for text field changes
  void onSubLocationChanged(int index, String value) {
    fieldSets[index].subLocation.value = value;
  }

  void onNosChanged(int index, String value) {
    fieldSets[index].nos.value = value;
  }

  void onLengthChanged(int index, String value) {
    fieldSets[index].length.value = value;
  }

  void onHeightChanged(int index, String value) {
    fieldSets[index].height.value = value;
  }

  void onRemarkChanged(int index, String value) {
    fieldSets[index].remark.value = value;
  }

  // Add a new set of fields
  void addFieldSet() {
    fieldSets.add(FieldSet());
  }

  // Refresh handler
  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    resetForm();
  }

  // Form submission logic
  void submitForm() {
    // Validate Package and PBOQ Name
    if (selectedPackage.isEmpty) {
      Get.snackbar('Error', 'Please select a package name');
      return;
    }
    if (selectedPboqName.isEmpty) {
      Get.snackbar('Error', 'Please select a PBOQ name');
      return;
    }

    // Validate each field set
    for (int i = 0; i < fieldSets.length; i++) {
      var fieldSet = fieldSets[i];
      if (fieldSet.selectedZone.isEmpty) {
        Get.snackbar('Error', 'Please select a zone for field set ${i + 1}');
        return;
      }
      if (fieldSet.selectedLocation.isEmpty) {
        Get.snackbar('Error', 'Please select a location for field set ${i + 1}');
        return;
      }
    }

    // Process form data for all field sets
    print('Form Data:');
    print('Package: ${selectedPackage.value}');
    print('PBOQ Name: ${selectedPboqName.value}');
    for (int i = 0; i < fieldSets.length; i++) {
      var fieldSet = fieldSets[i];
      print('Field Set ${i + 1}:');
      print('  Zone: ${fieldSet.selectedZone.value}');
      print('  Planning Status: ${fieldSet.planningStatus.value}');
      print('  Location: ${fieldSet.selectedLocation.value}');
      print('  Sub Location: ${fieldSet.subLocation.value}');
      print('  UOM: ${fieldSet.uom.value}');
      print('  Nos: ${fieldSet.nos.value}');
      print('  Length: ${fieldSet.length.value}');
      print('  Height: ${fieldSet.height.value}');
      print('  Remark: ${fieldSet.remark.value}');
    }

    // Reset form after submission
    resetForm();

    Get.snackbar('Success', 'Form submitted successfully');
  }

  // Reset form fields
  void resetForm() {
    selectedPackage.value = '';
    selectedPboqName.value = '';
    fieldSets.clear();
    fieldSets.add(FieldSet()); // Add one empty set to start
  }
}