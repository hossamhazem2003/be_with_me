import 'package:be_with_me_new_new/features/patient/vision/presentation/pages/show_posts.dart';
import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../vision/presentation/pages/create_post_tab.dart';
import '../../vision/presentation/pages/get_helpers_tab.dart';
import '../../vision/presentation/pages/yolo_screen.dart';

class VisionProblemsScreen extends StatefulWidget {
  List<CameraDescription> cameras;
  VisionProblemsScreen({required this.cameras});
  @override
  _VisionProblemsScreenState createState() => _VisionProblemsScreenState();
}

class _VisionProblemsScreenState extends State<VisionProblemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeWithMeColors.backGroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Vision Problems',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: BeWithMeColors.mainColor,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelStyle: TextStyle(color: Colors.white),
          labelStyle: TextStyle(color: Colors.white),
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: [
            Tab(text: 'Object Detection'),
            Tab(text: 'Create Post'),
            Tab(text: 'Show Posts'),
            Tab(text: 'Show Helpers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RealTimeObjectDetection(cameras: widget.cameras),
          CreatePostTab(),
          ShowPostsTab(),
          PeopleScreen(),
        ],
      ),
    );
  }
}
