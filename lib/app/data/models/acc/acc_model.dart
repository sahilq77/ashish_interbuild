class AccModel {
  final int srNo;
  final String accCategory;
  final String briefDetail;
  final String affectedMilestone;
  final bool keyDelayEvents;
  final String priority;
  final DateTime issueOpenDate;
  final int overdue;
  final String delay;
  final DateTime? issueCloseDate;
  final String role;
  final String attachment;
  final String statusUpdate;

  AccModel({
    required this.srNo,
    required this.accCategory,
    required this.briefDetail,
    required this.affectedMilestone,
    required this.keyDelayEvents,
    required this.priority,
    required this.issueOpenDate,
    required this.overdue,
    required this.delay,
    this.issueCloseDate,
    required this.role,
    required this.attachment,
    required this.statusUpdate,
  });

  factory AccModel.fromMap(Map<String, dynamic> map) {
    return AccModel(
      srNo: map['Sr.No'] ?? 0,
      accCategory: map['ACC Category'] ?? '',
      briefDetail: map['Brief Detail about Issue'] ?? '',
      affectedMilestone: map['Affected Milestone'] ?? '',
      keyDelayEvents: map['Key Delay Events'] == 'Yes',
      priority: map['Priority'] ?? '',
      issueOpenDate: DateTime.parse(map['Issue Open Date'] ?? ''),
      overdue: map['overdue'] ?? 0,
      delay: map['Delay'] ?? '',
      issueCloseDate: map['Issue close Date'] != null
          ? DateTime.parse(map['Issue close Date'])
          : null,
      role: map['Role'] ?? '',
      attachment: map['Attachment'] ?? '',
      statusUpdate: map['Status Update'] ?? '',
    );
  }
}