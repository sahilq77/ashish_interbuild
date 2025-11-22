import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:ashishinterbuild/app/data/models/add_pboq_measurment/get_add_pboq_measurment_response.dart';
import 'package:ashishinterbuild/app/data/models/add_pboq_measurment/get_planning_status_response.dart';
import 'package:ashishinterbuild/app/data/models/daily_progress_report/get_dashboard_response.dart';
import 'package:ashishinterbuild/app/data/models/daily_progress_report/get_dpr_list_response.dart';
import 'package:ashishinterbuild/app/data/models/daily_progress_report/get_update_dpr_list_response.dart';
import 'package:ashishinterbuild/app/data/models/global_model/pboq/get_pboq_name_response.dart';
import 'package:ashishinterbuild/app/data/models/global_model/week_periods/get_week_periods_response.dart';
import 'package:ashishinterbuild/app/data/models/global_model/zone/get_zone_locations_response.dart';
import 'package:ashishinterbuild/app/data/models/global_model/zone/get_zone_response.dart';
import 'package:ashishinterbuild/app/data/models/login/get_login_response.dart';
import 'package:ashishinterbuild/app/data/models/global_model/packages/get_package_name_response.dart';
import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_add_deduction_response.dart';
import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_delete_measurement_sheet_response.dart';
import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_edit_pboq_response.dart';
import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_pboq_list_response.dart';
import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_pboq_measurmentsheet_response.dart';
import 'package:ashishinterbuild/app/data/models/profile/get_profile_response.dart';
import 'package:ashishinterbuild/app/data/models/project_name/get_project_name_response.dart';
import 'package:ashishinterbuild/app/data/models/weekly_inspection/get_weekly_inspection_response.dart';
import 'package:ashishinterbuild/app/data/models/weekly_inspection/get_weekly_inspection_update_list_response.dart';
import 'package:ashishinterbuild/app/data/models/work_front_update/get_work_front_dashboard_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/utils/app_utility.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:ashishinterbuild/app/widgets/connctivityservice.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../routes/app_routes.dart';

class Networkcall {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  // ---------- Bearer Token Management ----------
  static String? _bearerToken;

  /// Set the bearer token (call after successful login / token refresh)
  static void setBearerToken(String token) {
    _bearerToken = token;
    log('Bearer token set');
  }

  /// Clear the token (call on logout)
  // static void clearBearerToken() {
  //   _bearerToken = null;
  //   log('Bearer token cleared');
  // }

  // ---------- Slow-Internet Snackbar ----------
  static GetSnackBar? _slowInternetSnackBar;
  static const int _minResponseTimeMs = 3000; // 3 seconds
  static bool _isNavigatingToNoInternet = false;

  // -------------------------------------------------
  Future<List<Object?>?> postMethod(
    int requestCode,
    String url,
    String body,
    BuildContext context,
  ) async {
    try {
      // ---- Connectivity check ----
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _navigateToNoInternet();
        return null;
      }

      // ---- Response timer ----
      final stopwatch = Stopwatch()..start();

      // ---- Build headers (add Bearer if present) ----
      final Map<String, String> headers = {'Content-Type': 'application/json'};
      if (AppUtility.authToken != null && AppUtility.authToken!.isNotEmpty) {
        log("Bearer Token: ${AppUtility.authToken}");
        headers['Authorization'] = 'Bearer ${AppUtility.authToken}';
      }

      // ---- POST request ----
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body.isEmpty ? null : body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Request timed out. Please try again.'),
          );

      stopwatch.stop();
      _handleSlowInternet(stopwatch.elapsedMilliseconds);

      final data = response.body;

      // ---- Log headers in all cases ----
      final headersLog = headers.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');

