import '../../data/models/response/get_posts_response_model.dart';
import '../entites/reactions_entity.dart';

abstract class PostRepository {
  Future<List<GetPostsResponseModel>> getAllPosts(String token);
  Future<List<ReactionsEntity>> getPostReactionsById(
      String token, String postId);
  Future<void> acceptPost(String token, String postId,String helperId);
}
