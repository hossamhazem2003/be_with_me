import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/features/helper/data/helper%20data%20source/calls_data_source.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_calls_history_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/inti_call_usecase.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/calls%20bloc/calls_bloc.dart';
import 'package:be_with_me_new_new/features/helper/presintation/pages/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/response/get_accepts_response_model.dart';
import '../../data/models/response/get_my_posts_response_model.dart';
import '../blocs/post bloc/post_bloc.dart';
import '../blocs/post bloc/post_events.dart';
import '../blocs/post bloc/post_states.dart';

class ShowPostsTab extends StatefulWidget {
  const ShowPostsTab({super.key});

  @override
  State<ShowPostsTab> createState() => _ShowPostsTabState();
}

class _ShowPostsTabState extends State<ShowPostsTab> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات الأولية عند فتح الشاشة
    context.read<PostBloc>().add(GetInitialDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is GetMyPostsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GetMyPostsError) {
          return Center(child: Text(state.message));
        } else if (state is GetMyPostsSuccess) {
          return _buildPostsList(context, state.response);
        }
        return const Center(child: Text('No posts available'));
      },
    );
  }

  Widget _buildPostsList(BuildContext context, List<GetMyPostsResponse> posts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildPostItem(context, posts[index]);
      },
    );
  }

  Widget _buildPostItem(BuildContext context, GetMyPostsResponse post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and delete
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('You',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${DateTime.now().difference(post.createdAt).inHours}h',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Delete action
                },
                child: const Text('Delete'),
              )
            ],
          ),
          const SizedBox(height: 10),
          // Post content
          Text(post.content),
          const SizedBox(height: 10),
          // Helpers + see all
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () => _showHelpersSheet(context),
                child: const Text(
                  'see all',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _showHelpersSheet(BuildContext context) {
    // استخدام البيانات المحملة مسبقاً
    final bloc = context.read<PostBloc>();
    if (bloc.cachedAccepts != null) {
      _showHelpersList(context, bloc.cachedAccepts!);
    } else {
      // كإحتياطي في حالة عدم وجود بيانات مخزنة
      bloc.add(GetAcceptsEvent());
      _showLoadingSheet(context);
    }
  }

  void _showLoadingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BlocBuilder<PostBloc, PostState>(
          buildWhen: (previous, current) =>
              current is GetAcceptsLoading ||
              current is GetAcceptsSuccess ||
              current is GetAcceptsError,
          builder: (context, state) {
            if (state is GetAcceptsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GetAcceptsError) {
              return Center(child: Text(state.message));
            } else if (state is GetAcceptsSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(context);
                _showHelpersList(context, state.response);
              });
              return const SizedBox.shrink();
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  void _showHelpersList(
      BuildContext context, List<GetAcceptsResponse> helpers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // نبقى نستخدمها للسماح بالتمرير
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height * 0.7, // تحديد أقصى ارتفاع
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(
            bottom: 20,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 5,
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: BeWithMeColors.mainColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                'Helpers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Flexible(
                // بدلاً من Expanded
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: helpers.length,
                  itemBuilder: (context, index) {
                    final helper = helpers[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          helper.profileImageUrl.isNotEmpty
                              ? "https://bewtihme-001-site1.jtempurl.com/${helper.profileImageUrl}"
                              : 'https://i.pravatar.cc/100',
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.call),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => CallsBloc(
                                    getCallsHistoryUseCase:
                                        GetCallsHistoryUseCase(
                                            callsRepository: CallsDataSource()),
                                    intiCallUsecase: IntiCallUsecase(
                                        callsRepository: CallsDataSource())),
                                child: EnhancedAgoraCallScreen(
                                  postId: helper.postId,
                                  acceptorId: helper.acceptorId,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      title: Text(helper.fullName),
                      subtitle: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(helper.rate.toStringAsFixed(1)),
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
}
