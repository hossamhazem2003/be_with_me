
abstract class NotificationEvents{}

class GetAllNotificationsEvent extends NotificationEvents {}

class MarkNotificationAsReadEvent extends NotificationEvents {
  final int notificationId;

  MarkNotificationAsReadEvent({required this.notificationId});
}

class MarkAllNotificationsAsReadEvent extends NotificationEvents {}