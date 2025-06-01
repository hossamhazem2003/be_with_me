import 'package:be_with_me_new_new/features/patient/vision/data/models/request/create_post_request.dart';
import 'package:be_with_me_new_new/features/patient/vision/data/models/response/create_post_response.dart';

import '../../data/models/response/get_accepts_response_model.dart';
import '../../data/models/response/get_my_posts_response_model.dart';

abstract class PostRepository{
  Future<CreatePostResponse> createPost(String token, CreatePostRequest request);
  Future<List<GetMyPostsResponse>> getMyPosts(String token);
  Future<List<GetAcceptsResponse>> getAccepts(String token);
}