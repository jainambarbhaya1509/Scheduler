import 'package:schedule/imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewReservations extends StatefulWidget {
  const ViewReservations({super.key});

  @override
  State<ViewReservations> createState() => _ViewReservationsState();
}

class _ViewReservationsState extends State<ViewReservations> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loadingDepartments = false;
  bool _loadingClasses = false;
  bool _loadingSlots = false;

  String _slotsRoot = 'slots';

  List<String> _departments = [];
  String? _selectedDepartment;

  String _section = 'Classrooms';
  List<String> _classList = [];
  String? _selectedClass;

  List<String> _dayList = [];
  List<String> _slotTimesSorted = [];
  Map<String, Map<String, SlotInfo>> _data = {};
  List<RequestModel> _requests = [];

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    await _detectSlotsRoot();
    await _loadSavedDepartment();
    await _fetchDepartments();
  }

  Future<void> _loadSavedDepartment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDept = prefs.getString('selected_department');
      if (savedDept != null && savedDept.isNotEmpty) {
        setState(() {
          _selectedDepartment = savedDept;
        });
      }
    } catch (e) {
      logger.d('Error loading saved department: $e');
    }
  }

  Future<void> _saveDepartment(String dept) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_department', dept);
    } catch (e) {
      logger.d('Error saving department: $e');
    }
  }

  Future<void> _detectSlotsRoot() async {
    try {
      final snapSlots = await _firestore.collection('slots').limit(1).get();
      if (snapSlots.docs.isNotEmpty) {
        _slotsRoot = 'slots';
        return;
      }
      final snapSlots1 = await _firestore.collection('slots_1').limit(1).get();
      if (snapSlots1.docs.isNotEmpty) {
        _slotsRoot = 'slots_1';
        return;
      }
      _slotsRoot = 'slots';
    } catch (_) {
      _slotsRoot = 'slots';
    }
  }

  Future<void> _fetchDepartments() async {
    setState(() {
      _loadingDepartments = true;
      _departments = [];
      _selectedDepartment = null;
    });

    try {
      final daysSnap = await _firestore.collection(_slotsRoot).get();
      final deptSet = <String>{};
      for (final d in daysSnap.docs) {
        final depts = await _firestore
            .collection(_slotsRoot)
            .doc(d.id)
            .collection('departments')
            .get();
        for (final dd in depts.docs) {
          deptSet.add(dd.id);
        }
      }
      final sorted = deptSet.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      setState(() {
        _departments = sorted;
        if (_departments.isNotEmpty) _selectedDepartment = _departments.first;
      });
      if (_selectedDepartment != null) await _fetchClassesForSection();
    } catch (e, st) {
      logger.d('fetchDepartments error: $e\n$st');
    } finally {
      setState(() {
        _loadingDepartments = false;
      });
    }
  }

  Future<void> _fetchClassesForSection() async {
    if (_selectedDepartment == null) return;
    setState(() {
      _loadingClasses = true;
      _classList = [];
      _selectedClass = null;
    });
    try {
      final q = await _firestore.collectionGroup('slots').get();
      final classes = <String>{};
      final needle = 'departments/${_selectedDepartment!}/$_section/';
      for (final doc in q.docs) {
        final path = doc.reference.path;
        final idx = path.indexOf(needle);
        if (idx >= 0) {
          final after = path.substring(idx + needle.length);
          final parts = after.split('/');
          if (parts.isNotEmpty) classes.add(parts.first);
        }
      }
      final sorted = classes.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      setState(() {
        _classList = sorted;
      });
    } catch (e, st) {
      logger.d('fetchClasses error: $e\n$st');
    } finally {
      setState(() {
        _loadingClasses = false;
      });
    }
  }

  // ---------------- normalizers & canonicalizers ----------------
  String _norm(String? s) {
    if (s == null) return '';
    var out = s.toLowerCase().trim();
    out = out.replaceAll(RegExp(r'\s+'), ' ');
    out = out.replaceAll(RegExp(r'[–—−]'), '-');
    out = out.replaceAll(RegExp(r'\s*-\s*'), '-');
    out = out.replaceAll('.', '');
    return out;
  }

  String _normDay(String? d) {
    final n = _norm(d);
    final map = {
      'mon': 'monday',
      'tue': 'tuesday',
      'wed': 'wednesday',
      'thu': 'thursday',
      'thur': 'thursday',
      'fri': 'friday',
      'sat': 'saturday',
      'sun': 'sunday',
    };
    if (map.containsKey(n)) return map[n]!;
    for (final v in map.values) {
      if (n.contains(v.substring(0, 3))) return v;
    }
    return n;
  }

  String _canonicalizeSlot(String raw) {
    final s = raw.trim();
    var t = s.replaceAll(RegExp(r'\s+to\s+', caseSensitive: false), '-');
    t = t.replaceAll(RegExp(r'[–—−]'), '-');
    t = t.replaceAll(RegExp(r'\s*-\s*'), '-');
    final parts = t
        .split('-')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length != 2) return _norm(t);
    final a = _parseTimeToHHMM(parts[0]);
    final b = _parseTimeToHHMM(parts[1]);
    if (a != null && b != null) return '$a-$b';
    return _norm(t);
  }

  String? _parseTimeToHHMM(String input) {
    final x = input.trim().toLowerCase();
    final hm = RegExp(r'^(\d{1,2}):(\d{2})$');
    final m1 = hm.firstMatch(x);
    if (m1 != null) {
      final h = int.parse(m1.group(1)!);
      final mm = int.parse(m1.group(2)!);
      if (h >= 0 && h < 24 && mm >= 0 && mm < 60) {
        return '${h.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
      }
    }
    final ampm = RegExp(r'^(\d{1,2}):(\d{2})\s*(am|pm)$');
    final m2 = ampm.firstMatch(x.replaceAll(' ', ''));
    if (m2 != null) {
      var h = int.parse(m2.group(1)!);
      final mm = int.parse(m2.group(2)!);
      final ap = m2.group(3)!;
      if (ap == 'pm' && h < 12) h += 12;
      if (ap == 'am' && h == 12) h = 0;
      return '${h.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
    }
    final digits = RegExp(r'^(\d{3,4})$');
    final m3 = digits.firstMatch(x.replaceAll(':', ''));
    if (m3 != null) {
      final d = m3.group(1)!;
      if (d.length == 3) {
        final h = int.parse(d.substring(0, 1));
        final mm = int.parse(d.substring(1));
        return '${h.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
      } else if (d.length == 4) {
        final h = int.parse(d.substring(0, 2));
        final mm = int.parse(d.substring(2));
        return '${h.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
      }
    }
    final any = RegExp(r'(\d{1,2})[:\-]?(\d{2})');
    final m4 = any.firstMatch(x);
    if (m4 != null) {
      final h = int.parse(m4.group(1)!);
      final mm = int.parse(m4.group(2)!);
      if (h >= 0 && h < 24 && mm >= 0 && mm < 60) {
        return '${h.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
      }
    }
    return null;
  }

  int? _parseStartInMinutes(String slotId) {
    try {
      final start = slotId.split('-').first.trim();
      final parts = start.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) return h * 60 + m;
      }
    } catch (_) {}
    return null;
  }

  List<String> _orderDays(List<String> days) {
    final order = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final lower = days.map((d) => d.toLowerCase()).toList();
    final present = <String>[];
    for (final o in order) {
      if (lower.contains(o)) {
        present.add(days.firstWhere((d) => d.toLowerCase() == o));
      }
    }
    for (final d in days) {
      if (!present.contains(d)) present.add(d);
    }
    return present;
  }

  // ---------------- core loader (keeps consideredSlots marking existing tiles) ----------------
  Future<void> _loadSlotsAndRequests() async {
    if (_selectedDepartment == null || _selectedClass == null) return;
    setState(() {
      _loadingSlots = true;
      _data = {};
      _dayList = [];
      _slotTimesSorted = [];
      _requests = [];
    });

    try {
      final requestsSnap = await _firestore
          .collection('requests')
          .doc(_selectedDepartment)
          .collection('requests_list')
          .get();
      final allRequests = requestsSnap.docs
          .map((d) => RequestModel.fromMap(d.data(), d.id))
          .toList();
      logger.d('Total requests: ${allRequests.length}');

      final nonRejected = allRequests
          .where((r) => r.status.toLowerCase() != 'rejected')
          .toList();
      _requests = nonRejected;
      logger.d('Non-rejected requests: ${_requests.length}');

      final daysSnap = await _firestore.collection(_slotsRoot).get();
      final days = daysSnap.docs.map((d) => d.id).toList();
      final slotTimesSet = <String>{};
      final temp = <String, Map<String, SlotInfo>>{};

      for (final day in days) {
        final dayMap = <String, SlotInfo>{};
        final slotsCollRef = _firestore
            .collection(_slotsRoot)
            .doc(day)
            .collection('departments')
            .doc(_selectedDepartment)
            .collection(_section)
            .doc(_selectedClass)
            .collection('slots');
        final slotsSnap = await slotsCollRef.get();
        for (final sdoc in slotsSnap.docs) {
          final slotIdRaw = sdoc.id;
          final data = sdoc.data();
          final start =
              (data['start_time'] as String?) ?? slotIdRaw.split('-').first;
          final end =
              (data['end_time'] as String?) ??
              (slotIdRaw.split('-').length > 1
                  ? slotIdRaw.split('-').last
                  : '');
          final canon = _canonicalizeSlot(slotIdRaw);
          slotTimesSet.add(canon);
          dayMap[canon] = SlotInfo(
            slotId: canon,
            startTime: start,
            endTime: end,
          );
        }
        temp[day] = dayMap;
      }

      final unmatchedRequests = <RequestModel>[];
      for (final day in days) {
        final dayMap = temp[day] ?? <String, SlotInfo>{};
        for (final slot in slotTimesSet) {
          final existing = dayMap[slot];
          final info =
              existing ??
              SlotInfo(
                slotId: slot,
                startTime: slot.split('-').first,
                endTime: slot.split('-').length > 1 ? slot.split('-').last : '',
              );
          info.booked = false;
          info.bookedBy = null;
          info.applicants = [];

          final related = _requests.where((r) {
            final rdClass = _norm(r.className);
            final rdDay = _normDay(r.day);
            if (!(rdClass == _norm(_selectedClass) && rdDay == _normDay(day))) {
              return false;
            }

            if (r.consideredSlots != null && r.consideredSlots!.isNotEmpty) {
              final canonList = r.consideredSlots!
                  .map((cs) => _canonicalizeSlot(cs))
                  .toSet();
              if (canonList.contains(slot)) return true;
            }

            final rs = _canonicalizeSlot((r.slotTime ?? '').toString());
            if (rs.isNotEmpty && rs == slot) return true;

            return false;
          }).toList();

          for (final r in related) {
            final st = r.status.toLowerCase();
            if (st == 'accepted' || st == 'booked') {
              info.booked = true;
              info.bookedBy ??= (r.username ?? r.email ?? r.id).toString();
            } else {
              final display = (r.username ?? r.email ?? r.id).toString();
              if (display.isNotEmpty) info.applicants.add(display);
            }
          }

          dayMap[slot] = info;
        }

        final dayRelatedReqs = _requests.where(
          (r) =>
              _norm(r.className) == _norm(_selectedClass) &&
              _normDay(r.day) == _normDay(day),
        );
        for (final r in dayRelatedReqs) {
          var matched = false;
          if (r.consideredSlots != null && r.consideredSlots!.isNotEmpty) {
            for (final cs in r.consideredSlots!) {
              if (slotTimesSet.contains(_canonicalizeSlot(cs))) {
                matched = true;
                break;
              }
            }
          }
          final single = _canonicalizeSlot((r.slotTime ?? '').toString());
          if (!matched && single.isNotEmpty && slotTimesSet.contains(single)) {
            matched = true;
          }
          if (!matched) unmatchedRequests.add(r);
        }

        temp[day] = dayMap;
      }

      final sortedSlotTimes = slotTimesSet.toList()
        ..sort((a, b) {
          final aStart = _parseStartInMinutes(a);
          final bStart = _parseStartInMinutes(b);
          if (aStart != null && bStart != null) return aStart.compareTo(bStart);
          return a.compareTo(b);
        });

      final orderedDays = _orderDays(days);

      setState(() {
        _data = temp;
        _dayList = orderedDays;
        _slotTimesSorted = sortedSlotTimes;
      });

      if (unmatchedRequests.isNotEmpty) {
        logger.d(
          '--- UNMATCHED non-rejected requests (refer to non-existing slots) ---',
        );
        for (final r in unmatchedRequests) {
          logger.d(
            'req id=${r.id} class=${r.className} day=${r.day} considered=${r.consideredSlots} slot=${r.slotTime} status=${r.status}',
          );
        }
      } else {
        logger.d(
          'All non-rejected requests matched existing slots (or there were none).',
        );
      }
    } catch (e, st) {
      logger.d('loadSlotsAndRequests error: $e\n$st');
    } finally {
      setState(() {
        _loadingSlots = false;
      });
    }
  }

  // ---------- UI helpers ----------
  Color _statusColor(SlotInfo? info) {
    if (info == null) return Colors.green.shade700;
    if (info.booked) return Colors.red.shade700;
    if (info.applicants.isNotEmpty) return Colors.amber.shade700;
    return Colors.green.shade700;
  }

  String _statusLabel(SlotInfo? info) {
    if (info == null) return 'Available';
    if (info.booked) return 'Booked';
    if (info.applicants.isNotEmpty) return 'Applied';
    return 'Available';
  }

  String _getDayName(DateTime date) {
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[date.weekday - 1];
  }

  List<String> _getFilteredDays() {
    if (_selectedDate == null) {
      return _dayList;
    }
    final selectedDayName = _getDayName(_selectedDate!).toLowerCase();
    return _dayList
        .where((day) => day.toLowerCase() == selectedDayName)
        .toList();
  }

  bool _areAllFieldsFilled() {
    return _selectedDepartment != null &&
        _selectedClass != null &&
        _selectedDate != null;
  }

  String _getValidationError() {
    if (_selectedDepartment == null) {
      return 'Please select a Department';
    }
    if (_selectedClass == null) {
      return 'Please select a Class/Lab';
    }
    if (_selectedDate == null) {
      return 'Please select a Date';
    }
    return '';
  }

  // Modern, clean UI for filter controls - White background with black text
  Widget _buildTopControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Department display (non-editable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.business, color: Colors.black87, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedDepartment ?? 'Department',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Section selector
            _buildFilterField(
              label: 'Section',
              icon: Icons.school,
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _section,
                  items: const [
                    DropdownMenuItem(
                      value: 'Classrooms',
                      child: Text(
                        'Classrooms',
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Labs',
                      child: Text(
                        'Labs',
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                    ),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    setState(() {
                      _section = v;
                      _selectedClass = null;
                      _classList = [];
                      _data = {};
                      _dayList = [];
                      _slotTimesSorted = [];
                    });
                    await _fetchClassesForSection();
                  },
                  underline: const SizedBox.shrink(),
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Class selector
            _buildFilterField(
              label: 'Class/Lab',
              icon: Icons.class_,
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedClass,
                  hint: const Text(
                    'Select Class/Lab',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  items: _classList
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedClass = v;
                      _data = {};
                      _dayList = [];
                      _slotTimesSorted = [];
                      _selectedDate = null;
                    });
                    if (v != null) _loadSlotsAndRequests();
                  },
                  underline: const SizedBox.shrink(),
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Date selector
            Row(
              children: [
                Expanded(
                  child: _buildFilterField(
                    label: 'Date',
                    icon: Icons.calendar_today,
                    isDateField: true,
                    onDateTap: () async {
                      if (_selectedDepartment == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a Department first'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      if (_selectedClass == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a Class/Lab first'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    dateText: _selectedDate != null
                        ? '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}'
                        : 'Select Date',
                  ),
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black87,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Validation error
            if (!_areAllFieldsFilled())
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.red.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getValidationError(),
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (!_areAllFieldsFilled()) const SizedBox(height: 12),

            // Refresh button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_loadingSlots || !_areAllFieldsFilled())
                    ? null
                    : _loadSlotsAndRequests,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Load Slots',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterField({
    required String label,
    required IconData icon,
    Widget? child,
    bool isDateField = false,
    VoidCallback? onDateTap,
    String? dateText,
  }) {
    if (isDateField && onDateTap != null) {
      return GestureDetector(
        onTap: onDateTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black87, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dateText ?? 'Select Date',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 18),
          const SizedBox(width: 10),
          Expanded(child: child ?? const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildSlotTileContent(SlotInfo? info, String slotId) {
    final color = _statusColor(info);
    final label = _statusLabel(info);
    final displayTime = (info?.startTime != null && info?.endTime != null)
        ? '${info!.startTime} - ${info.endTime}'
        : slotId;

    final children = <Widget>[
      Text(
        displayTime,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, color: color),
      ),
    ];

    if (info != null && info.booked) {
      final by = info.bookedBy ?? 'Unknown';
      children.addAll([
        const SizedBox(height: 4),
        Text(
          by,
          style: TextStyle(fontWeight: FontWeight.w800, color: color),
        ),
      ]);
    } else if (info != null && info.applicants.isNotEmpty) {
      final show = info.applicants.length <= 3
          ? info.applicants
          : info.applicants.sublist(0, 3);
      children.add(const SizedBox(height: 6));
      children.addAll([
        for (final name in show) ...[
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 4),
        ],
      ]);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildGrid() {
    if (_selectedClass == null ||
        _selectedDepartment == null ||
        _selectedDate == null) {
      return const SizedBox.shrink();
    }
    if (_loadingSlots) {
      return const Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black,
        ),
      );
    }
    if (_dayList.isEmpty) {
      return const Center(
        child: Text(
          'No slots found for the selected class/lab.',
          style: TextStyle(color: Colors.black),
        ),
      );
    }

    final filteredDays = _getFilteredDays();
    if (filteredDays.isEmpty) {
      return Center(
        child: Text(
          _selectedDate != null
              ? 'No slots found for ${_getDayName(_selectedDate!)} (${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}).'
              : 'No slots found for the selected class/lab.',
          style: const TextStyle(color: Colors.black),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: filteredDays.map((day) {
          final dayMap = _data[day] ?? {};
          final slotIds = _slotTimesSorted;
          if (slotIds.isEmpty) {
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No slots found for this day.',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            );
          }

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const tileMinWidth = 160.0;
                      final crossAxisCount =
                          (constraints.maxWidth / tileMinWidth).floor().clamp(
                            1,
                            6,
                          );
                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: slotIds.length,
                        itemBuilder: (context, index) {
                          final slotId = slotIds[index];
                          final info = dayMap[slotId];
                          final color = _statusColor(info);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              border: Border.all(color: color),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildSlotTileContent(info, slotId),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // white app background
      // AppBar intentionally removed so no title is shown
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 28,
            ), // small top padding so content is not glued to status bar
            _buildTopControls(),
            const SizedBox(height: 4),
            _buildGrid(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------- Models ----------------

class SlotInfo {
  String? slotId;
  String? startTime;
  String? endTime;
  bool booked;
  String? bookedBy;
  List<String> applicants;

  SlotInfo({
    this.slotId,
    this.startTime,
    this.endTime,
    this.booked = false,
    this.bookedBy,
    List<String>? applicants,
  }) : applicants = applicants ?? [];
}

class RequestModel {
  final String id;
  final String? className; // mapped from roomId
  final String? day;
  final String? slotTime; // single slot
  final List<String>? consideredSlots; // optional array of strings
  final String status;
  final String? username;
  final String? email;
  final Map<String, dynamic> raw;

  RequestModel({
    required this.id,
    required this.className,
    required this.day,
    required this.slotTime,
    this.consideredSlots,
    required this.status,
    this.username,
    this.email,
    required this.raw,
  });

  factory RequestModel.fromMap(Map<String, dynamic> m, String id) {
    List<String>? cs;
    if (m['consideredSlots'] is List) {
      cs = (m['consideredSlots'] as List)
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (m['considered_slots'] is List) {
      cs = (m['considered_slots'] as List)
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return RequestModel(
      id: id,
      className:
          (m['roomId'] ?? m['className'] ?? m['class'] ?? m['class_name'])
              ?.toString(),
      day: (m['day'] ?? m['dayName'] ?? m['day_name'])?.toString(),
      slotTime: (m['timeSlot'] ?? m['slotTime'] ?? m['slot_time'] ?? m['slot'])
          ?.toString(),
      consideredSlots: cs,
      status: (m['status'] ?? '').toString(),
      username: (m['username'] ?? m['userName'] ?? m['name'])?.toString(),
      email: (m['email'] ?? m['userEmail'])?.toString(),
      raw: m,
    );
  }
}
