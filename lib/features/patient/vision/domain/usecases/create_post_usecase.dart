import 'package:be_with_me_new_new/features/patient/vision/data/datasource/post_datasource.dart';
import 'package:be_with_me_new_new/features/patient/vision/data/models/request/create_post_request.dart';
import 'package:be_with_me_new_new/features/patient/vision/data/models/response/create_post_response.dart';
import 'package:be_with_me_new_new/features/patient/vision/domain/repositories/post_repository.dart';

class CreatePostUseCase{
  PostRepository postRepository = PostDataSource();
  
  Future<CreatePostResponse> call(String token, CreatePostRequest request) async{
    return postRepository.createPost(token, request);
  }
}