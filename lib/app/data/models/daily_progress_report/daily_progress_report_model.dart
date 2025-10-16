// measurement_sheet_model.dart
class DailyProgressReportModel {
  final String packageName;
  final String cboqName;
  final String msQty;
  final String pboqName;
  final String zones;
  final String uom;
  final String pboqQty;
  final String pboa;
  final String todaysTargetPboaQuantity;
  final String todaysAchieveQuantity;
   final String pboaQuantity;
  DailyProgressReportModel({
    required this.packageName,
    required this.cboqName,
    required this.msQty,
    required this.pboqName,
    required this.zones,
    required this.uom,
    required this.pboqQty,
    required this.pboa,
    required this.todaysTargetPboaQuantity,
    required this.todaysAchieveQuantity,
    required this.pboaQuantity,
  });
}
