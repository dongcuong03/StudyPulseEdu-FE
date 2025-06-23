import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final String imageUrl;
  final Color color;
  final int size;

  const StatisticCard({
    super.key,
    required this.title,
    required this.value,
    required this.imageUrl,
    required this.color,
    required this.size
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: color),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: Offset(0, 0),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 25.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title và Icon trên cùng một dòng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 16.sp, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Image.asset(
                      imageUrl,
                      width: size.sp,
                      height: size.sp,
                      color: color,
                      colorBlendMode: BlendMode.srcIn,
                    ),


                    SizedBox(width: 20.w),
                  ],
                ),
                SizedBox(height: 4.h),
                // Value bên dưới
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
