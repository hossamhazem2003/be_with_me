import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/notification%20bloc/notification_bloc.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/notification%20bloc/notification_events.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/notification%20bloc/notification_states.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch all notifications when the screen starts
    context.read<NotificationBloc>().add(GetAllNotificationsEvent());
  }

  // Get icon based on notification type
  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return Icons.calendar_today;
      case 'message':
        return Icons.message;
      case 'reminder':
        return Icons.alarm;
      case 'alert':
        return Icons.warning_amber;
      case 'update':
        return Icons.update;
      default:
        return Icons.notifications;
    }
  }

  // Get color based on notification type
  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return Colors.blue;
      case 'message':
        return Colors.green;
      case 'reminder':
        return Colors.orange;
      case 'alert':
        return Colors.red;
      case 'update':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Format date to a readable format
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeWithMeColors.backGroundColor,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: BeWithMeColors.mainColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            )),
        actions: [
          // Mark all as read button
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded) {
                bool hasUnread = state.notifications
                    .any((notification) => !notification.isRead);
                return IconButton(
                  icon: const Icon(Icons.mark_email_read, color: Colors.white),
                  tooltip: 'Mark all as read',
                  onPressed: hasUnread
                      ? () {
                          context
                              .read<NotificationBloc>()
                              .add(MarkAllNotificationsAsReadEvent());
                        }
                      : null,
                );
              }
              return IconButton(
                icon: const Icon(Icons.mark_email_read),
                onPressed: null,
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          // Handle success and error states
          if (state is MarkAsReadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
            context.read<NotificationBloc>().add(GetAllNotificationsEvent());
          } else if (state is MarkAsReadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else if (state is MarkAllAsReadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
            context.read<NotificationBloc>().add(GetAllNotificationsEvent());
          } else if (state is MarkAllAsReadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading ||
              state is MarkAsReadLoading ||
              state is MarkAllAsReadLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }

            // Group notifications by date
            Map<String, List<dynamic>> groupedNotifications = {};
            for (var notification in state.notifications) {
              final date =
                  DateFormat('MMM d, yyyy').format(notification.createdAt);
              if (!groupedNotifications.containsKey(date)) {
                groupedNotifications[date] = [];
              }
              groupedNotifications[date]!.add(notification);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<NotificationBloc>()
                    .add(GetAllNotificationsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: groupedNotifications.keys.length,
                itemBuilder: (context, index) {
                  final date = groupedNotifications.keys.elementAt(index);
                  final notifications = groupedNotifications[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          date,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ...notifications.map((notification) =>
                          _buildNotificationItem(notification)),
                      if (index < groupedNotifications.keys.length - 1)
                        const Divider(height: 16, thickness: 0.5),
                    ],
                  );
                },
              ),
            );
          } else if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<NotificationBloc>()
                          .add(GetAllNotificationsEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            return _buildEmptyState();
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you receive notifications, they will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<NotificationBloc>().add(GetAllNotificationsEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(notification) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check_circle, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Mark as read
          context.read<NotificationBloc>().add(
                MarkNotificationAsReadEvent(notificationId: notification.id),
              );
          return false;
        } else {
          // Here you could add a delete notification event if needed
          return false;
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: notification.profileImageUrl.isNotEmpty
                    ? NetworkImage(
                        "https://bewtihme-001-site1.jtempurl.com/${notification.profileImageUrl}")
                    : null,
                child: notification.profileImageUrl.isEmpty
                    ? Icon(Icons.person, color: Colors.grey[400])
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.patientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notification.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    notification.type,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getNotificationColor(notification.type),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          trailing: !notification.isRead
              ? IconButton(
                  icon: const Icon(Icons.mark_email_read, color: Colors.blue),
                  tooltip: 'Mark as read',
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                          MarkNotificationAsReadEvent(
                              notificationId: notification.id),
                        );
                  },
                )
              : null,
          onTap: () {
            // Handle notification tap
            if (!notification.isRead) {
              context.read<NotificationBloc>().add(
                    MarkNotificationAsReadEvent(
                        notificationId: notification.id),
                  );
            }
            // Add navigation or action based on notification type
          },
        ),
      ),
    );
  }
}
