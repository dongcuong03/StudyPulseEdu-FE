import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';

import '../../../../resources/utils/helpers/helper_mixin.dart';

class AccountRow extends StatefulWidget {
  final String phone;
  final Role? role;
  final bool isActive;
  final Future<bool> Function() onToggle;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const AccountRow({
    super.key,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.onToggle,
    required this.onView,
    required this.onEdit,
  });

  @override
  State<AccountRow> createState() => _AccountRowState();
}

class _AccountRowState extends State<AccountRow> with HelperMixin {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.isActive;
  }

  Future<void> _confirmToggle() async {
    final confirmed = await showConfirmDialogWeb(
      context: context,
      title: 'Thông báo',
      content: _isActive
          ? 'Bạn có muốn vô hiệu hóa tài khoản này?'
          : 'Bạn có muốn mở lại tài khoản này?',
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
          isDeactivating
              ? 'Vô hiệu hóa tài khoản thành công'
              : 'Mở lại tài khoản thành công',
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
          Expanded(flex: 1, child: Text(widget.phone)),
          Expanded(
              flex: 1,
              child: Center(child: Text(widget.role?.displayName ?? ''))),
          Expanded(
            flex: 1,
            child: Center(
              child: Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: _isActive,
                  onChanged: (_) => _confirmToggle(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.blue),
                    onPressed: widget.onView,
                  ),
                  SizedBox(width: 40.w),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: widget.onEdit,
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