      if (response.statusCode == 200) {
        log(
          "POST → $url\n"
          "RequestCode: $requestCode\n"
          "Headers:\n$headersLog\n"
          "Body: $body\n"
          "Response: $data",
        );

        switch (requestCode) {
          case 1:
            final str = "[${response.body}]";
            final login = getLoginResponseFromJson(str);
            return login;
          case 11:
            final str = "[${response.body}]";
            final addPboqMeasurment = getAddPboqMsResponseFromJson(str);
            return addPboqMeasurment;

          // case 11:
          //   final parsed = json.decode(response.body) as Map<String, dynamic>;
          //   final addPboqMeasurment = [GetAddPboqMsResponse.fromJson(parsed)];
          case 12:
            final str = "[${response.body}]";
            final getPlanningStatus = getPlanningStatusResponseFromJson(str);
            return getPlanningStatus;
          case 13:
            final str = "[${response.body}]";
            final editPboq = getEditPboqMeasurmentResponseFromJson(str);
            return editPboq;
          case 14:
            final str = "[${response.body}]";
            final deleteMS = getDeleteMeasurmentResponseFromJson(str);
            return deleteMS;
          case 16:
            final str = "[${response.body}]";
            final deleteMS = getAddDeductionResponseFromJson(str);
            return deleteMS;

          default:
            log("Invalid request code: $requestCode");
            throw ParseException('Unhandled request code: $requestCode');
        }
      } else if (response.statusCode == 401) {
        log(
          "POST → $url\n"
          "RequestCode: $requestCode\n"
          "Headers:\n$headersLog\n"
          "Body: $body\n"
          "Response: $data\n"
          "Status: 401 Unauthorized",
        );
        // await AppUtility.clearUserInfo();
        // Get.offAllNamed(AppRoutes.login);
      } else {
        throw HttpException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on NoInternetException catch (e) {
      final headersLog = {
        'Content-Type': 'application/json',
        if (_bearerToken != null && _bearerToken!.isNotEmpty)
          'Authorization': 'Bearer $_bearerToken',
      }.entries.map((e) => '${e.key}: ${e.value}').join('\n');

      log("POST → $url\nHeaders:\n$headersLog\nError: $e");
      await _navigateToNoInternet();
      return null;
    } on TimeoutException catch (e) {
      final headersLog = {
        'Content-Type': 'application/json',
        if (_bearerToken != null && _bearerToken!.isNotEmpty)
          'Authorization': 'Bearer $_bearerToken',
      }.entries.map((e) => '${e.key}: ${e.value}').join('\n');

      log("POST → $url\nHeaders:\n$headersLog\nError: $e");
      AppSnackbarStyles.showError(
        title: 'Request Timed Out',
        message: 'The server took too long to respond. Please try again.',
      );
      return null;
    } on HttpException catch (e) {
      final headersLog = {
        'Content-Type': 'application/json',
        if (_bearerToken != null && _bearerToken!.isNotEmpty)
          'Authorization': 'Bearer $_bearerToken',
      }.entries.map((e) => '${e.key}: ${e.value}').join('\n');

      log("POST → $url\nHeaders:\n$headersLog\nError: $e");
      return null;
    } on SocketException catch (e) {
      final headersLog = {
        'Content-Type': 'application/json',
        if (_bearerToken != null && _bearerToken!.isNotEmpty)
          'Authorization': 'Bearer $_bearerToken',
      }.entries.map((e) => '${e.key}: ${e.value}').join('\n');

      log("POST → $url\nHeaders:\n$headersLog\nError: $e");
      await _navigateToNoInternet();
      return null;
    } catch (e) {
      final headersLog = {
        'Content-Type': 'application/json',
        if (_bearerToken != null && _bearerToken!.isNotEmpty)
          'Authorization': 'Bearer $_bearerToken',
      }.entries.map((e) => '${e.key}: ${e.value}').join('\n');

      log("POST → $url\nHeaders:\n$headersLog\nUnexpected: $e");
      return null;
    }
  }

  // -------------------------------------------------
  Future<List<Object?>?> getMethod(
    int requestCode,
    String url,
    BuildContext context,
  ) async {
    try {
      // ---- Connectivity check ----
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _navigateToNoInternet();
        return null;
      }

      // ---- Response timer ----
      final stopwatch = Stopwatch()..start();

      // ---- Build headers (add Bearer if present) ----
      final Map<String, String> headers = {};
      if (AppUtility.authToken != null && AppUtility.authToken!.isNotEmpty) {
        log("Bearer Token: ${AppUtility.authToken}");
        headers['Authorization'] = 'Bearer ${AppUtility.authToken}';
      }

      // ---- GET request ----
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Request timed out. Please try again.'),
          );

      stopwatch.stop();
      _handleSlowInternet(stopwatch.elapsedMilliseconds);

      final data = response.body;
      log("GET → $url");

