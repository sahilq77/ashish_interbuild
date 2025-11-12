import 'package:get/get.dart';

class ClientCommitmentDashboardController extends GetxController {
  // Reactive variables for dashboard data
  final monthlyTarget = RxDouble(0.0);
  final monthlyAchieve = RxDouble(0.0);
  final monthlyPercent = RxDouble(0.0);

  final weeklyTarget = RxDouble(0.0);
  final weeklyAchieve = RxDouble(0.0);
  final weeklyPercent = RxDouble(0.0);

  final dailyTarget = RxDouble(0.0);
  final dailyAchieve = RxDouble(0.0);
  final dailyPercent = RxDouble(0.0);

  @override
  void onInit() {
    super.onInit();
    // Initialize with sample data (replace with actual data source)
    fetchDashboardData();
  }

  Future<void> refreshData() async {
    // Simulate a network delay for refresh
    await Future.delayed(const Duration(seconds: 1));
    fetchDashboardData();
  }

  void fetchDashboardData() {
    // Simulate fetching data (replace with actual API or database calls)
    monthlyTarget.value = 1000000.0; // Example: ₹10,00,000
    monthlyAchieve.value = 750000.0; // Example: ₹7,50,000
    monthlyPercent.value = calculatePercentage(
      monthlyAchieve.value,
      monthlyTarget.value,
    );

    weeklyTarget.value = 250000.0; // Example: ₹2,50,000
    weeklyAchieve.value = 200000.0; // Example: ₹2,00,000
    weeklyPercent.value = calculatePercentage(
      weeklyAchieve.value,
      weeklyTarget.value,
    );

    dailyTarget.value = 50000.0; // Example: ₹50,000
    dailyAchieve.value = 45000.0; // Example: ₹45,000
    dailyPercent.value = calculatePercentage(
      dailyAchieve.value,
      dailyTarget.value,
    );
  }

  double calculatePercentage(double achieved, double target) {
    if (target == 0) return 0.0;
    return (achieved / target * 100).toDouble();
  }

  // Format currency for display
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Format percentage for display
  String formatPercentage(double percent) {
    return '${percent.toStringAsFixed(2)}%';
  }
}
