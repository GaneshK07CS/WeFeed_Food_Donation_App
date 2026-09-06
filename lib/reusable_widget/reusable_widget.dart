import 'package:flutter/material.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.contain,
    width: 140,
    height: 140,
    color: Colors.white,
  );
}

Widget reusableTextField(
  String text,
  IconData icon,
  bool isPasswordType,
  TextEditingController controller, {
  String? Function(String?)? validator,
  Widget? suffixIcon,
  TextInputType? keyboardType,
  void Function(String)? onChanged,
}) {
  return TextFormField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    onChanged: onChanged,
    style: const TextStyle(color: Colors.white, fontSize: 15),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      labelText: text,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      fillColor: Colors.white.withValues(alpha: 0.22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      errorStyle: const TextStyle(
        color: Colors.yellowAccent,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(color: Colors.yellowAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(color: Colors.yellowAccent, width: 1.5),
      ),
    ),
    keyboardType: keyboardType ??
        (isPasswordType
            ? TextInputType.visiblePassword
            : (text.toLowerCase().contains('email')
                ? TextInputType.emailAddress
                : TextInputType.text)),
    validator: validator,
  );
}

Container firebaseButton(
  BuildContext context,
  String title,
  VoidCallback onTap, {
  Color? backgroundColor,
  Color? textColor,
  IconData? icon,
}) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.white,
        foregroundColor: textColor ?? Colors.black87,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: textColor ?? Colors.black87),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              color: textColor ?? Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ),
  );
}