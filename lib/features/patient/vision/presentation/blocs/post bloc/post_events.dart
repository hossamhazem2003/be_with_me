import 'package:be_with_me_new_new/features/patient/vision/data/models/request/create_post_request.dart';

abstract class PostEvent{}

class CreatePostEvent extends PostEvent{
  CreatePostRequest request;
  CreatePostEvent({required this.request});
}

class GetMyPostsEvent extends PostEvent{}
class GetInitialDataEvent extends PostEvent{}
class GetAcceptsEvent extends PostEvent{}
