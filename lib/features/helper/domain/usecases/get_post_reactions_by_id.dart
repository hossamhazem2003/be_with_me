import 'package:be_with_me_new_new/features/helper/data/helper%20data%20source/posts_data_source.dart';
import 'package:be_with_me_new_new/features/helper/domain/entites/reactions_entity.dart';
import 'package:be_with_me_new_new/features/helper/domain/repositories/post_repository.dart';

class GetPostReactionsByIdUseCase {
  final PostRepository postsRepository = PostsDataSource();
  Future<List<ReactionsEntity>> call(String token, String postId) async {
    return postsRepository.getPostReactionsById(token, postId);
  }
}
