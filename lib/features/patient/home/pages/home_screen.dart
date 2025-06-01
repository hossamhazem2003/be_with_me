import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';

// Import application files
import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_profile_data_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/update_profile_usecase.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/profile%20bloc/profile_bloc.dart';
import 'package:be_with_me_new_new/features/helper/presintation/pages/profile_screen.dart';
import 'package:be_with_me_new_new/features/patient/home/pages/hearing_problems_screen.dart';
import 'package:be_with_me_new_new/features/patient/home/pages/vision_problems_screen.dart';
import 'package:be_with_me_new_new/features/patient/vision/domain/usecases/create_post_usecase.dart';
import 'package:be_with_me_new_new/features/patient/vision/domain/usecases/get_accepts_usecase.dart';
import 'package:be_with_me_new_new/features/patient/vision/domain/usecases/get_helpers_usecase.dart';
import 'package:be_with_me_new_new/features/patient/vision/domain/usecases/get_my_posts_usecase.dart';
import 'package:be_with_me_new_new/features/patient/vision/presentation/blocs/helperbloc/helper_bloc.dart';
import 'package:be_with_me_new_new/features/patient/vision/presentation/blocs/helperbloc/helper_events.dart';
import 'package:be_with_me_new_new/features/patient/vision/presentation/blocs/post%20bloc/post_bloc.dart';

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: BeWithMeColors.backGroundColor,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // App logo or icon could be added here
                // Image.asset('assets/images/logo.png', height: 80),
                const SizedBox(height: 20),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: BeWithMeColors.mainColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'How can we help you today?',
                  style: TextStyle(
                    fontSize: 18,
                    color: BeWithMeColors.mainColor.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 60),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildFeatureCard(
                        context: context,
                        title: 'Hearing Assistance',
                        description: 'Get help with hearing-related issues',
                        icon: Icons.hearing,
                        color: Colors.blue.shade700,
                        onTap: () => _navigateToHearingProblems(context),
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context: context,
                        title: 'Vision Assistance',
                        description: 'Get help with vision-related issues',
                        icon: Icons.visibility,
                        color: Colors.blue.shade600,
                        onTap: () => _navigateToVisionProblems(context),
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context: context,
                        title: 'Profile Settings',
                        description: 'Manage your personal information',
                        icon: Icons.person,
                        color: Colors.blue.shade500,
                        onTap: () => _navigateToProfile(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHearingProblems(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HearingProblemsScreen()),
    );
  }

  void _navigateToVisionProblems(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => PostBloc(
                createPostUseCase: CreatePostUseCase(),
                getMyPostsUseCase: GetMyPostsUseCase(),
                getAcceptsUseCase: GetAcceptsUseCase(),
              ),
            ),
            BlocProvider(
              create: (_) => HelperBloc(
                getHelpersUseCase: GetHelpersUseCase(),
              )..add(GetAllHelpers()),
            ),
          ],
          child: VisionProblemsScreen(cameras: cameras),
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ProfileBloc(
            getProfileUseCase: GetProfileDataUsecase(),
            updateProfileUseCase: UpdateProfileUsecase(),
          ),
          child: const ProfileScreen(),
        ),
      ),
    );
    debugPrint('Navigated to Profile screen');
  }
}
