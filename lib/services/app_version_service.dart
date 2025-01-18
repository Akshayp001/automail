import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:install_plugin/install_plugin.dart';
import 'dart:io';

class AppVersion {
  final String version;
  final int versionCode;
  final String name;
  final DateTime releaseDate;
  final String appUrl;
  final String description;
  final bool forceUpdate;

  AppVersion({
    required this.version,
    required this.versionCode,
    required this.name,
    required this.releaseDate,
    required this.appUrl,
    required this.description,
    required this.forceUpdate,
  });

  factory AppVersion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppVersion(
      version: data['version'] ?? '',
      versionCode: data['versionCode'] ?? 0,
      name: data['name'] ?? '',
      releaseDate: (data['releaseDate'] as Timestamp).toDate(),
      appUrl: data['appUrl'] ?? '',
      description: data['description'] ?? '',
      forceUpdate: data['forceUpdate'] ?? false,
    );
  }
}

class AppVersionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Dio _dio = Dio();

  static Future<void> checkForUpdates() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final int currentVersionCode = int.parse(packageInfo.buildNumber);

      final QuerySnapshot snapshot = await _firestore
          .collection('appVersion')
          .orderBy('versionCode', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return;

      final AppVersion latestVersion =
          AppVersion.fromFirestore(snapshot.docs.first);

      if (latestVersion.versionCode > currentVersionCode) {
        _showUpdateDialog(latestVersion);
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  static void _showUpdateDialog(AppVersion version) {
    final RxDouble downloadProgress = 0.0.obs;
    final RxBool isDownloading = false.obs;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => !version.forceUpdate && !isDownloading.value,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with version info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.system_update,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Version Available',
                              style: Get.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Version ${version.version} (${version.versionCode})',
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Release date and description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Released on ${_formatDate(version.releaseDate)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          version.description,
                          style: Get.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Download progress
                  if (isDownloading.value) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: downloadProgress.value,
                        backgroundColor: Colors.grey[200],
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Downloading: ${(downloadProgress.value * 100).toInt()}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!version.forceUpdate && !isDownloading.value)
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'Later',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isDownloading.value
                            ? null
                            : () => _downloadAndInstall(
                                  version,
                                  downloadProgress,
                                  isDownloading,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isDownloading.value ? 'Downloading...' : 'Update Now',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: !version.forceUpdate,
    );
  }

  static Future<void> _downloadAndInstall(
    AppVersion version,
    RxDouble progress,
    RxBool isDownloading,
  ) async {
    try {
      isDownloading.value = true;
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/app-update.apk';

      await _dio.download(
        version.appUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            progress.value = received / total;
          }
        },
      );

      // Install the APK
      await InstallPlugin.installApk(filePath);

      // Clean up the downloaded file
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      isDownloading.value = false;
      Get.back();
    } catch (e) {
      isDownloading.value = false;
      Get.snackbar(
        'Error',
        'Failed to download update. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('Download error: $e');
    }
  }

  static String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
