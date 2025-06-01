import 'package:be_with_me_new_new/features/patient/vision/data/datasource/post_datasource.dart';
import 'package:be_with_me_new_new/features/patient/vision/data/models/response/get_accepts_response_model.dart';
import 'package:be_with_me_new_new/features/patient/vision/domain/repositories/post_repository.dart';

class GetAcceptsUseCase {
  PostRepository postRepository = PostDataSource();

  Future<List<GetAcceptsResponse>> call(String token) async{
    return await postRepository.getAccepts(token);
  }
}