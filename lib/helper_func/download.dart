  import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      var images = await Permission.photos.request();
      var videos = await Permission.videos.request();
      var manage = await Permission.manageExternalStorage.request();
      var storage = await Permission.storage.request();

      return images.isGranted ||
          videos.isGranted ||
          manage.isGranted ||
          storage.isGranted;
    }

    return true;
  }

  Future<void> downloadExcelFile(String url, String fileName) async {
    if (await _requestPermissions()) {
      try {
        final dio = Dio();
        late String filePath;

        if (Platform.isAndroid) {
          /// Android Downloads directory
          final downloadsDir = Directory("/storage/emulated/0/Download");

          if (!downloadsDir.existsSync()) {
            downloadsDir.createSync(recursive: true);
          }

          filePath = "${downloadsDir.path}/$fileName.xlsx";
        } else if (Platform.isIOS) {
          /// iOS does not have a public Downloads folder
          final dir = await getApplicationDocumentsDirectory();
          filePath = "${dir.path}/$fileName.xlsx";
        }

        await dio.download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              log(
                "Download: ${(received / total * 100).toStringAsFixed(0)}%",
              );
            }
          },
        );

        log("File saved at: $filePath");
      } catch (e) {
        log("Error downloading file: $e");
      }
    } else {
      log("Storage permission not granted.");
    }
  }