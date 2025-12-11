// ================= Dart Core Libraries =================
export 'dart:async';
export 'dart:io' show File, Directory, Platform;
export 'dart:math';
export 'dart:js_interop';

// ================= Flutter Pages =================
export 'package:schedule/pages/home.dart';


// ================= Flutter Packages =================

export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:path_provider/path_provider.dart';
export 'package:permission_handler/permission_handler.dart';

// ================= Web Packages =================
export 'package:logger/logger.dart';
export 'initializations.dart';

// ================= State Management =================
export 'package:get/get.dart';

// ================= Firebase / Firestore =================
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:schedule/services/firestore_service.dart';
export 'package:schedule/utils/firestore_helpers.dart';

// ================= Helpers / Utils =================
export 'package:schedule/helper/logic/check_interval.dart';
export 'package:schedule/helper/logic/n_hrs_slot.dart';
export 'package:schedule/utils/slot_helpers.dart';
export 'package:schedule/helper/date_time/convert_time.dart';
export 'package:schedule/helper/logic/tt_to_json.dart';
export 'package:schedule/helper/security/generate_password.dart';

// ================= Email =================
export 'package:schedule/helper/email/send_mail.dart';
export 'package:schedule/services/error_handler.dart';
export 'package:mailer/mailer.dart';
export 'package:mailer/smtp_server.dart';

// ================= Controllers =================
export 'package:schedule/controller/schedule/schedule_controller.dart';
export 'package:schedule/controller/session/session_controller.dart';
export 'package:schedule/controller/auth/login_controller.dart';
export 'package:schedule/controller/auth/forget_password_controller.dart';


// ================= Models =================
export 'package:schedule/models/class_avalability_model.dart';
export 'package:schedule/models/class_timing_model.dart';
export 'package:schedule/models/dept_availability_model.dart';
export 'package:schedule/models/users_applied_model.dart';

// ================= Other Packages =================
export 'package:file_picker/file_picker.dart';
export 'package:schedule/services/session_service.dart';
