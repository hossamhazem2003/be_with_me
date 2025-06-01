abstract class PostsEvent {}

class GetAllPostsEvent extends PostsEvent {
  final String token;

  GetAllPostsEvent({
    required this.token,
  });
}

class GetPostReactionsByIdEvent extends PostsEvent {
  final String token;
  final String postId;
  GetPostReactionsByIdEvent({
    required this.token,
    required this.postId,
  });
}

class AcceptPostEvent extends PostsEvent{
  String postId;
  AcceptPostEvent({required this.postId});
}