import 'dart:io';

import 'package:ashishinterbuild/app/modules/global_controller/acc_category/acc_category_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/doer_role/doer_role_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/milestone/milestone_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/project_name/project_name_dropdown_controller.dart';
import 'package:ashishinterbuild/app/modules/home/acc/add_acc/add_acc_form_controller.dart';
import 'package:ashishinterbuild/app/modules/home/acc/edit_acc/edit_acc_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/date_formater.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart'
    show AppSnackbarStyles;
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class EditAccFormView extends StatefulWidget {
  const EditAccFormView({super.key});

  @override
  State<EditAccFormView> createState() => _EditAccFormViewState();
}

class _EditAccFormViewState extends State<EditAccFormView> {
  final projectdController = Get.find<ProjectNameDropdownController>();
  final packageNameController = Get.find<PackageNameController>();
  final accCategoryController = Get.find<AccCategoryController>();
  final doerRoleController = Get.find<DoerRoleController>();
  final milestoneController = Get.find<MilestoneController>();
  @override
  Widget build(BuildContext context) {
    final EditAccController controller = Get.put(EditAccController());
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppbar(),
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          padding: ResponsiveHelper.padding(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => _buildDropdownField(
                  label: 'Project *',
                  value: controller.selectedProject.value,
                  items: projectdController.projectNames,
                  onChanged: controller.onProjectChanged,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select an Project'
                      : null,
                  hint: 'Select Project',
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Obx(
                () => _buildDropdownField(
                  label: 'Package *',
                  value: controller.selectedPackage.value,
                  items: packageNameController.packageNames,
                  onChanged: controller.onPackageChanged,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select an Package'
                      : null,
                  hint: 'Select Package',
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Obx(
                () => _buildDropdownField(
                  label: 'ACC Category *',
                  value: controller.accCategory.value,
                  items: accCategoryController.accCategoryNames,
                  onChanged: controller.onAccCategoryChanged,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select an ACC category'
                      : null,
                  hint: 'Select Category',
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Obx(
                () => _buildDropdownField(
                  label: 'Priority',
                  value: controller.priority.value,
                  items: controller.priorities,
                  onChanged: controller.onPriorityChanged,
                  hint: 'Select Priority',
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Obx(
                () => _buildDropdownField(
                  label: 'Key Delay Events',
                  value: controller.keyDelayEvents.value,
                  items: controller.keyDelayOptions,
                  onChanged: controller.onKeyDelayEventsChanged,
                  hint: 'Plese Select Yes/No',
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Obx(
                () => _buildDropdownField(
                  label: 'Affected Milestone *',
                  value: controller.affectedMilestone.value,
                  items: milestoneController.milestoneNames,
                  onChanged: controller.onAffectedMilestoneChanged,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select an affected milestone'
                      : null,
                  hint: 'Select Milestone',
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildTextFormField(
                label: 'Brief Details *',
                controller: controller.briefDetails,
                onChanged: controller.onBriefDetailsChanged,
                hint: 'Detail',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter brief details'
                    : null,
              ),

              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Obx(
                () => _buildDateField(
                  label: 'Issue Open Date *',
                  selectedDate: controller.issueOpenDate.value,
                  onDateChanged: controller.onIssueOpenDateChanged,
                  hint: 'Enter Date',
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Obx(
                () => _buildDropdownField(
                  label: 'Role *',
                  value: controller.role.value,
                  items: doerRoleController.doerRoleNames,
                  onChanged: controller.onRoleChanged,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a role'
                      : null,
                  hint: 'Select Doer',
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Obx(
                () => _buildAttachmentField(
                  label: 'Attachment',
                  fileName: controller.attachmentFileName.value,
                  onAttachmentPicked: controller.pickAttachment,
                  hint: 'Choose File',
                  attachmentLink: controller.attchmentLink.value,
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.05),
              ElevatedButton(
                onPressed: () => controller.submitForm(context),
                style: AppButtonStyles.elevatedLargeBlack(),
                child: Text(
                  'Submit',
                  style: AppStyle.buttonTextPoppinsWhite.responsive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?)? onChanged,
    String? Function(String?)? validator,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        DropdownSearch<String>(
          selectedItem: value.isNotEmpty ? value : null,
          items: items,
          onChanged: onChanged,
          validator: validator,
          enabled: onChanged != null,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          popupProps: const PopupProps.menu(
            showSearchBox: true,
            showSelectedItems: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    required Function(String)? onChanged,
    required String hint,
    String? Function(String?)? validator,
    required TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime)? onDateChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: Get.context!,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null && pickedDate != selectedDate) {
              onDateChanged?.call(pickedDate);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(
                text: DateFormater.formatDate(selectedDate.toString()),
              ),
              decoration: InputDecoration(
                hintText: hint,
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentField({
    required String label,
    required String fileName,
    required Function() onAttachmentPicked,
    required String hint,
    String? attachmentLink,
  }) {
    print(fileName);
    TextEditingController fcontroller = TextEditingController(text: fileName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppStyle.reportCardRowCount.responsive,
                overflow: TextOverflow.ellipsis, // good for long labels
              ),
            ),

            // Small download button - only as wide as its content
            if (attachmentLink != null && attachmentLink.contains('https'))
              ElevatedButton(
                style: AppButtonStyles.elevatedSmallBlack().copyWith(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.all(8),
                  ), // optional: make it even tighter
                  minimumSize: WidgetStateProperty.all(
                    Size(
                      ResponsiveHelper.spacing(40),
                      ResponsiveHelper.spacing(40),
                    ),
                  ), // square & compact
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // reduces extra padding
                ),
                onPressed: attachmentLink != null
                    ? () {
                        final fileName =
                            attachmentLink +
                            DateTime.now()
                                .toString()
                                .split('/')
                                .last
                                .split('?')
                                .first;
                        _downloadFile(
                          url: attachmentLink,
                          originalFileName: fileName,
                        );
                      }
                    : null, // disables button if no link
                child: const Icon(Icons.download, size: 20),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onAttachmentPicked,
          child: AbsorbPointer(
            child: TextFormField(
              controller: fcontroller,
              decoration: InputDecoration(
                hintText: hint,
                suffixIcon: const Icon(Icons.attach_file),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Edit ACC Issue Form',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }

  Future<bool> _requestImageDownloadPermission() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    Permission permission;
    if (androidInfo.version.sdkInt >= 33) {
      // Android 13+ → Use Photos permission for images
      permission = Permission.photos;
    } else {
      // Older Android → Use storage
      permission = Permission.storage;
    }

    var status = await permission.status;

    if (status.isDenied) {
      status = await permission.request();
    }

    if (status.isPermanentlyDenied) {
      // Fluttertoast.showToast(
      //   msg: "Please allow photos/storage access in Settings → Apps → Your App",
      //   toastLength: Toast.LENGTH_LONG,
      // );
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  Future<void> _downloadFile({
    required String url,
    required String
    originalFileName, // Optional: can help detect type if URL lacks extension
  }) async {
    try {
      // 1. Request permission (improved for Android 13+ scoped storage)
      if (!await _requestImageDownloadPermission()) {
        AppSnackbarStyles.showError(
          title: "Permission Denied",
          message: "Storage permission required to save files",
        );
        return;
      }

      // 2. Determine save directory (best practice per platform)
      Directory? directory;
      if (Platform.isAndroid) {
        // Try Downloads folder first (recommended)
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = Directory(
            '/storage/emulated/0/Downloads',
          ); // Some devices use capital D
        }
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null || !await directory.exists()) {
        AppSnackbarStyles.showError(
          title: "Error",
          message: "Cannot access storage directory",
        );
        return;
      }

      // 3. Extract file extension intelligently
      String extension = '.bin'; // fallback
      String fileNameWithoutExt =
          'File_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';

      // Try from URL first
      final uri = Uri.tryParse(url);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        String lastSegment = uri.pathSegments.last;
        // Handle URLs with query params like: image.jpg?token=abc
        if (lastSegment.contains('.')) {
          lastSegment = lastSegment.split('?').first;
        }
        final dotIndex = lastSegment.lastIndexOf('.');
        if (dotIndex != -1 && dotIndex < lastSegment.length - 1) {
          extension = lastSegment.substring(dotIndex); // e.g., ".pdf"
        }
      }

      // Fallback: try from originalFileName or Content-Type later via header
      if ((extension == '.bin' ||
              ![
                '.pdf',
                '.xlsx',
                '.doc',
                '.docx',
                '.jpg',
                '.jpeg',
                '.png',
                '.gif',
                '.webp',
              ].contains(extension.toLowerCase())) &&
          originalFileName.isNotEmpty) {
        final dotIndex = originalFileName.lastIndexOf('.');
        if (dotIndex != -1) {
          final candidateExt = originalFileName
              .substring(dotIndex)
              .toLowerCase();
          if ([
            '.pdf',
            '.xlsx',
            '.doc',
            '.docx',
            '.jpg',
            '.jpeg',
            '.png',
            '.gif',
            '.webp',
          ].contains(candidateExt)) {
            extension = candidateExt;
          }
        }
      }

      // Final filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${fileNameWithoutExt}_$timestamp$extension';
      final savePath = '${directory.path}/$fileName';

      // 4. Download with Dio
      final dio = Dio();

      // Optional: Set headers if needed (e.g., for auth)
      // dio.options.headers['Authorization'] = 'Bearer ...';

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            Fluttertoast.cancel(); // Avoid toast spam
            Fluttertoast.showToast(
              msg: "Downloading $extension file: $progress%",
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        },
      );

      // 5. Verify file was saved
      final file = File(savePath);
      if (await file.exists() && await file.length() > 100) {
        // >100 bytes to avoid empty/corrupt
        AppSnackbarStyles.showSuccess(
          title: "Downloaded!",
          message: "Saved as $fileName",
        );

        // Optional: Notify Android gallery/media scanner (for images/PDFs)
        if (Platform.isAndroid) {
          try {
            // await _addToGallery(fileName, savePath, extension);
          } catch (e) {
            debugPrint("Failed to refresh gallery: $e");
          }
        }
      } else {
        throw Exception("Downloaded file is empty or corrupt");
      }
    } catch (e) {
      debugPrint("Download error: $e");
      AppSnackbarStyles.showError(
        title: "Download Failed",
        message: e.toString().contains("empty")
            ? "File is empty or corrupted"
            : "Could not download file",
      );
    }
  }
}
