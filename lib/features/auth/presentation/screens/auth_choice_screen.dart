import 'package:be_with_me_new_new/features/auth/presentation/screens/login_screen.dart';
import 'package:be_with_me_new_new/features/auth/presentation/screens/register_screen.dart';
import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/widgets/base_app_button.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth bloc/auth_bloc.dart';

// ignore: must_be_immutable
class AuthChoiceScreen extends StatelessWidget {
  List<CameraDescription> cameras;
  AuthChoiceScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeWithMeColors.backGroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;
          double textScale = width / 400; // Adjust text scaling based on width

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.1),
                  // Login or Sign Up Text
                  Text(
                    'Be With Me',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BeWithMeColors.mainColor,
                      fontSize: 50 * textScale,
                      fontFamily: 'Merriweather-Black',
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: height * 0.06),

                  // Image (Responsive)
                  Image.asset(
                    'assets/images/auth choice.png',
                    width: width * 0.85,
                    height: height * 0.5,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: height * 0.04),

                  // Login Button
                  SizedBox(
                    width: width * 0.8,
                    child: BaseAppButton(
                      text: 'Login',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => AuthBloc(),
                              child: LoginScreen(
                                cameras: cameras,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: height * 0.01),

                  // Sign Up Button (Fixed typo "Sing Up" → "Sign Up")
                  SizedBox(
                    width: width * 0.8,
                    child: BaseAppButton(
                      text: 'Sign Up',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => AuthBloc(),
                              child: RegisterScreen(
                                cameras: cameras,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: height * 0.05),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
