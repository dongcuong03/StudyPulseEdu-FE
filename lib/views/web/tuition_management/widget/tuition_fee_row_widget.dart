import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';

import '../../../../resources/utils/helpers/helper_mixin.dart';

class TuitionFeeRowWidget extends StatefulWidget {
  final String studentCode;
  final String studentName;
  final double totalTuitionFee;
  final double unpaidTuitionFee;
  final TuitionStatus status;
  final VoidCallback onView;

  const TuitionFeeRowWidget(
      {super.key,
        required this.studentCode,
        required this.studentName,
        required this.totalTuitionFee,
        required this.unpaidTuitionFee,
        required this.status,
        required this.onView,});

  @override
  State<TuitionFeeRowWidget> createState() => _TuitionFeeRowWidgetState();
}

class _TuitionFeeRowWidgetState extends State<TuitionFeeRowWidget> with HelperMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      child: Row(
        children: [
          Expanded(flex: 0, child: Text(widget.studentCode)),
          SizedBox(width: 40,),
          Expanded(flex: 1, child: Text(widget.studentName)),
          Expanded(flex: 1, child: Center(child: Text(NumberFormat("#,##0", "en_US").format(widget.totalTuitionFee ?? 0)))),
          Expanded(flex: 1, child: Center(child: Text(NumberFormat("#,##0", "en_US").format(widget.unpaidTuitionFee ?? 0)))),
          Expanded(flex: 1, child: Center(child: Text(widget.status.displayName))),
          Expanded(
            flex: 1,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.blue),
                    onPressed: widget.onView,
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
