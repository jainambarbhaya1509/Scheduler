import "package:schedule/imports.dart";

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

Future<void> downloadExcelFileApp(String fileName) async {

  // Load asset template
  final byteData = await rootBundle.load('assets/template.xlsx');
  final bytes = byteData.buffer.asUint8List();

  if (!await _requestPermissions()) {
    logger.d("Storage permission not granted.");
    return;
  }

  late String filePath;

  if (Platform.isAndroid) {
    final downloadsDir = Directory("/sdcard/Download");
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }
    filePath = "${downloadsDir.path}/$fileName";
  } else if (Platform.isIOS) {
    final dir = await getApplicationDocumentsDirectory();
    filePath = "${dir.path}/$fileName";
  } else {
    throw UnsupportedError("Unsupported platform");
  }

  await File(filePath).writeAsBytes(bytes);
  logger.d("Template saved at: $filePath");
}
