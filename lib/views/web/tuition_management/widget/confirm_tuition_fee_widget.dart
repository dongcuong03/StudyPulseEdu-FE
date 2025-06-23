import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:study_pulse_edu/resources/constains/constants.dart';
import 'package:study_pulse_edu/resources/utils/helpers/helper_mixin.dart';

import 'dart:html' as html;
import '../../../../resources/utils/app/app_theme.dart';
import '../../../../viewmodels/web/tuition_fee_view_model.dart';

class ConfirmTuitionFeeWidget extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  const ConfirmTuitionFeeWidget({
    super.key,
    required this.onClose
  });

  @override
  ConsumerState<ConfirmTuitionFeeWidget> createState() =>
      _ConfirmTuitionFeeWidgetState();
}

class _ConfirmTuitionFeeWidgetState
    extends ConsumerState<ConfirmTuitionFeeWidget> with HelperMixin {
  html.File? selectedFile;

  String? fileError;

  void _submit()async{
    setState(() {
      fileError = null;
    });

    if (selectedFile == null) {
      setState(() {
        fileError = "File không được để trônng.";
      });
      return;
    }

    if (!selectedFile!.name.toLowerCase().endsWith('.xlsx')) {
      setState(() {
        fileError = "File không hợp lệ. Vui lòng chọn file Excel";
      });
      return;
    }
    try {
      showLoading(context, show: true);
      final fileBytes = await _readFileAsBytes(selectedFile!);
      final error = await ref.read(tuitionFeeViewModelProvider.notifier)
          .importTuitionFeeExcel(
        fileBytes,
        selectedFile!.name,
      );
      showLoading(context, show: false);

      if (error == null) {
        context.pop();
        widget.onClose?.call();
      } else {
        showErrorToastWeb(context, error);
      }
    } catch (e) {
      showErrorToast("Lỗi không xác định: $e");
      showLoading(context, show: false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: 500.w,
        height: 0.5.sh,
        child: Column(
          children: [
            // --- Title ---
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                        ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        blendMode: BlendMode.srcIn,
                        child: const Row(
                          children: [
                            Icon(Icons.upload),
                            SizedBox(width: 8),
                            Text(
                              'Xác nhận trạng thái nộp học phí',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(color: Colors.black87, thickness: 0.5),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: selectedFile == null
                                ? GestureDetector(
                                    onTap: _pickFile,
                                    behavior: HitTestBehavior.opaque,
                                    // để toàn vùng có thể nhận sự kiện
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.attach_file,
                                            color: Colors.black54),
                                        SizedBox(width: 8),
                                        Text(
                                          'Chọn file xác nhận tại đây',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.insert_drive_file,
                                          color: Colors.green),
                                      SizedBox(width: 8),
                                      Text(
                                        selectedFile!.name,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedFile = null;
                                          });
                                        },
                                        child: Icon(Icons.close,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                          ),
                        )
                      ],
                    ),
                    if (fileError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              fileError!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 60.h,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3E61FC), Color(0xFF75D1F3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                             _submit();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          child: Text(
                            'Hoàn tất',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickFile() {
    final uploadInput = html.FileUploadInputElement()..accept = '.xlsx';
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final file = uploadInput.files?.first;
      if (file != null) {
        setState(() {
          selectedFile = file;
          fileError = null;
        });
      }
    });
  }
  Future<Uint8List> _readFileAsBytes(html.File file) {
    final completer = Completer<Uint8List>();
    final reader = html.FileReader();

    reader.readAsArrayBuffer(file);

    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result as Uint8List);
    });

    reader.onError.listen((event) {
      completer.completeError("Đọc file thất bại");
    });

    return completer.future;
  }

}
