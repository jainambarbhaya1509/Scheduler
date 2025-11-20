import 'package:get/get.dart';
import 'package:schedule/controller/schedule_controller.dart';

class HomeController extends GetxController {
  final RxBool changeMode = false.obs;
  ScheduleController scheduleController = Get.put(ScheduleController());

  void changeSearchMode() {
    changeMode.value = !changeMode.value;
  }
}
