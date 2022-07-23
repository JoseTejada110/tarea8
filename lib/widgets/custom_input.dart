import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInput extends StatelessWidget {
  const CustomInput({
    Key? key,
    required this.controller,
    this.focusNode,
    this.width,
    this.height,
    this.textCapitalization = TextCapitalization.none,
    this.textInputType = TextInputType.text,
    this.minLines = 1,
    this.maxLines = 1,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters = const [],
    this.onSubmitted,
    this.inputAction,
    this.borderRadius = const BorderRadius.all(Radius.circular(10.0)),
    this.isObscure = false,
    this.autofocus = false,
    this.onChanged,
    this.margin,
    this.readOnly = false,
    this.backgroundColor,
    this.maxLength,
    this.onEditingComplete,
  }) : super(key: key);
  final TextEditingController controller;
  final FocusNode? focusNode;
  final double? width;
  final double? height;
  final TextCapitalization textCapitalization;
  final TextInputType textInputType;
  final TextInputAction? inputAction;
  final int minLines;
  final int maxLines;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter> inputFormatters;
  final void Function(String?)? onSubmitted;
  final BorderRadius borderRadius;
  final bool isObscure;
  final bool autofocus;
  final void Function(String)? onChanged;
  final EdgeInsets? margin;
  final bool readOnly;
  final Color? backgroundColor;
  final int? maxLength;
  final void Function()? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width,
            height: height,
            child: TextField(
              onEditingComplete: onEditingComplete,
              maxLength: maxLength,
              readOnly: readOnly,
              autofocus: autofocus,
              obscureText: isObscure,
              onSubmitted: onSubmitted,
              textCapitalization: textCapitalization,
              inputFormatters: inputFormatters,
              keyboardType: textInputType,
              minLines: minLines,
              maxLines: maxLines,
              controller: controller,
              focusNode: focusNode,
              textInputAction: inputAction,
              decoration: InputDecoration(
                fillColor: backgroundColor,
                filled: backgroundColor != null,
                labelText: labelText,
                hintText: hintText,
                errorText: errorText,
                prefixIcon: prefixIcon,
                suffixIcon: getSuffixIcon(),
              ),
              onChanged: onChanged,
            )
          ),
        ],
      ),
    );
  }

  Widget? getSuffixIcon() {
    return errorText == null
      ? suffixIcon
      : _CustomErrorIcon(error: errorText!);
  }
}

class _CustomErrorIcon extends StatelessWidget {
  const _CustomErrorIcon({Key? key, required this.error}) : super(key: key);
  final String error;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: error,
      child: const Icon(
        Icons.warning_rounded,
        color: Colors.red,
        size: 25,
      ),
    );
  }
}