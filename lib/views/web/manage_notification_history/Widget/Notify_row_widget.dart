import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';

import '../../../../resources/utils/helpers/helper_mixin.dart';

class NotifyRowWidget extends StatefulWidget {
  final String receiverName;
  final String senderName;
  final DateTime sendDate;
  final String title;
  final String message;

  const NotifyRowWidget({
    super.key,
    required this.receiverName,
    required this.senderName,
    required this.sendDate,
    required this.title,
    required this.message,
  });

  @override
  State<NotifyRowWidget> createState() => _NotifyRowWidgetState();
}

class _NotifyRowWidgetState extends State<NotifyRowWidget> with HelperMixin {
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
          Expanded(
              flex: 1,
              child: Tooltip(
                  message: widget.senderName,
                  child: Text(
                    widget.senderName,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ))),
          SizedBox(
            width: 20,
          ),
          Expanded(
              flex: 1,
              child: Tooltip(
                  message: widget.receiverName,
                  child: Text(
                    widget.receiverName,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ))),
          SizedBox(
            width: 10,
          ),
          Expanded(
              flex: 1,
              child: Center(
                  child: Text(DateFormat('HH:mm, dd/MM/yyyy')
                      .format(widget.sendDate)))),
          Expanded(flex: 1, child: Center(child: Text(widget.title))),
          SizedBox(
            width: 30,
          ),
          Expanded(
            flex: 2,
            child: Tooltip(
              message: widget.message,
              child: Text(
                widget.message,
                textAlign: TextAlign.justify,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          )
        ],
      ),
    );
  }
}
