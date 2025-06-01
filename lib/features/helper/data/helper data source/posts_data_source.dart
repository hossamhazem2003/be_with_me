import 'dart:convert';
import 'dart:developer';

import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
import 'package:be_with_me_new_new/features/helper/data/models/response/get_posts_response_model.dart';
import 'package:be_with_me_new_new/features/helper/domain/entites/reactions_entity.dart';
import 'package:http/http.dart' as http;

import '../../domain/repositories/post_repository.dart';

class PostsDataSource extends PostRepository {
  @override
  Future<List<GetPostsResponseModel>> getAllPosts(String token) async {
    try {
      final uri = Uri.parse('https://bewtihme-001-site1.jtempurl.com/api/Post');

      var headers = {
        'Authorization': 'Bearer $token',
        'Host': 'bewtihme-001-site1.jtempurl.com',
        'Connection': 'keep-alive',
      };

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(responseBody) as List;
        return GetPostsResponseModel.fromJsonList(jsonList);
      } else {
        throw Exception('فشل في تحميل المنشورات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في جلب المنشورات: $e');
    }
  }

  @override
  Future<List<ReactionsEntity>> getPostReactionsById(
      String token, String postId) async {
    try {
      final uri = Uri.parse(
          'https://bewtihme-001-site1.jtempurl.com/api/Post/$postId/reactions');

      var headers = {
        'Authorization': 'Bearer $token',
        'Host': 'bewtihme-001-site1.jtempurl.com',
        'Connection': 'keep-alive',
      };

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(responseBody) as List;
        return ReactionsEntity.fromJsonList(jsonList);
      } else {
        throw Exception('فشل في تحميل المنشورات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في جلب المنشورات: $e');
    }
  }

  @override
  Future<void> acceptPost(String token, String postId,String helperId) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Host': 'bewtihme-001-site1.jtempurl.com',
      'Connection': 'keep-alive',
    };


    var request = http.Request('POST', Uri.parse('https://bewtihme-001-site1.jtempurl.com/api/Helper/$postId/Accept-Post'));
    request.body = json.encode({
      "requestAcceptorId": helperId
    });
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        return;
      } else {
        print(response.reasonPhrase);
        throw Exception('Failed to accept post: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error accepting post: $e');
      throw Exception('Error accepting post: $e');
    }}
}
