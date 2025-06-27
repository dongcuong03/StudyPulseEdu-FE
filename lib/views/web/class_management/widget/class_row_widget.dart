import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';

import '../../../../resources/utils/helpers/helper_mixin.dart';

class ClassRowWidget extends StatefulWidget {
  final String className;
  final String nameTeacher;
  final DateTime startDate;
  final DateTime endDate;
  final int numberStudent;
  final int maxStudent;
  final ClassStatus status;
  final Future<bool> Function() onToggle;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onEnroll;

  const ClassRowWidget(
      {super.key,
      required this.className,
      required this.nameTeacher,
      required this.startDate,
      required this.endDate,
      required this.numberStudent,
      required this.maxStudent,
      required this.status,
      required this.onToggle,
      required this.onView,
      required this.onEdit,
      required this.onEnroll});

  @override
  State<ClassRowWidget> createState() => _ClassRowWidgetState();
}

class _ClassRowWidgetState extends State<ClassRowWidget> with HelperMixin {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.status == ClassStatus.ACTIVE;
  }

  Future<void> _confirmToggle() async {
    final confirmed = await showConfirmDialogWeb(
      context: context,
      title: 'Thông báo',
      content: _isActive
          ? 'Bạn có muốn ẩn lớp học này?'
          : 'Bạn có muốn bỏ ẩn lớp học này?',
      icon: Icons.notifications,
    );

    if (confirmed == true) {
      final isDeactivating = _isActive;
      final success = await widget.onToggle(); // Gọi API
      if (success) {
        setState(() {
          _isActive = !_isActive;
        });
        showSuccessToastWeb(
          context,
          isDeactivating ? 'Ẩn lớp học thành công' : 'Bỏ ẩn lớp học thành công',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(widget.className)),
          Expanded(flex: 1, child: Center(child: Text(widget.nameTeacher))),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '${widget.startDate.day.toString().padLeft(2, '0')}/${widget.startDate.month.toString().padLeft(2, '0')}/${widget.startDate.year}',
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '${widget.endDate.day.toString().padLeft(2, '0')}/${widget.endDate.month.toString().padLeft(2, '0')}/${widget.endDate.year}',
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                  '${widget.numberStudent.toString()}/${widget.maxStudent.toString()}'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: _isActive,
                      onChanged: (_) => _confirmToggle(),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.blue),
                    onPressed: widget.onView,
                  ),
                  SizedBox(width: 20.w),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: widget.onEdit,
                  ),
                  SizedBox(width: 20.w),
                  IconButton(
                    icon: Icon(Icons.group_add, color: Colors.deepPurple),
                    onPressed: widget.onEnroll,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
