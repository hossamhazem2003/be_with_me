import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_bloc.dart';
import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/widgets/base_app_button.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'complete_register_screen.dart';

class RegisterScreen extends StatefulWidget {
  List<CameraDescription> cameras;
  RegisterScreen({super.key, required this.cameras});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeWithMeColors.mainColor,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;
          double textScale = width / 400;

          return Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.1),

                      // Register Title
                      Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 32 * textScale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Merriweather-Black',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: height * 0.01),

                      // Create Account Text
                      Text(
                        "Create a new account to get started",
                        style: TextStyle(
                          fontSize: 16 * textScale,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Merriweather-Black',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: height * 0.09),

                      // Bottom White Container
                      Container(
                        width: width,
                        padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                        decoration: BoxDecoration(
                          color: BeWithMeColors.backGroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height * 0.04),

                            // Username Field
                            Text('Username', style: _labelStyle(textScale)),
                            SizedBox(height: height * 0.01),
                            _buildTextField(
                              'Enter your username',
                              controller: _usernameController,
                            ),

                            SizedBox(height: height * 0.02),

                            // Email Field
                            Text('Email', style: _labelStyle(textScale)),
                            SizedBox(height: height * 0.01),
                            _buildTextField(
                              'Enter your email',
                              controller: _emailController,
                            ),

                            SizedBox(height: height * 0.02),

                            // Password Field
                            Text('Password', style: _labelStyle(textScale)),
                            SizedBox(height: height * 0.01),
                            _buildPasswordField(
                              controller: _passwordController,
                              isPassword: true,
                            ),

                            SizedBox(height: height * 0.02),

                            // Confirm Password Field
                            Text('Confirm Password',
                                style: _labelStyle(textScale)),
                            SizedBox(height: height * 0.01),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              isPassword: false,
                            ),

                            SizedBox(height: height * 0.04),

                            // Register Button
                            SizedBox(
                              width: width * 0.85,
                              child: BaseAppButton(
                                text: 'Next',
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          BlocProvider<AuthBloc>(
                                            create: (_) => AuthBloc(),
                                            child: CompleteRegisterScreen(
                                              username:
                                                  _usernameController.text,
                                              email: _emailController.text,
                                              password:
                                                  _passwordController.text,
                                              confirmPassword:
                                                  _confirmPasswordController
                                                      .text,
                                              cameras: widget.cameras,
                                            ),
                                          )));
                                },
                              ),
                            ),

                            SizedBox(height: height * 0.03),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Label Style
  TextStyle _labelStyle(double scale) {
    return TextStyle(
      fontSize: 16 * scale,
      fontWeight: FontWeight.bold,
      fontFamily: 'Merriweather-Black',
    );
  }

  // TextField Widget
  Widget _buildTextField(String hintText,
      {required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : _obscureConfirmPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: isPassword ? 'Enter your password' : 'Confirm your password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: IconButton(
          icon: Icon(
            isPassword
                ? (_obscurePassword ? Icons.visibility_off : Icons.visibility)
                : (_obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility),
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        ),
      ),
    );
  }

// Social Media Button
}
