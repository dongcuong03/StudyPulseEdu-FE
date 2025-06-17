import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppInputSecond extends StatefulWidget {
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

  const AppInputSecond({
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
  });

  @override
  State<AppInputSecond> createState() => _AppInputSecondState();
}

class _AppInputSecondState extends State<AppInputSecond> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            key: widget.fieldKey,
            controller: widget.controller,
            keyboardType: widget.inputType,
            obscureText: widget.isPasswordField == true ? _obscureText : false,
            validator: widget.validator,
            readOnly: widget.readOnly,
            inputFormatters: widget.inputFormatters,
            onTap: widget.onTap,
            maxLines: widget.maxLines ?? 1,
            decoration: InputDecoration(

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              labelText: widget.labelText,
              labelStyle: TextStyle(color: Colors.grey[700]),
              helperText: widget.helperText,
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
                  color: Colors.grey,

                ),
              )
                  : null,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              isDense: true,
            ),
            onFieldSubmitted: widget.onFieldSubmitted,
            onSaved: widget.onSaved,
          ),
        ),
        if (widget.errorText != null && widget.errorText!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 6.w),
            child: Text(
              widget.errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }
}
