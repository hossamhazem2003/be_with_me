import 'dart:convert';
import 'dart:developer';

import 'package:be_with_me_new_new/features/helper/domain/entites/notification_entity.dart';
import 'package:be_with_me_new_new/features/helper/domain/repositories/notification_repository.dart';
import 'package:http/http.dart' as http;

class NotificationDataSource extends NotificationRepository{
  @override
  Future<List<Notification>> getNotifications(String token) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Host': 'bewtihme-001-site1.jtempurl.com',
      'Connection': 'keep-alive',
    };

    final url = Uri.parse('https://bewtihme-001-site1.jtempurl.com/api/Notification');

    final request = http.Request('GET', url);
    request.headers.addAll(headers);

    final response = await request.send();

    log(response.statusCode.toString());

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final List<dynamic> jsonList = json.decode(responseBody);
      return jsonList.map((e) => Notification.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch notifications: ${response.statusCode}');
    }
  }


  @override
  Future<String> markAsRead(String token, int notificationId) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Host': 'bewtihme-001-site1.jtempurl.com',
      'Connection': 'keep-alive',
    };

    final url = Uri.parse(
      'https://bewtihme-001-site1.jtempurl.com/api/Notification/$notificationId/mark-as-read',
    );

    final request = http.Request('PUT', url);
    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> jsonMap = json.decode(responseBody);
      return jsonMap['message'] ?? 'Success';
    } else {
      throw Exception('Failed to mark notification as read: ${response.statusCode}');
    }
  }

  @override
  Future<String> markAllAsRead(String token) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Host': 'bewtihme-001-site1.jtempurl.com',
      'Connection': 'keep-alive',
    };

    final url = Uri.parse('https://bewtihme-001-site1.jtempurl.com/api/Notification/mark-all-as-read');

    final request = http.Request('PUT', url);
    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> jsonMap = json.decode(responseBody);
      return jsonMap['message'] ?? 'All notifications marked as read';
    } else {
      throw Exception('Failed to mark all notifications as read: ${response.statusCode}');
    }
  }

}