import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/superadmin/superadmin_controller.dart';
import 'package:schedule/widgets/faculty_card_widget.dart';

class ManageFacultyPage extends StatelessWidget {
  ManageFacultyPage({super.key});
  final SuperAdminController _superAdminController = Get.put(
    SuperAdminController(),
  );
  @override
  Widget build(BuildContext context) {
    final searchQuery = "".obs;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manage Faculty",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildSearchBar(context, searchQuery),
            const SizedBox(height: 15),
            Expanded(
              child: Obx(
                () => _superAdminController.faculties.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [Text("No faculties added")],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _superAdminController.faculties.length,
                        itemBuilder: (context, index) {
                          final faculty =
                              _superAdminController.faculties[index];

                          return Slidable(
                            key: ValueKey(faculty.email),

                            // 👉 Slide action (drag OR click on web)
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  onPressed: (_) async {
                                    final confirm = await Get.dialog<bool>(
                                      AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                        title: Row(
                                          children: [
                                            Icon(
                                              Icons.warning_amber_rounded,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text("Delete Faculty"),
                                          ],
                                        ),
                                        content: Text(
                                          "Delete ${faculty.username} permanently?",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                        actionsPadding:
                                            const EdgeInsets.fromLTRB(
                                              16,
                                              0,
                                              16,
                                              16,
                                            ),
                                        actions: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.7),
                                            ),
                                            onPressed: () =>
                                                Get.back(result: false),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                              foregroundColor: Theme.of(
                                                context,
                                              ).colorScheme.onError,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () =>
                                                Get.back(result: true),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      _superAdminController.deleteUser(
                                        faculty.email,
                                      );
                                    }
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: "Delete",
                                ),
                              ],
                            ),

                            child: FacultyCardWidget(
                              position: faculty.isHOD && faculty.isAdmin
                                  ? "HOD / Time Table Coordinator"
                                  : faculty.isHOD
                                  ? "Head of Department"
                                  : faculty.isAdmin
                                  ? "Time Table Coordinator"
                                  : "Faculty",
                              department: faculty.department,
                              username: faculty.username,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, RxString searchQuery) {
    return TextField(
      onChanged: (value) => searchQuery.value = value,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintText: "Search",
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
      ),
    );
  }
}
