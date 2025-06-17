import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constains/constants.dart';

class ImageViewerDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageViewerDialog({
    required this.images,
    this.initialIndex = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<ImageViewerDialog> {
  late PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Stack(
        children: [
          // Lớp bắt tap ở nền (tap vào vùng trống sẽ đóng)
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.transparent, // Đảm bảo vùng này bắt được tap
            ),
          ),

          // Lớp ảnh - không được lan tap ra ngoài
          Center(
            child: SizedBox(
              width: 0.8.sw,
              height: 0.75.sh,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imageUrl = "${ApiConstants.getBaseUrl}/uploads/${widget.images[index]}";
                  return GestureDetector(
                    onTap: () {}, // Chặn sự kiện tap ở ảnh
                    child: InteractiveViewer(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Paging indicator
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
