// app/data/models/work_front_update/work_front_update_model.dart
class WorkFrontUpdateModel {
  final int srNo;
  final int systemId;
  final String packageName;
  final String cboqCode;
  final String pboq;
  final String pboa;
  final int pboaQty;
  final double pboaRate;
  final String doer;
  final String uom;
  final String fix;
  final String trade;
  final String zone;

  // bottom row fields
  final double rate;
  final double amount;
  final int msQty;
  final int cumRecQty;
  final double cumRecAmount;
  final String workFrontRecAmount; // shown as % in UI

  WorkFrontUpdateModel({
    required this.srNo,
    required this.systemId,
    required this.packageName,
    required this.cboqCode,
    required this.pboq,
    required this.pboa,
    required this.pboaQty,
    required this.pboaRate,
    required this.doer,
    required this.uom,
    required this.fix,
    required this.trade,
    required this.zone,
    required this.rate,
    required this.amount,
    required this.msQty,
    required this.cumRecQty,
    required this.cumRecAmount,
    required this.workFrontRecAmount,
  });

  // Helper for copyWith (optional)
  WorkFrontUpdateModel copyWith({
    int? srNo,
    int? systemId,
    String? packageName,
    String? cboqCode,
    String? pboq,
    String? pboa,
    int? pboaQty,
    double? pboaRate,
    String? doer,
    String? uom,
    String? fix,
    String? trade,
    String? zone,
    double? rate,
    double? amount,
    int? msQty,
    int? cumRecQty,
    double? cumRecAmount,
    String? workFrontRecAmount,
  }) {
    return WorkFrontUpdateModel(
      srNo: srNo ?? this.srNo,
      systemId: systemId ?? this.systemId,
      packageName: packageName ?? this.packageName,
      cboqCode: cboqCode ?? this.cboqCode,
      pboq: pboq ?? this.pboq,
      pboa: pboa ?? this.pboa,
      pboaQty: pboaQty ?? this.pboaQty,
      pboaRate: pboaRate ?? this.pboaRate,
      doer: doer ?? this.doer,
      uom: uom ?? this.uom,
      fix: fix ?? this.fix,
      trade: trade ?? this.trade,
      zone: zone ?? this.zone,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      msQty: msQty ?? this.msQty,
      cumRecQty: cumRecQty ?? this.cumRecQty,
      cumRecAmount: cumRecAmount ?? this.cumRecAmount,
      workFrontRecAmount: workFrontRecAmount ?? this.workFrontRecAmount,
    );
  }
}