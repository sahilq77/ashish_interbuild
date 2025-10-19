class ClientCommitmentModel {
  final int srNo;
  final String taskAssignedTo;
  final String hod;
  final String taskDetails;
  final String affectedMilestone;
  final String? priority;
  final DateTime milestoneTargetDate;
  final DateTime initialTargetDate;
  final String ccCategory;
  final int overdueDays;
  final String? delay;
  final DateTime? revisedCompletionDate;
  final DateTime? closeDate;
  final String statusUpdate;
  final String? attachment;
  final String? remark;

  ClientCommitmentModel({
    required this.srNo,
    required this.taskAssignedTo,
    required this.hod,
    required this.taskDetails,
    required this.affectedMilestone,
    this.priority,
    required this.milestoneTargetDate,
    required this.initialTargetDate,
    required this.ccCategory,
    required this.overdueDays,
    this.delay,
    this.revisedCompletionDate,
    this.closeDate,
    required this.statusUpdate,
    this.attachment,
    this.remark,
  });
}