import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_pulse_edu/viewmodels/mobile/assignment_user_view_model.dart';
import 'package:study_pulse_edu/viewmodels/mobile/classA_mobile_user_view_model.dart';
import 'package:study_pulse_edu/resources/widgets/assignment_filter_widget.dart';
import 'package:study_pulse_edu/views/mobile/user/assignment/widget/assignment_user_tab_widget.dart';
import '../../../../resources/utils/helpers/helper_mixin.dart';

class AssignmentUserScreen extends ConsumerStatefulWidget {
  final String? studentId;
  final String? studentName;
  final String? studentCode;

  const AssignmentUserScreen(
      {required this.studentId,
      required this.studentName,
      required this.studentCode,
      super.key});

  @override
  ConsumerState createState() => _AssignmentUserScreenState();
}

class _AssignmentUserScreenState extends ConsumerState<AssignmentUserScreen>
    with HelperMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;
  AssignmentTabType _currentTab = AssignmentTabType.all;

  final tabs = AssignmentTabType.values;

  String? _selectedClass;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = tabs[_tabController.index];
      });
    });
    Future.microtask(() {
      ref.read(assignmentUserViewModelProvider.notifier).fetchAssignments(
            studentId: widget.studentId,
          );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(assignmentUserViewModelProvider);
    final viewModelNotifier =
        ref.read(assignmentUserViewModelProvider.notifier);
    final assignments = viewModelNotifier.getAssignmentsByTab(_currentTab);

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Bài tập', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
                icon: const Icon(Icons.filter_list_alt, size: 30),
                onPressed: () async {
                  final classList = await ref
                      .read(classaMobileUserViewModelProvider.notifier)
                      .fetchClassAUser(id: widget.studentId.toString());
                  final classNames = classList.map((e) => e.className).toList();

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) {
                      return AssignmentFilterWidget(
                        classNames: classNames,
                        initialSelectedClass: _selectedClass,
                        initialFromDate: _fromDate,
                        initialToDate: _toDate,
                        onApply: ({selectedClass, fromDate, toDate}) {
                          setState(() {
                            _selectedClass = selectedClass;
                            _fromDate = fromDate;
                            _toDate = toDate;
                          });

                          ref
                              .read(assignmentUserViewModelProvider.notifier)
                              .fetchAssignments(
                                studentId: widget.studentId,
                                className: selectedClass,
                                formDate: fromDate,
                                toDate: toDate,
                              );
                        },
                        onReset: () {
                          setState(() {
                            _selectedClass = null;
                            _fromDate = null;
                            _toDate = null;
                          });

                          ref
                              .read(assignmentUserViewModelProvider.notifier)
                              .fetchAssignments(
                                studentId: widget.studentId,
                              );
                        },
                      );
                    },
                  );
                }),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Tất cả'),
                Tab(text: 'Chưa nộp'),
                Tab(text: 'Đã nộp'),
                Tab(text: 'Quá hạn'),
              ],
            ),
          ),
          Expanded(
            child: viewModel.when(
              data: (_) {
                return TabBarView(
                  controller: _tabController,
                  children: tabs.map((tabType) {
                    final assignments =
                        viewModelNotifier.getAssignmentsByTab(tabType);
                    return AssignmentTab(
                      assignments: assignments,
                      studentId: widget.studentId,
                      studentName: widget.studentName,
                      studentCode: widget.studentCode,
                      onSubmitted: () async {
                        await ref
                            .read(assignmentUserViewModelProvider.notifier)
                            .fetchAssignments(studentId: widget.studentId);
                        showSuccessToast("Nộp bài tập thành công");
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text("Lỗi: $e")),
            ),
          ),
        ],
      ),
    );
  }
}
