import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/widgets/base_app_button.dart';
import 'package:flutter/material.dart';

import '../../../helper/presintation/pages/main_screen.dart';

class ChangeSuccessPass extends StatelessWidget {
  const ChangeSuccessPass({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: BeWithMeColors.mainColor,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: height * 0.70,
                decoration: BoxDecoration(
                  color: BeWithMeColors.backGroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 25),
                        Image.asset(
                          'assets/images/change success.png',
                          height: height / 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your password has been reset',
                          style: TextStyle(fontSize: 17),
                        ),
                        Text(
                          'Successfully!',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        // Login Button
                        BaseAppButton(
                          text: 'Continue',
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => MainScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 80),
              // Title
              Text(
                'Password Changed!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ), // Email Field
            ],
          ),
        ],
      ),
    );
  }
}
