import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_event.dart';
import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_states.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/register_request_model.dart';
import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/widgets/base_app_button.dart';
import '../auth bloc/auth_bloc.dart';
import 'login_screen.dart';

class CompleteRegisterScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  List<CameraDescription> cameras;

  CompleteRegisterScreen(
      {Key? key,
      required this.username,
      required this.email,
      required this.password,
      required this.confirmPassword,
      required this.cameras})
      : super(key: key);

  @override
  State<CompleteRegisterScreen> createState() => _CompleteRegisterScreenState();
}

class _CompleteRegisterScreenState extends State<CompleteRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();

  File? _profileImage;
  String? _gender;
  String? _role;
  String? _fullName;
  DateTime? _birthDate;

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose the image source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: BeWithMeColors.mainColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageSourceOption(
                  icon: Icons.camera_alt,
                  title: 'camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _imageSourceOption(
                  icon: Icons.photo_library,
                  title: 'phone gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: BeWithMeColors.mainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: BeWithMeColors.mainColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: BeWithMeColors.mainColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _gender != null &&
        _role != null &&
        _birthDate != null) {
      _formKey.currentState!.save();
      final request = RegisterRequestModel(
        fullName: _fullName!,
        gender: _gender!,
        role: _role!,
        dateOfBirth:
            '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
        profileImage: _profileImage?.path ?? '',
        username: widget.username,
        email: widget.email,
        password: widget.password,
        confirmPassword: widget.confirmPassword,
      );
      context.read<AuthBloc>().add(RegisterEvent(request));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeWithMeColors.mainColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          } else {
            // Close loading dialog if it exists
            Navigator.of(context, rootNavigator: true).pop();
          }

          if (state is RegisterSuccess) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => BlocProvider(
                          create: (context) => AuthBloc(),
                          child: LoginScreen(
                            cameras: widget.cameras,
                          ),
                        )));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Registration completed successfully,Login to continue'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to next screen or login
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: LayoutBuilder(
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(height: height * 0.1),

                        // Profile Image
                        GestureDetector(
                          onTap: _showImageSourceSelection,
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: _profileImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child: Image.file(
                                        _profileImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.camera_alt,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.03),

                        // Title
                        Text(
                          'Complete registration',
                          style: TextStyle(
                            fontSize: 28 * textScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Merriweather-Black',
                          ),
                        ),

                        SizedBox(height: height * 0.01),

                        Text(
                          "Complete your personal information",
                          style: TextStyle(
                            fontSize: 16 * textScale,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Merriweather-Black',
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: height * 0.05),

                        // Bottom White Container
                        Container(
                          width: width,
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.06),
                          decoration: const BoxDecoration(
                            color: BeWithMeColors.backGroundColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: height * 0.04),

                                // Full Name Field
                                Text('Full Name',
                                    style: _labelStyle(textScale)),
                                SizedBox(height: height * 0.01),
                                _buildTextField(
                                  'Enter your full name',
                                  controller: _fullNameController,
                                  onSaved: (val) => _fullName = val,
                                ),

                                SizedBox(height: height * 0.02),

                                // Gender Section
                                Text('Gender', style: _labelStyle(textScale)),
                                SizedBox(height: height * 0.01),
                                _buildSelectionCard(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildRadioOption(
                                          title: 'Male',
                                          value: 'Male',
                                          groupValue: _gender,
                                          onChanged: (val) =>
                                              setState(() => _gender = val),
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildRadioOption(
                                          title: 'Female',
                                          value: 'Female',
                                          groupValue: _gender,
                                          onChanged: (val) =>
                                              setState(() => _gender = val),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: height * 0.02),

                                // Role Section
                                Text('Role', style: _labelStyle(textScale)),
                                SizedBox(height: height * 0.01),
                                _buildSelectionCard(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildRadioOption(
                                          title: 'Helper',
                                          value: 'helper',
                                          groupValue: _role,
                                          onChanged: (val) =>
                                              setState(() => _role = val),
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildRadioOption(
                                          title: 'Patient',
                                          value: 'patient',
                                          groupValue: _role,
                                          onChanged: (val) =>
                                              setState(() => _role = val),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: height * 0.02),

                                // Birth Date
                                Text('Birth Date',
                                    style: _labelStyle(textScale)),
                                SizedBox(height: height * 0.01),
                                GestureDetector(
                                  onTap: _selectBirthDate,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: BeWithMeColors.mainColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _birthDate == null
                                              ? 'Chose Birth Date'
                                              : '${_birthDate!.day}-${_birthDate!.month}-${_birthDate!.year}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: _birthDate == null
                                                ? Colors.grey.shade600
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: height * 0.04),

                                // Register Button
                                Center(
                                  child: SizedBox(
                                    width: width * 0.85,
                                    child: BaseAppButton(
                                      text: 'Register',
                                      onPressed: _submit,
                                    ),
                                  ),
                                ),

                                SizedBox(height: height * 0.04),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Back Button
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            );
          },
        ),
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
  Widget _buildTextField(
    String hintText, {
    required TextEditingController controller,
    required Function(String?) onSaved,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'This field required' : null,
      onSaved: onSaved,
    );
  }

  Widget _buildSelectionCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String value,
    required String? groupValue,
    required Function(String?) onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      value: value,
      groupValue: groupValue,
      activeColor: BeWithMeColors.mainColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      onChanged: onChanged,
    );
  }
}
