
import 'dart:convert';
import 'dart:developer';

import 'package:be_with_me_new_new/features/patient/vision/data/models/request/create_post_request.dart';

import 'package:be_with_me_new_new/features/patient/vision/data/models/response/create_post_response.dart';
import 'package:be_with_me_new_new/features/patient/vision/data/models/response/get_accepts_response_model.dart';
import 'package:be_with_me_new_new/features/patient/vision/data/models/response/get_my_posts_response_model.dart';
import 'package:http/http.dart' as http;

import '../../domain/repositories/post_repository.dart';

class PostDataSource extends PostRepository{
  String baseUrl = "https://bewtihme-001-site1.jtempurl.com/api";
  @override
  Future<CreatePostResponse> createPost(String token, CreatePostRequest requestModel) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Host': 'bewtihme-001-site1.jtempurl.com',
      'Connection': 'keep-alive',
    };

    final url = Uri.parse('$baseUrl/Post/Create');

    final request = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = json.encode(requestModel.toJson());

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final decodedJson = json.decode(responseBody) as Map<String, dynamic>;
      return CreatePostResponse.fromJson(decodedJson);
    } else {
      throw Exception('Failed to create post: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  @override
  Future<List<GetMyPostsResponse>> getMyPosts(String token) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Host': 'bewtihme-001-site1.jtempurl.com',
      'Connection': 'keep-alive',
    };

    final url = Uri.parse('$baseUrl/Post/MyPosts');
    log(url.toString());

    final request = http.Request('GET', url);
    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final List<dynamic> decodedJson = json.decode(responseBody);

      return decodedJson
          .map((item) => GetMyPostsResponse.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to get posts: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  @override
  Future<List<GetAcceptsResponse>> getAccepts(String token) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Host': 'bewtihme-001-site1.jtempurl.com',
      'Connection': 'keep-alive',
    };

    final url = Uri.parse('https://bewtihme-001-site1.jtempurl.com/api/Post/6/reactions');

    final request = http.Request('GET', url);
    log(request.body);
    request.headers.addAll(headers);

    final response = await request.send();

    log(response.toString());

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final List<dynamic> decodedJson = json.decode(responseBody);

      return decodedJson.map((item) => GetAcceptsResponse.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get accepts: ${response.statusCode} ${response.reasonPhrase}');
    }
  }
  
}