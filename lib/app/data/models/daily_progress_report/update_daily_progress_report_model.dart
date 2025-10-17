class UpdateDailyProgressReportModel {
  final String srNo;
  final String systemId;
  final String source;
  final String zone;
  final String location;
  final String subLocation;
  final String cboqCode;
  final String pboq;
  final String pboa;
  final String pboaQty;
  final String pboaAmount;
  final String revisedStartDate;
  final String revisedEndDate;
  final String length;
  final String breadth;
  final String height;
  final String msQty;
  final String uploadedFile;
  final String progress;
  final String execution;
  final String updatedOn;

  UpdateDailyProgressReportModel({
    required this.srNo,
    required this.systemId,
    required this.source,
    required this.zone,
    required this.location,
    required this.subLocation,
    required this.cboqCode,
    required this.pboq,
    required this.pboa,
    required this.pboaQty,
    required this.pboaAmount,
    required this.revisedStartDate,
    required this.revisedEndDate,
    required this.length,
    required this.breadth,
    required this.height,
    required this.msQty,
    required this.uploadedFile,
    required this.progress,
    required this.execution,
    required this.updatedOn,
  });
}