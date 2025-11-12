import 'package:get/get.dart';

/// One row of the **first** table (the long one with Source, Zone, …)
class WorkFrontUpdateDetailModel {
  final String source;
  final String zone;
  final String location;
  final String subLocation;
  final String cboqCode;
  final String pboq;
  final String pboa;
  final int systemId;
  final double pboaQty;
  final double pboaAmount;
  final DateTime revisedStartDate;
  final DateTime revisedEndDate;

  WorkFrontUpdateDetailModel({
    required this.source,
    required this.zone,
    required this.location,
    required this.subLocation,
    required this.cboqCode,
    required this.pboq,
    required this.pboa,
    required this.systemId,
    required this.pboaQty,
    required this.pboaAmount,
    required this.revisedStartDate,
    required this.revisedEndDate,
  });

  // Handy for debugging / JSON conversion
  @override
  String toString() {
    return 'WorkFrontUpdateDetailModel(source: $source, zone: $zone, systemId: $systemId, pboaQty: $pboaQty, pboaAmount: $pboaAmount)';
  }
}

/// One row of the **second** table (the short measurement-sheet table)
class MeasurementSheetModel {
  final int nos;
  final double length;
  final double breadth;
  final double height;
  final double msQty;
  final String? lastUploadedFile;
  final String? progressUpdatedOn;
  final String? receivedDate;

  MeasurementSheetModel({
    required this.nos,
    required this.length,
    required this.breadth,
    required this.height,
    required this.msQty,
    this.lastUploadedFile,
    this.progressUpdatedOn,
    this.receivedDate,
  });
}