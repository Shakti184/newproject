import 'package:flutter/material.dart';

class RoundedInputField extends StatefulWidget {
  final String labelText;
  final bool obscureText;
  final double borderRadius;
  final TextEditingController? controller;

  const RoundedInputField({super.key, 
    required this.labelText,
    required this.obscureText,
    this.borderRadius = 10.0,
    this.controller,
  });

  @override
  State<RoundedInputField> createState() => _RoundedInputFieldState();
}

class _RoundedInputFieldState extends State<RoundedInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              decoration: InputDecoration(
                labelText: widget.labelText,
                contentPadding: const EdgeInsets.all(16.0),
                border: InputBorder.none,
              ),
            ),
          ),
          if (widget.obscureText)
            IconButton(
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            ),
        ],
      ),
    );
  }
}