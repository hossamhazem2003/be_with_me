import 'package:be_with_me_new_new/features/auth/data/models/request/reset_password_request_model.dart';
import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_event.dart';
import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_states.dart';
import 'package:be_with_me_new_new/features/auth/presentation/screens/login_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth bloc/auth_bloc.dart';
import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/widgets/base_app_button.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String token;
  List<CameraDescription> cameras;
  NewPasswordScreen(
      {super.key, required this.email, required this.token,required this.cameras});

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onResetPassword() {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both passwords')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          ResetPasswordEvent(
            ResetPasswordRequestModel(
              email: widget.email,
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
              token: widget.token,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.response.message)),
          );
          // الانتقال إلى شاشة تسجيل الدخول
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => AuthBloc(
                    // قم بتمرير UseCases المناسبة هنا
                    ),
                child: LoginScreen(cameras: widget.cameras,),
              ),
            ),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
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
                  // الجزء العلوي مع النصوص
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: height * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New Password',
                          style: TextStyle(
                            fontSize: 32 * textScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          "Enter your new password",
                          style: TextStyle(
                            fontSize: 16 * textScale,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // الجزء السفلي
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: width,
                      height: height * 0.7,
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
                          SizedBox(height: height * 0.02),
                          // Image
                          Center(
                            child: Image.asset(
                              'assets/images/change success.png',
                              width: width * 0.8,
                              height: height * 0.3,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          // Password Field
                          Text('New Password', style: _labelStyle(textScale)),
                          SizedBox(height: height * 0.01),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter your new password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          // Confirm Password Field
                          Text('Confirm Password',
                              style: _labelStyle(textScale)),
                          SizedBox(height: height * 0.01),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              hintText: 'Confirm your new password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.04),
                          // Continue Button
                          SizedBox(
                            width: width * 0.85,
                            child: state is AuthLoading
                                ? Center(child: CircularProgressIndicator())
                                : BaseAppButton(
                                    text: 'Continue',
                                    onPressed: _onResetPassword,
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
      },
    );
  }

  TextStyle _labelStyle(double textScale) {
    return TextStyle(
      fontSize: 16 * textScale,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
  }
}
