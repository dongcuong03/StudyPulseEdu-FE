import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../constains/constants.dart';

class PDFViewerDialog extends StatelessWidget {
  final String pdfUrl;

  const PDFViewerDialog({required this.pdfUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          AppBar(
            title: const Text('Xem PDF'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          Expanded(
            child: SfPdfViewer.network("${ApiConstants.getBaseUrl}/uploads/$pdfUrl"),
          ),
        ],
      ),
    );
  }
}
