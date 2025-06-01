import 'package:be_with_me_new_new/features/patient/vision/data/models/response/create_post_response.dart';
import 'package:be_with_me_new_new/features/patient/vision/data/models/response/get_my_posts_response_model.dart';

import '../../../data/models/response/get_accepts_response_model.dart';

abstract class PostState{}

class PostInitState extends PostState{}

class CreatePostSuccess extends PostState{
  CreatePostResponse response;
  CreatePostSuccess({required this.response});
}

class CreatePostError extends PostState{
  String message;
  CreatePostError({required this.message});
}

class CreatePostLoading extends PostState{}

class GetMyPostsSuccess extends PostState{
  List<GetMyPostsResponse> response;
  GetMyPostsSuccess({required this.response});
}

class GetMyPostsLoading extends PostState{}

class GetMyPostsError extends PostState{
  String message;
  GetMyPostsError({required this.message});
}

class GetAcceptsSuccess extends PostState{
  List<GetAcceptsResponse> response;
  GetAcceptsSuccess({required this.response});
}

class GetAcceptsLoading extends PostState{}

class GetAcceptsError extends PostState{
  String message;
  GetAcceptsError({required this.message});
}

