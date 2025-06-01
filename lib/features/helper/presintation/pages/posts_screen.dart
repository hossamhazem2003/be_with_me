import 'dart:developer';

import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
import 'package:be_with_me_new_new/features/helper/data/models/response/get_posts_response_model.dart';
import 'package:be_with_me_new_new/features/helper/domain/entites/reactions_entity.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_notification_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/mark_all_notification_as_read_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/mark_notification_read_usecase.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/notification%20bloc/notification_bloc.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/posts%20bloc/posts_bloc.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/posts%20bloc/posts_events.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/posts%20bloc/posts_states.dart';
import 'package:be_with_me_new_new/features/helper/presintation/pages/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  void _loadPosts() {
    final token = SharedPreferencesManager.getToken();
    if (token != null) {
      context.read<PostsBloc>().add(GetAllPostsEvent(token: token));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      _loadPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeWithMeColors.backGroundColor,
      appBar: AppBar(
        backgroundColor: BeWithMeColors.mainColor,
        title: const Text(
          'Posts',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: Container(),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => NotificationBloc(
                        getNotificationUseCase: GetNotificationUseCase(),
                        markNotificationReadUseCase:
                            MarkNotificationAsReadUseCase(),
                        markAllNotificationsAsReadUseCase:
                            MarkAllNotificationsAsReadUseCase(),
                      ),
                      child: const NotificationsScreen(),
                    ),
                  ));
            },
          ),
        ],
      ),
      body: BlocConsumer<PostsBloc, PostsState>(
        listener: (context, state) {
          if (state is GetPostReactionsByIdSuccess) {
            _showReactionsBottomSheet(context, state.reactions);
          } else if (state is GetPostReactionsByIdError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AcceptPostSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Accepted Send to the Patient Waiting his confirmation'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          log(state.toString());
          if (state is PostsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AcceptPostLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentPosts = context.read<PostsBloc>().currentPosts;

          if (currentPosts.isEmpty) {
            return const Center(child: Text('No posts available'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadPosts();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: currentPosts.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == currentPosts.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final post = currentPosts[index];
                return _buildPostCard(post);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(GetPostsResponseModel post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.network(
                    post.author.pictureUrl.replaceAll(r'\', '/'),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey[300],
                        child: Icon(Icons.person, color: Color(0xff4A65F2)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post.author.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xff4A65F2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.content,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.favorite, color: Colors.red[400], size: 18),
                const SizedBox(width: 4),
                Text('${post.reactionsCount} Reactions'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      final token = SharedPreferencesManager.getToken();
                      if (token != null) {
                        context.read<PostsBloc>().add(GetPostReactionsByIdEvent(
                              token: token,
                              postId: post.id.toString(),
                            ));
                      }
                    },
                    icon: const Icon(Icons.people_outline,
                        color: Color(0xff4A65F2)),
                    label: const Text(
                      'Show Applied Helpers',
                      style: TextStyle(color: Color(0xff4A65F2)),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      context
                          .read<PostsBloc>()
                          .add(AcceptPostEvent(postId: post.id.toString()));
                    },
                    icon: const Icon(Icons.comment_outlined,
                        color: Color(0xff4A65F2)),
                    label: const Text('Accept',
                        style: TextStyle(color: Color(0xff4A65F2))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReactionsBottomSheet(
      BuildContext context, List<ReactionsEntity> reactions) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Applied Helpers',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff4A65F2)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: reactions.length,
                  itemBuilder: (context, index) {
                    final reaction = reactions[index];
                    return ListTile(
                      leading: ClipOval(
                        child: Image.network(
                          reaction.profileImageUrl.replaceAll(r'\\', '/'),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[300],
                              child: const Icon(Icons.person,
                                  color: Color(0xff4A65F2)),
                            );
                          },
                        ),
                      ),
                      title: Text(reaction.fullName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(reaction.rate.toString()),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
