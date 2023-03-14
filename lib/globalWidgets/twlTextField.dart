import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../constants/constants.dart';
import '../responsive.dart';

// ignore: must_be_immutable
class TwlNormalTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;
  final int? maxlength;
  final int? maxLines;
  final String? hintText;
  final onTAp;
  final onchnage;
  final readOnly;
  final errorBorder;
  final focusedBorder;
  final List<TextInputFormatter>? inputForamtters;
  final textAlign;
  final prefixStyle;
  TextStyle? style;
  String? intialValue;
  final prefixText;
  final contentPadding;
  final expand;
  final textCapitalization;
  final isDense;
  final autofocus;
  TwlNormalTextField(
      {required this.controller,
      this.textCapitalization,
      this.textInputType,
      this.prefixStyle,
      this.validator,
      this.expand,
      this.autofocus,
      this.maxlength,
      this.maxLines,
      this.hintText,
      this.isDense,
      this.inputForamtters,
      this.textAlign,
      this.style,
      this.onTAp,
      this.intialValue,
      this.prefixText,
      this.contentPadding,
      this.readOnly,
      this.onchnage,
      this.focusedBorder,
      this.errorBorder});

  @override
  State<TwlNormalTextField> createState() => _TwlNormalTextFieldState();
}

class _TwlNormalTextFieldState extends State<TwlNormalTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: widget.textCapitalization == null
          ? TextCapitalization.none
          : widget.textCapitalization,
      // initialValue: widget.intialValue == null ? '' : widget.intialValue,
      textAlign: widget.textAlign == null ? TextAlign.start : widget.textAlign,
      maxLength: widget.maxlength,
      controller: widget.controller,
      keyboardType: widget.textInputType,
      validator: widget.validator,
      autofocus: widget.autofocus != null ? widget.autofocus : false,
      maxLines: widget.maxLines,
      onChanged: widget.onchnage,
      expands: widget.expand != null ? widget.expand : false,
      inputFormatters: widget.inputForamtters,
      style: widget.style == null
          ? TextStyle(fontSize: 15
              // isTab(context) ? 10.sp : 14.sp
              )
          : widget.style,
      onTap: widget.onTAp,
      decoration: InputDecoration(
        errorStyle: TextStyle(height: 0),
        counterText: "",
        // prefix: Text('+91 ',style: TextStyle(color: tBlack),),
        hintText: widget.hintText,
        hintStyle: TextStyle(fontSize: 15
            //  isTab(context) ? 10.sp : 14.sp
            ),
        // hintText: 'Enter Your Mobile Number',
        fillColor: Colors.white,
        prefixText: widget.prefixText,
        prefixStyle: widget.prefixStyle,
        contentPadding: widget.contentPadding != null
            ? widget.contentPadding
            : EdgeInsets.symmetric(horizontal: 15, vertical: 1),
        filled: true,
        isDense: widget.isDense != null ? widget.isDense : false,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(width: 1, color: Colors.black),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 0, color: Colors.black),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            width: 1,
            color: Colors.red,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
      ),
      readOnly: widget.readOnly != null ? widget.readOnly : false,
    );
  }
}
