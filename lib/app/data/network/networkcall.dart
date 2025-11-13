import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:ashishinterbuild/app/data/models/global_model/pboq/get_pboq_name_response.dart';
import 'package:ashishinterbuild/app/data/models/global_model/zone/get_zone_locations_response.dart';
import 'package:ashishinterbuild/app/data/models/global_model/zone/get_zone_response.dart';
import 'package:ashishinterbuild/app/data/models/login/get_login_response.dart';
import 'package:ashishinterbuild/app/data/models/global_model/packages/get_package_name_response.dart';
import 'package:ashishinterbuild/app/data/models/profile/get_profile_response.dart';
import 'package:ashishinterbuild/app/data/models/project_name/get_project_name_response.dart';
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
  static void clearBearerToken() {
    _bearerToken = null;
    log('Bearer token cleared');
  }

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
      if (_bearerToken != null && _bearerToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_bearerToken';
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
      if (response.statusCode == 200) {
        log(
          "POST → $url \nRequestCode: $requestCode \nBody: $body \nResponse: $data",
        );

        // Wrap in array for the existing parsers
        final str = "[${response.body}]";

        switch (requestCode) {
          case 1:
            final login = getLoginResponseFromJson(str);
            return login;

          default:
            log("Invalid request code: $requestCode");
            throw ParseException('Unhandled request code: $requestCode');
        }
      } else if (response.statusCode == 401) {
        await AppUtility.clearUserInfo();
        Get.offAllNamed(AppRoutes.login);

        log("POST → $url \nStatus: ${response.statusCode} \nResponse: $data");
      } else {
        throw HttpException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on NoInternetException catch (e) {
      log("POST → $url \nError: $e");
      await _navigateToNoInternet();
      return null;
    } on TimeoutException catch (e) {
      log("POST → $url \nError: $e");
      AppSnackbarStyles.showError(
        title: 'Request Timed Out',
        message: 'The server took too long to respond. Please try again.',
      );
      return null;
    } on HttpException catch (e) {
      log("POST → $url \nError: $e");
      return null;
    } on SocketException catch (e) {
      log("POST → $url \nError: $e");
      await _navigateToNoInternet();
      return null;
    } catch (e) {
      log("POST → $url \nUnexpected: $e");
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
