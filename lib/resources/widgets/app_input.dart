import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppInput extends StatefulWidget {
  final TextEditingController? controller;
  final Key? fieldKey;
  final bool? isPasswordField;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final bool readOnly;
  final int? maxLines;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? inputType;
  final void Function()? onTap;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const AppInput({
    super.key,
    this.controller,
    this.isPasswordField,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.prefixIcon,
    this.maxLines,
    this.inputFormatters,
    this.readOnly = false,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.inputType,
    this.onTap,
    this.errorText,
    this.onChanged,

  });

  @override
  _AppInputState createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // tự động co chiều cao theo nội dung
      children: [
        TextFormField(
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          maxLines: widget.maxLines ?? 1,
          controller: widget.controller,
          keyboardType: widget.inputType,
          obscureText: widget.isPasswordField == true ? _obscureText : false,
          validator: widget.validator,
          readOnly: widget.readOnly,
          inputFormatters: widget.inputFormatters ?? [],
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.helperText,
            labelStyle: TextStyle(color: Colors.grey[800]),
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPasswordField == true
                ? GestureDetector(
              onTap: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              child: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: _obscureText ? Colors.grey : Colors.blue,
              ),
            )
                : null,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r), // dùng .r cho radius responsive
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.w),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5.w),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
            isDense: true,
            errorText: null, // tuyệt đối không dùng errorText để Flutter không vẽ lỗi mặc định
          ),
          onFieldSubmitted: widget.onFieldSubmitted,
          onSaved: widget.onSaved,
        ),
        if (widget.errorText != null && widget.errorText!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w), // dùng padding responsive
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.sp, // dùng đơn vị sp của flutter_screenutil
              ),
            ),
          ),
      ],
    );
  }
}
