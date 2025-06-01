import 'package:be_with_me_new_new/features/helper/data/models/response/get_posts_response_model.dart';
import 'package:be_with_me_new_new/features/helper/domain/entites/reactions_entity.dart';

abstract class PostsState {}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsError extends PostsState {
  final String message;
  PostsError({required this.message});
}

class GetAllPostsSuccess extends PostsState {
  final List<GetPostsResponseModel> posts;
  GetAllPostsSuccess({required this.posts});
}

class LoadingReactions extends PostsState {
  final List<GetPostsResponseModel> currentPosts;
  LoadingReactions({required this.currentPosts});
}

class GetPostReactionsByIdSuccess extends PostsState {
  final List<ReactionsEntity> reactions;
  final List<GetPostsResponseModel> currentPosts;
  GetPostReactionsByIdSuccess(
      {required this.reactions, required this.currentPosts});
}

class GetPostReactionsByIdError extends PostsState {
  final String message;
  final List<GetPostsResponseModel> currentPosts;
  GetPostReactionsByIdError(
      {required this.message, required this.currentPosts});
}

class AcceptPostSuccess extends PostsState{
  final List<GetPostsResponseModel> posts;
  AcceptPostSuccess({required this.posts});
}

class AcceptPostLoading extends PostsState{}