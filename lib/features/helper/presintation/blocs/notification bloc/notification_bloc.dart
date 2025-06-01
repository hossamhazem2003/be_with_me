import 'dart:developer';

import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/mark_all_notification_as_read_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/mark_notification_read_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_notification_usecase.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/notification%20bloc/notification_events.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/notification%20bloc/notification_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationBloc extends Bloc<NotificationEvents, NotificationState> {
  final GetNotificationUseCase getNotificationUseCase;
  final MarkNotificationAsReadUseCase markNotificationReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;

  NotificationBloc({
    required this.getNotificationUseCase,
    required this.markNotificationReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
  }) : super(NotificationInitial()) {
    on<GetAllNotificationsEvent>(_handleGetAllNotifications);
    on<MarkNotificationAsReadEvent>(_handleMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_handleMarkAllNotificationsAsRead);
  }

  Future<void> _handleGetAllNotifications(GetAllNotificationsEvent event, Emitter<NotificationState> emit) async {
    try {
      emit(NotificationLoading());
      final token = SharedPreferencesManager.getToken();
      log(token!);
      final notifications = await getNotificationUseCase.call(token!);
      emit(NotificationLoaded(notifications));
    } catch (e) {
      log(e.toString());
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _handleMarkNotificationAsRead(MarkNotificationAsReadEvent event, Emitter<NotificationState> emit) async {
    try {
      emit(MarkAsReadLoading());
      String? token = SharedPreferencesManager.getToken();
      final message = await markNotificationReadUseCase.call(token!, event.notificationId);
      emit(MarkAsReadSuccess(message));
    } catch (e) {
      emit(MarkAsReadError(e.toString()));
    }
  }

  Future<void> _handleMarkAllNotificationsAsRead(MarkAllNotificationsAsReadEvent event, Emitter<NotificationState> emit) async {
    try {
      emit(MarkAllAsReadLoading());
      String? token = SharedPreferencesManager.getToken();
      final message = await markAllNotificationsAsReadUseCase.call(token!);
      emit(MarkAllAsReadSuccess(message));
    } catch (e) {
      emit(MarkAllAsReadError(e.toString()));
    }
  }
}