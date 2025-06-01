import 'dart:developer';

import 'package:be_with_me_new_new/features/auth/data/models/request/login_request_model.dart';
import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_event.dart';
import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_states.dart';
import 'package:be_with_me_new_new/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:be_with_me_new_new/features/auth/presentation/screens/register_screen.dart';
import 'package:be_with_me_new_new/features/helper/data/helper%20data%20source/calls_data_source.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/accept_post_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_all_posts_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_calls_history_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_post_reactions_by_id.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_profile_data_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/inti_call_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/update_profile_usecase.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/calls%20bloc/call_events.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/calls%20bloc/calls_bloc.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/posts%20bloc/posts_bloc.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/profile%20bloc/profile_bloc.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/profile%20bloc/profile_events.dart';
import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/widgets/base_app_button.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../helper/presintation/pages/main_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../patient/home/pages/home_screen.dart';
import '../auth bloc/auth_bloc.dart';

// ignore: must_be_immutable
class LoginScreen extends StatefulWidget {
  List<CameraDescription> cameras;
  LoginScreen({super.key, required this.cameras});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          log('role from api ${state.response.role}');
          log('role exact value: "${state.response.role}"'); // This will show any hidden characters
          if (state.response.role == 'helper') {
            log('we are in helper');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) => PostsBloc(
                                getAllPostsUseCase: GetAllPostsUsecase(),
                                getPostReactionsByIdUseCase:
                                    GetPostReactionsByIdUseCase(),
                                acceptPostUseCase: AcceptPostUseCase()),
                          ),
                          BlocProvider(
                            create: (context) => ProfileBloc(
                              getProfileUseCase: GetProfileDataUsecase(),
                              updateProfileUseCase: UpdateProfileUsecase(),
                            )..add(GetProfileDataEvent()),
                          ),
                          BlocProvider(
                              create: (context) => CallsBloc(
                                  getCallsHistoryUseCase:
                                      GetCallsHistoryUseCase(
                                          callsRepository: CallsDataSource()),
                                  intiCallUsecase: IntiCallUsecase(
                                      callsRepository: CallsDataSource()))
                                ..add(GetCallsHistoryEvent()))
                        ],
                        child: MainScreen(),
                      )),
            );
          } else if (state.response.role == 'patient') {
            log('we are in patient');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (_) => HomeScreen(cameras: widget.cameras)),
            );
          } else {
            // Handle other roles or show an error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unknown role: ${state.response.role}')),
            );
          }
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
              double textScale = width / 400; // Adjust text size dynamically

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

                          // Login Title
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 32 * textScale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Merriweather-Black',
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: height * 0.01),

                          // Welcome Text
                          Text(
                            "Welcome back! We've missed you",
                            style: TextStyle(
                              fontSize: 16 * textScale,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Merriweather-Black',
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: height * 0.03),

                          // Bottom White Container
                          Container(
                            width: width,
                            padding:
                                EdgeInsets.symmetric(horizontal: width * 0.06),
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

                                // Email Field
                                Text('Email Or Username',
                                    style: _labelStyle(textScale)),
                                SizedBox(height: height * 0.01),
                                _buildTextField(
                                  'Enter your email or username',
                                  controller: _emailController,
                                ),

                                SizedBox(height: height * 0.02),

                                // Password Field
                                Text('Password', style: _labelStyle(textScale)),
                                SizedBox(height: height * 0.01),
                                _buildPasswordField(),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider(
                                            create: (_) => AuthBloc(),
                                            child: ForgetPasswordScreen(
                                              cameras: widget.cameras,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Forget password?',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontFamily: 'Merriweather-Black',
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: height * 0.02),

                                // Login Button
                                SizedBox(
                                  width: width * 0.85,
                                  child: state is AuthLoading
                                      ? Center(
                                          child: CircularProgressIndicator())
                                      : BaseAppButton(
                                          text: 'Login',
                                          onPressed: () {
                                            log(_emailController.text);
                                            log(_passwordController.text);
                                            context.read<AuthBloc>().add(
                                                  LoginEvent(
                                                    LoginRequestModel(
                                                      usernameOrEmail:
                                                          _emailController.text,
                                                      password:
                                                          _passwordController
                                                              .text,
                                                    ),
                                                  ),
                                                );
                                          },
                                        ),
                                ),

                                SizedBox(height: height * 0.02),

                                // OR Divider
                                Center(
                                  child: Text(
                                    'or',
                                    style: TextStyle(fontSize: 22 * textScale),
                                  ),
                                ),

                                SizedBox(height: height * 0.02),

                                // Social Media Login Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildSocialButton(
                                        'assets/images/google.png'),
                                    SizedBox(width: width * 0.1),
                                    _buildSocialButton(
                                      'assets/images/facebook.jpg',
                                    ),
                                    SizedBox(width: width * 0.1),
                                    _buildSocialButton(
                                        'assets/images/apple.png'),
                                  ],
                                ),

                                SizedBox(height: height * 0.02),

                                // Sign Up Text
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider(
                                              create: (_) => AuthBloc(),
                                              child: RegisterScreen(
                                                cameras: widget.cameras,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Sign up',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Merriweather-Black',
                                        ),
                                      ),
                                    ),
                                  ],
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
      },
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

  // Email & Password TextField
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

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Enter your password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  // Social Media Button
  Widget _buildSocialButton(String assetPath) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Image.asset(assetPath, width: 32, height: 32),
      ),
    );
  }
}
