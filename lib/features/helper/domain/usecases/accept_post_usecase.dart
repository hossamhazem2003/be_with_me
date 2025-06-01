import 'package:be_with_me_new_new/features/helper/data/helper%20data%20source/posts_data_source.dart';
import 'package:be_with_me_new_new/features/helper/domain/repositories/post_repository.dart';

class AcceptPostUseCase {
  final PostRepository postRepository = PostsDataSource();

  Future<void> call(String token,String postId,String helperId) async {
    return await postRepository.acceptPost(token, postId,helperId);
  }
}