class AccModel {
  final int srNo;
  final String accCategory;
  final String briefDetail;
  final String affectedMilestone;
  final bool keyDelayEvents;
  final String priority;
  final String issueOpenDate;
  final int overdue;
  final String delay;
  final String? issueCloseDate;
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
      srNo: map['Sr.No'] as int,
      accCategory: map['ACC Category'] as String,
      briefDetail: map['Brief Detail about Issue'] as String,
      affectedMilestone: map['Affected Milestone'] as String,
      keyDelayEvents: map['Key Delay Events'] == 'Yes',
      priority: map['Priority'] as String,
      issueOpenDate: map['Issue Open Date'] as String,
      overdue: map['overdue'] as int,
      delay: map['Delay'] as String,
      issueCloseDate: map['Issue close Date'] as String,
      role: map['Role'] as String,
      attachment: map['Attachment'] as String,
      statusUpdate: map['Status Update'] as String,
    );
  }
}
