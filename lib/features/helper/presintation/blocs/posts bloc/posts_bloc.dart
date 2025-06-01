import 'dart:developer';

import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
import 'package:be_with_me_new_new/features/helper/data/models/response/get_posts_response_model.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/accept_post_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_post_reactions_by_id.dart';
import 'package:bloc/bloc.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_all_posts_usecase.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/posts%20bloc/posts_events.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/posts%20bloc/posts_states.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetAllPostsUsecase getAllPostsUseCase;
  final GetPostReactionsByIdUseCase getPostReactionsByIdUseCase;
  final AcceptPostUseCase acceptPostUseCase;

  List<GetPostsResponseModel> _currentPosts = [];

  PostsBloc({
    required this.getAllPostsUseCase,
    required this.getPostReactionsByIdUseCase,
    required this.acceptPostUseCase
  }) : super(PostsInitial()) {
    on<GetAllPostsEvent>(_handleGetAllPosts);
    on<GetPostReactionsByIdEvent>(_handleGetPostReactionsById);
    on<AcceptPostEvent>(_handleAcceptPost);
  }

  List<GetPostsResponseModel> get currentPosts => _currentPosts;

  Future<void> _handleGetAllPosts(
      GetAllPostsEvent event, Emitter<PostsState> emit) async {
    try {
      emit(PostsLoading());
      final posts = await getAllPostsUseCase(event.token);
      _currentPosts = posts;
      emit(GetAllPostsSuccess(posts: posts));
    } catch (e) {
      emit(PostsError(message: e.toString()));
    }
  }

  Future<void> _handleGetPostReactionsById(
      GetPostReactionsByIdEvent event, Emitter<PostsState> emit) async {
    try {
      emit(LoadingReactions(currentPosts: _currentPosts));
      final reactions =
      await getPostReactionsByIdUseCase(event.token, event.postId);
      emit(GetPostReactionsByIdSuccess(
          reactions: reactions, currentPosts: _currentPosts));
    } catch (e) {
      emit(GetPostReactionsByIdError(
          message: e.toString(), currentPosts: _currentPosts));
    }
  }

  Future<void> _handleAcceptPost(
      AcceptPostEvent event, Emitter<PostsState> emit) async {
    try {
      emit(AcceptPostLoading());
      final token = SharedPreferencesManager.getToken();
      log(token!);
      final userId = SharedPreferencesManager.getUserId();
      log(userId ?? 'no id');
      await acceptPostUseCase.call(token!, event.postId,userId!);

      // إعادة تحميل البيانات بعد النجاح
      final refreshedPosts = await getAllPostsUseCase(token);
      _currentPosts = refreshedPosts;
      emit(AcceptPostSuccess(posts: refreshedPosts));
    } catch (e) {
      log(e.toString());
      emit(PostsError(message: e.toString()));
    }
  }
}