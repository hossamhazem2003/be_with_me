import 'package:be_with_me_new_new/features/helper/data/helper%20data%20source/posts_data_source.dart';
import 'package:be_with_me_new_new/features/helper/data/models/response/get_posts_response_model.dart';
import 'package:be_with_me_new_new/features/helper/domain/repositories/post_repository.dart';

class GetAllPostsUsecase {
  final PostRepository postsRepository = PostsDataSource();

  Future<List<GetPostsResponseModel>> call(String token) async {
    return postsRepository.getAllPosts(token);
  }
}
