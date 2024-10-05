import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String labelText;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;

  const CustomInputField({
    required this.labelText,
    required this.onSaved,
    required this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }
}
