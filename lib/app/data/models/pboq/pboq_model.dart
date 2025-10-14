class PboqModel {
  final String systemId;
  final String source;
  final String cboqCode;
  final String pboq;
  final String pboa;
  final String zone;
  final String location;
  final String subLocation;
  final String uom;
  final int nos;
  final double length;
  final double breadth;
  final double height;
  final double deduction;
  final int msQty;
  final String remark;
  final DateTime updatedOn;
  final String packageName;
  final String cboqName;
  final String pboqQty;

  PboqModel({
    required this.systemId,
    required this.source,
    required this.cboqCode,
    required this.pboq,
    required this.pboa,
    required this.zone,
    required this.location,
    required this.subLocation,
    required this.uom,
    required this.nos,
    required this.length,
    required this.breadth,
    required this.height,
    required this.deduction,
    required this.msQty,
    required this.remark,
    required this.updatedOn,
    required this.packageName,
    required this.cboqName,
    required this.pboqQty,
  });

  // Optional: Add a method to convert to JSON if needed
  Map<String, dynamic> toJson() {
    return {
      'systemId': systemId,
      'source': source,
      'cboqCode': cboqCode,
      'pboq': pboq,
      'pboa': pboa,
      'zone': zone,
      'location': location,
      'subLocation': subLocation,
      'uom': uom,
      'nos': nos,
      'length': length,
      'breadth': breadth,
      'height': height,
      'deduction': deduction,
      'msQty': msQty,
      'remark': remark,
      'updatedOn': updatedOn.toIso8601String(),
      'packageName': packageName,
      'cboqName': cboqName,
      'pboqQty': pboqQty,
    };
  }

  // Optional: Add a factory constructor to create from JSON if needed
  factory PboqModel.fromJson(Map<String, dynamic> json) {
    return PboqModel(
      systemId: json['systemId'],
      source: json['source'],
      cboqCode: json['cboqCode'],
      pboq: json['pboq'],
      pboa: json['pboa'],
      zone: json['zone'],
      location: json['location'],
      subLocation: json['subLocation'],
      uom: json['uom'],
      nos: json['nos'],
      length: json['length'],
      breadth: json['breadth'],
      height: json['height'],
      deduction: json['deduction'],
      msQty: json['msQty'],
      remark: json['remark'],
      updatedOn: DateTime.parse(json['updatedOn']),
      packageName: json['packageName'],
      cboqName: json['cboqName'],
      pboqQty: json['pboqQty'],
    );
  }
}