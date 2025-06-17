import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
Future<String?> showParentVerificationDialog(BuildContext context) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nhập mã xác nhận phụ huynh',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    Pinput(
                      length: 6,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onCompleted: (value) {
                        Navigator.pop(context, value);
                      },
                      defaultPinTheme: PinTheme(
                        width: 50,
                        height: 60,
                        textStyle: const TextStyle(fontSize: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1), // Bóng mờ nhẹ
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                      separatorBuilder: (index) => const SizedBox(width: 10),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

void showErrorToast(String msg, {Toast length = Toast.LENGTH_SHORT}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: length,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 5,
    backgroundColor: Colors.deepOrangeAccent,
    textColor: Colors.white,
    fontSize: 15.sp,
  );
}