import 'package:be_with_me_new_new/features/auth/data/models/request/send_code_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/verify_code_request_model.dart';
import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_event.dart';
import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_states.dart';
import 'package:be_with_me_new_new/features/auth/presentation/screens/new_password_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth bloc/auth_bloc.dart';

import '../../../../core/const/app_colors.dart';
import '../../../../widgets/base_app_button.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  List<CameraDescription> cameras;
  OtpScreen({super.key, required this.email,required this.cameras});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onVerifyCode() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the complete code')),
      );
      return;
    }
    context.read<AuthBloc>().add(
          VerifyCodeEvent(
            VerifyCodeRequestModel(
              email: widget.email,
              code: code,
            ),
          ),
        );
  }

  void _onSendCodeAgain() {
    context.read<AuthBloc>().add(
          SendCodeEvent(
            SendCodeRequestModel(
              email: widget.email,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is VerifyCodeSuccess) {
          // الانتقال إلى شاشة إعادة تعيين كلمة المرور
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => AuthBloc(),
                child: NewPasswordScreen(
                    email: widget.email, token: state.response.resetToken,cameras: widget.cameras,),
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
                          'Verification Code',
                          style: TextStyle(
                            fontSize: 32 * textScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          "Enter the code sent to your email",
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
                              'assets/images/otp.png', // تأكد من وجود الصورة في المسار الصحيح
                              width: width * 0.8,
                              height: height * 0.3,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          // OTP Fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              6,
                              (index) => SizedBox(
                                width: width * 0.12,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.length == 1 && index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    } else if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                  },
                                ),
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
                                    onPressed: _onVerifyCode,
                                  ),
                          ),
                          SizedBox(height: height * 0.03),
                          // Send Again Button
                          Center(
                            child: TextButton(
                              onPressed: _onSendCodeAgain,
                              child: Text(
                                'Send Code Again',
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
}
