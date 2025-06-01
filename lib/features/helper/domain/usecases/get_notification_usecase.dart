import 'package:be_with_me_new_new/features/helper/data/helper%20data%20source/notification_data_source.dart';
import 'package:be_with_me_new_new/features/helper/domain/entites/notification_entity.dart';
import 'package:be_with_me_new_new/features/helper/domain/repositories/notification_repository.dart';

class GetNotificationUseCase{
  NotificationRepository notificationRepository = NotificationDataSource();
  
  Future<List<Notification>> call(String token) async{
    return await notificationRepository.getNotifications(token);
  }
}