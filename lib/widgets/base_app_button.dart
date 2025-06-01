import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:flutter/material.dart';

class BaseAppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BaseAppButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      width: MediaQuery.of(context).size.width,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: BeWithMeColors.mainColor, // Background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Border radius
          ),
        ),
        child: Text(text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: 'Merriweather-Black',
            )),
      ),
    );
  }
}
