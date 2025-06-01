import 'package:be_with_me_new_new/features/helper/domain/entites/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<Notification>> getNotifications(String token);
  Future<String> markAsRead(String token, int notificationId);
  Future<String> markAllAsRead(String token);
}