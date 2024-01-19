import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Utils/helpers.dart';
import '../Utils/color_resources.dart';
import '../Utils/dimensions.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final Color? fillColor;
  final int maxLines;
  final bool isPassword;
  final bool isCountryPicker;
  final bool isShowBorder;
  final bool isIcon;
  final bool isShowSuffixIcon;
  final bool isShowPrefixIcon;
  final Function? onTap;
  final Function? onChanged;
  final Function? onSuffixTap;
  final String? suffixIconUrl;
  final String? prefixIconUrl;
  final String? prefixText;
  final bool isSearch;
  final Function? onSubmit;
  final Function(String s)? onFieldSubmit;
  final bool isEnabled;
  final bool isEmail;
  final bool isNumeric;
  final double cornerRadius;

  final TextCapitalization capitalization;
  final bool required;

  const CustomTextField(
      {super.key,
      this.hintText = 'Write something...',
      this.controller,
      this.focusNode,
      this.nextFocus,
      this.isEnabled = true,
      this.inputType = TextInputType.text,
      this.inputAction = TextInputAction.next,
      this.maxLines = 1,
      this.onSuffixTap,
      this.prefixText,
      this.fillColor,
      this.onSubmit,
      this.onFieldSubmit,
      this.onChanged,
      this.capitalization = TextCapitalization.none,
      this.isCountryPicker = false,
      this.isShowBorder = false,
      this.isShowSuffixIcon = false,
      this.isShowPrefixIcon = false,
      this.onTap,
      this.isIcon = false,
      this.isPassword = false,
      this.isEmail = false,
      this.suffixIconUrl,
      this.prefixIconUrl,
      this.isSearch = false,
      this.isNumeric = false,
      this.cornerRadius = 25,
      this.required = true});

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines,
      controller: widget.controller,
      focusNode: widget.focusNode,
      // style: Theme.of(context).textTheme.displayMedium!.copyWith(
      //     color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: 16),
      textInputAction: widget.inputAction,
      keyboardType: widget.inputType,
      // cursorColor: ColorResources.primaryColor,
      onFieldSubmitted: widget.onFieldSubmit,
      textCapitalization: widget.capitalization,
      enabled: widget.isEnabled,
      validator: (value) {
        if (widget.isEmail) {
          if (value == null || value.isEmpty) {
            return 'Required Field';
          }
          bool emailValid = RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(value);
          return !emailValid ? "Enter Valid Email" : null;
        } else if (widget.isNumeric) {
          return Helper.isNumeric(value) ? null : "Enter Valid Value";
        } else {
          if (widget.required && (value == null || value.isEmpty)) {
            return 'Required Field';
          }
        }
        return null;
      },
      autofocus: false,
      //onChanged: widget.isSearch ? widget.languageProvider.searchLanguage : null,
      obscureText: widget.isPassword ? _obscureText : false,
      inputFormatters: widget.inputType == TextInputType.phone
          ? <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9+]'))
            ]
          : null,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          borderSide: const BorderSide(style: BorderStyle.none, width: 0),
        ),
        isDense: true,
        prefixText: widget.prefixText,
        labelText: widget.hintText,
        // fillColor: widget.fillColor != null
        //     ? widget.fillColor
        //     : Theme.of(context).primaryColor,
        hintStyle: Theme.of(context)
            .textTheme
            .displayMedium!
            .copyWith(fontSize: 12, color: ColorResources.gray),
        filled: true,
        prefixIcon: widget.isShowPrefixIcon
            ? Padding(
                padding: const EdgeInsets.only(
                    left: Dimensions.PADDING_SIZE_LARGE,
                    right: Dimensions.PADDING_SIZE_SMALL),
                child: Image.asset(widget.prefixIconUrl!),
              )
            : const SizedBox.shrink(),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 23, maxHeight: 20),
        suffixIcon: widget.isShowSuffixIcon
            ? widget.isPassword
                ? IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Theme.of(context).hintColor.withOpacity(0.3)),
                    onPressed: _toggle)
                : widget.isIcon
                    ? IconButton(
                        onPressed: widget.onSuffixTap as void Function()?,
                        icon: Image.asset(
                          widget.suffixIconUrl!,
                          width: 20,
                          height: 20,
                          // color: Theme.of(context).textTheme.bodyText1!.color,
                        ),
                      )
                    : null
            : null,
      ),
      onTap: widget.onTap as void Function()?,
      // onSubmitted: (text) => widget.nextFocus != null
      //     ? FocusScope.of(context).requestFocus(widget.nextFocus)
      //     : widget.onSubmit!(text),
      onChanged: widget.onChanged as void Function(String)?,
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
