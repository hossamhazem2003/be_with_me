import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/features/patient/vision/data/models/request/create_post_request.dart';
import 'package:be_with_me_new_new/features/patient/vision/presentation/blocs/post%20bloc/post_bloc.dart';
import 'package:be_with_me_new_new/features/patient/vision/presentation/blocs/post%20bloc/post_events.dart';
import 'package:be_with_me_new_new/features/patient/vision/presentation/blocs/post%20bloc/post_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePostTab extends StatefulWidget {
  @override
  _CreatePostTabState createState() => _CreatePostTabState();
}

class _CreatePostTabState extends State<CreatePostTab> {
  final TextEditingController _postController = TextEditingController();

  // Help suggestions specifically for blind users needing camera assistance
  final List<Map<String, dynamic>> helpSuggestions = [
    {
      'text': "I need help navigating to the nearest intersection",
      'icon': Icons.directions_walk
    },
    {
      'text': "Can someone help me identify objects in my surroundings?",
      'icon': Icons.search
    },
    {'text': "Need assistance reading labels on products", 'icon': Icons.label},
    {
      'text': "Help me find a specific item in my room",
      'icon': Icons.find_in_page
    },
    {'text': "I need guidance crossing a busy street", 'icon': Icons.traffic},
  ];

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _sharePost(BuildContext context) {
    if (_postController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe what help you need')),
      );
      return;
    }
    final createPostRequest = CreatePostRequest(
      content: _postController.text.trim(),
      createdAt: DateTime.now(),
    );
    context.read<PostBloc>().add(CreatePostEvent(request: createPostRequest));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostBloc, PostState>(
      listener: (context, state) {
        if (state is CreatePostSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Help request sent successfully!')),
          );
          _postController.clear();
        } else if (state is CreatePostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern text input field
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  controller: _postController,
                  maxLines: 5,
                  decoration: const InputDecoration.collapsed(
                    hintText:
                        'Describe what help you need with camera assistance...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Help suggestions title
              const Text(
                'Quick Help Requests:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              // Modern suggestion chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: helpSuggestions.map((suggestion) {
                  return GestureDetector(
                    onTap: () {
                      _postController.text = suggestion['text'];
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: BeWithMeColors.mainColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            suggestion['icon'],
                            size: 18,
                            color: BeWithMeColors.mainColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            suggestion['text'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              // Modern submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: state is CreatePostLoading
                      ? null
                      : () => _sharePost(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BeWithMeColors.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: BeWithMeColors.mainColor.withOpacity(0.3),
                  ),
                  child: state is CreatePostLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.post_add,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Request Help',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
