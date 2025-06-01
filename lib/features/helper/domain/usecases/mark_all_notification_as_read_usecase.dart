import 'package:be_with_me_new_new/features/helper/data/helper%20data%20source/notification_data_source.dart';
import 'package:be_with_me_new_new/features/helper/domain/repositories/notification_repository.dart';

class MarkAllNotificationsAsReadUseCase{
  NotificationRepository notificationRepository = NotificationDataSource();
  
  Future<String> call(String token) async{
    return await notificationRepository.markAllAsRead(token);
  }
}