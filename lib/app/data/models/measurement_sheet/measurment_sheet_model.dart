// measurement_sheet_model.dart
class MeasurementSheet {
  final String packageName;
  final String cboqName;
  final String msQty;
  final String pboqName;
  final String zones;
  final String uom;
  final String pboqQty;

  MeasurementSheet({
    required this.packageName,
    required this.cboqName,
    required this.msQty,
    required this.pboqName,
    required this.zones,
    required this.uom,
    required this.pboqQty,
  });
}