      if (response.statusCode == 200) {
        log("GET → $url \nResponse: $data");

        final str = "[${response.body}]";

        switch (requestCode) {
          case 2:
            final getProfile = getUserProfileResponseFromJson(str);
            return getProfile;

          case 4:
            final getProjects = getProjectNameResponseFromJson(str);
            return getProjects;
          case 5:
            final getPackages = getPackageNameResponseFromJson(str);
            return getPackages;
          case 6:
            final getPboq = getPboqNameResponseFromJson(str);
            return getPboq;
          case 7:
            final getZone = getZoneResponseFromJson(str);
            return getZone;
          case 8:
            final getZoneLocations = getZoneLocationsResponseFromJson(str);
            return getZoneLocations;
          case 9:
            final getPboqList = getPboqListResponseFromJson(str);
            return getPboqList;
          case 10:
            final getPboqMeasurementSheetList =
                getPboqMeasurementsheetResponseFromJson(str);
            return getPboqMeasurementSheetList;

          case 15:
            final getPboqList = getPboqListResponseFromJson(str);
            return getPboqList;
          case 17:
            final getDPRdashboard = getDashboardResponseFromJson(str);
            return getDPRdashboard;
          case 18:
            final getDPRList = getDprListResponseFromJson(response.body);
            return [getDPRList];
          case 19:
            final getDprReportDetailList = getUpdateDprListResponseFromJson(
              response.body,
            );
            return [getDprReportDetailList];
          case 22:
            final getWirdashboard = getWeeeklyDashboardResponseFromJson(str);
            return getWirdashboard;
          case 23:
            final getWirList = getDprListResponseFromJson(response.body);
            return [getWirList];
          case 24:
            final getWeeklyPeriod = getWeeklyPeriodsResponseFromJson(str);
            return getWeeklyPeriod;
          // case 24:
          //   final getWeeklyPeriod = getWeeklyPeriodsResponseFromJson(str);
          //   return getWeeklyPeriod;
          case 25:
            final getWIRDetailList =
                getUpdateWeeklyInspectionListResponseFromJson(response.body);
            return [getWIRDetailList];
          case 27:
            final getWFdashboard = geWorkFrontDashboardResponseFromJson(str);
            return getWFdashboard;

          default:
            log("Invalid request code: $requestCode");
            throw ParseException('Unhandled request code: $requestCode');
        }
      } else if (response.statusCode == 401) {
        await AppUtility.clearUserInfo();
        Get.offAllNamed(AppRoutes.login);
        log("GET → $url \nStatus: ${response.statusCode} \nResponse: $data");
      } else {
        throw HttpException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on NoInternetException catch (e) {
      log("GET → $url \nError: $e");
      await _navigateToNoInternet();
      return null;
    } on TimeoutException catch (e) {
      log("GET → $url \nError: $e");
      AppSnackbarStyles.showError(
        title: 'Request Timed Out',
        message: 'The server took too long to respond. Please try again.',
      );
      return null;
    } on HttpException catch (e) {
      log("GET → $url \nError: $e");
      return null;
    } on SocketException catch (e) {
      log("GET → $url \nError: $e");
      await _navigateToNoInternet();
      return null;
    } catch (e) {
      log("GET → $url \nUnexpected: $e");
      return null;
    }
  }

  // -------------------------------------------------
  Future<void> _navigateToNoInternet() async {
    if (!_isNavigatingToNoInternet &&
        Get.currentRoute != AppRoutes.noInternet) {
      _isNavigatingToNoInternet = true;

      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await Get.offNamed(AppRoutes.noInternet);
      }

      await Future.delayed(const Duration(milliseconds: 500));
      _isNavigatingToNoInternet = false;
    }
  }

  // -------------------------------------------------
  void _handleSlowInternet(int responseTimeMs) {
    if (responseTimeMs > _minResponseTimeMs) {
      if (_slowInternetSnackBar == null || !Get.isSnackbarOpen) {
        _slowInternetSnackBar = GetSnackBar(
          titleText: Text(
            'Slow Internet',
            style: AppStyle.heading1PoppinsWhite,
          ),
          messageText: Text(
            'Slow internet connection detected. Please check your network.',
            style: AppStyle.subheading1PoppinsWhite,
          ),
          duration: const Duration(days: 1),
          backgroundColor: Colors.orange.shade600,
          snackPosition: SnackPosition.TOP,
          isDismissible: false,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
          icon: const Icon(
            Icons.warning_rounded,
            color: Colors.white,
            size: 28,
          ),
          shouldIconPulse: true,
        );
        Get.showSnackbar(_slowInternetSnackBar!);
      }
    } else {
      if (_slowInternetSnackBar != null && Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
        _slowInternetSnackBar = null;
      }
    }
  }
}
