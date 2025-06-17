import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef PageChangedCallback = void Function(int page);

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PageChangedCallback onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> pageButtons = [];

    void addPageButton(int page) {
      final isSelected = page == currentPage;
      pageButtons.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: ElevatedButton(
            onPressed: isSelected ? null : () => onPageChanged(page),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(36.w, 36.h),
              backgroundColor: isSelected ? Colors.blue : Colors.grey[400],
              foregroundColor: isSelected ? Colors.white : Colors.black,
              disabledBackgroundColor: Colors.blue,
              disabledForegroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(
              '$page',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ),
      );
    }

    // Nút "trang trước"
    pageButtons.add(
      ElevatedButton(
        onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(36.w, 36.h)),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          )),
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade300; // Màu nền khi disabled (mờ)
            }
            return Colors.grey.shade400; // Màu nền khi enabled
          }),
          foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade500; // Màu chữ khi disabled (mờ)
            }
            return Colors.black; // Màu chữ khi enabled
          }),
        ),
        child: Text('<'),
      ),

    );

    if (totalPages <= 7) {
      for (int i = 1; i <= totalPages; i++) {
        addPageButton(i);
      }
    } else {
      addPageButton(1);

      if (currentPage > 4) {
        pageButtons.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Text('...', style: TextStyle(fontSize: 14.sp)),
        ));
      }

      int start = currentPage - 1;
      int end = currentPage + 1;

      if (start <= 1) {
        start = 2;
        end = 4;
      }

      if (end >= totalPages) {
        end = totalPages - 1;
        start = totalPages - 3;
      }

      for (int i = start; i <= end; i++) {
        if (i > 1 && i < totalPages) {
          addPageButton(i);
        }
      }

      if (currentPage < totalPages - 3) {
        pageButtons.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Text('...', style: TextStyle(fontSize: 14.sp)),
        ));
      }

      addPageButton(totalPages);
    }

    // Nút "trang sau"
    pageButtons.add(
      ElevatedButton(
        onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(36.w, 36.h)),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          )),
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade300; // Màu nền khi disabled (mờ)
            }
            return Colors.grey.shade400; // Màu nền khi enabled
          }),
          foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade500; // Màu chữ khi disabled (mờ)
            }
            return Colors.black; // Màu chữ khi enabled
          }),
        ),
        child: Text('>'),
      ),

    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: pageButtons,
      ),
    );
  }
}
