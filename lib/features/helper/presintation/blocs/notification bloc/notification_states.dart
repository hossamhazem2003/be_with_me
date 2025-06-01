import 'package:be_with_me_new_new/features/helper/domain/entites/notification_entity.dart';

abstract class NotificationState {}

// الحالة الأولية
class NotificationInitial extends NotificationState {}

// حالة تحميل الإشعارات
class NotificationLoading extends NotificationState {}

// حالة نجاح جلب الإشعارات
class NotificationLoaded extends NotificationState {
  final List<Notification> notifications;

  NotificationLoaded(this.notifications);
}

// حالة فشل جلب الإشعارات
class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

// حالة وضع علامة "مقروء" على إشعار
class MarkAsReadLoading extends NotificationState {}

// حالة نجاح وضع علامة "مقروء" على إشعار
class MarkAsReadSuccess extends NotificationState {
  final String message;

  MarkAsReadSuccess(this.message);
}

// حالة فشل وضع علامة "مقروء" على إشعار
class MarkAsReadError extends NotificationState {
  final String message;

  MarkAsReadError(this.message);
}

// حالة وضع علامة "مقروء" على جميع الإشعارات
class MarkAllAsReadLoading extends NotificationState {}

// حالة نجاح وضع علامة "مقروء" على جميع الإشعارات
class MarkAllAsReadSuccess extends NotificationState {
  final String message;

  MarkAllAsReadSuccess(this.message);
}

// حالة فشل وضع علامة "مقروء" على جميع الإشعارات
class MarkAllAsReadError extends NotificationState {
  final String message;

  MarkAllAsReadError(this.message);
}