import 'package:be_with_me_new_new/features/helper/domain/entites/author_post_entity.dart';

class GetPostsResponseModel {
  final int id;
  final String content;
  final AuthorModel author;
  final int reactionsCount;

  GetPostsResponseModel({
    required this.id,
    required this.content,
    required this.author,
    required this.reactionsCount,
  });

  factory GetPostsResponseModel.fromJson(Map<String, dynamic> json) {
    return GetPostsResponseModel(
      id: json['id'],
      content: json['content'],
      author: AuthorModel.fromJson(json['author']),
      reactionsCount: json['reactionsCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author.toJson(),
      'reactionsCount': reactionsCount,
    };
  }

  static List<GetPostsResponseModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => GetPostsResponseModel.fromJson(json))
        .toList();
  }
}
