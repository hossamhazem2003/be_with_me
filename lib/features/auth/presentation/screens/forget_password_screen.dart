import 'package:be_with_me_new_new/features/auth/data/models/request/send_code_request_model.dart';
import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_event.dart';
import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_states.dart';
import 'package:be_with_me_new_new/features/auth/presentation/screens/otp_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth bloc/auth_bloc.dart';
import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/widgets/base_app_button.dart';

class ForgetPasswordScreen extends StatefulWidget {
  List<CameraDescription> cameras;
   ForgetPasswordScreen({super.key,required this.cameras});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SendCodeSuccess) {
          // الانتقال إلى شاشة التحقق من الكود
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => AuthBloc(),
                child: OtpScreen(email: _emailController.text,cameras: widget.cameras,),
              ),
            ),
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
                          'Forgot Password',
                          style: TextStyle(
                            fontSize: 32 * textScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          "Enter your email to reset your password",
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
                              'assets/images/forget pass.png',
                              width: width * 0.8,
                              height: height * 0.3,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          // Email Field
                          Text('Email', style: _labelStyle(textScale)),
                          SizedBox(height: height * 0.01),
                          _buildTextField(
                            'Enter your email',
                            controller: _emailController,
                          ),
                          SizedBox(height: height * 0.04),
                          // Send Code Button
                          SizedBox(
                            width: width * 0.85,
                            child: state is AuthLoading
                                ? Center(child: CircularProgressIndicator())
                                : BaseAppButton(
                                    text: 'Send Code',
                                    onPressed: () {
                                      if (_emailController.text.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Please enter your email')),
                                        );
                                        return;
                                      }
                                      context.read<AuthBloc>().add(
                                            SendCodeEvent(
                                              SendCodeRequestModel(
                                                email: _emailController.text,
                                              ),
                                            ),
                                          );
                                    },
                                  ),
                          ),
                          SizedBox(height: height * 0.03),
                          // Back Button
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Back To Login',
                                style: TextStyle(
                                  color: BeWithMeColors.mainColor,
                                  fontSize: 16 * textScale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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

  TextStyle _labelStyle(double scale) {
    return TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold);
  }

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
}
