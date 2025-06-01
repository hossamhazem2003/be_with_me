import 'dart:developer';

import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
import 'package:be_with_me_new_new/features/helper/data/models/response/get_calls_history_response_model.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_notification_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/mark_all_notification_as_read_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/mark_notification_read_usecase.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/calls%20bloc/calls_bloc.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/calls%20bloc/calls_states.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/notification%20bloc/notification_bloc.dart';
import 'package:be_with_me_new_new/features/helper/presintation/pages/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/calls bloc/call_events.dart';

class CallsHistoryScreen extends StatefulWidget {
  const CallsHistoryScreen({super.key});

  @override
  State<CallsHistoryScreen> createState() => _CallsHistoryScreenState();
}

class _CallsHistoryScreenState extends State<CallsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final userId = SharedPreferencesManager.getUserId();
    if (userId != null) {
      context.read<CallsBloc>().add(GetCallsHistoryEvent());
    } else {
      log('User ID is null!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeWithMeColors.backGroundColor,
      appBar: AppBar(
        backgroundColor: BeWithMeColors.mainColor,
        title:
            const Text('Call History', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => NotificationBloc(
                        getNotificationUseCase: GetNotificationUseCase(),
                        markNotificationReadUseCase:
                            MarkNotificationAsReadUseCase(),
                        markAllNotificationsAsReadUseCase:
                            MarkAllNotificationsAsReadUseCase(),
                      ),
                      child: const NotificationsScreen(),
                    ),
                  ));
            },
          ),
        ],
      ),
      body: BlocBuilder<CallsBloc, CallsStates>(
        builder: (context, state) {
          log('Current State: $state');
          if (state is CallsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CallsError) {
            log(state.message);
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is GetCallsHistorySuccess) {
            if (state.callsHistory.isEmpty) {
              return const Center(child: Text('No call history found.'));
            }
            return _buildCallHistoryList(state.callsHistory);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildCallHistoryList(List<GetCallHistoryResponseModel> calls) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: calls.length,
              itemBuilder: (context, index) {
                final call = calls[index];
                log(call.callee.pictureUrl);
                final isCurrentUserCaller =
                    call.caller.id == SharedPreferencesManager.getUserId();
                final otherUser =
                    isCurrentUserCaller ? call.callee : call.caller;
                final callType = isCurrentUserCaller ? 'Outgoing' : 'Incoming';

                return _buildCallItem(
                  context,
                  otherUser,
                  call.startTime,
                  call.duration,
                  callType,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: BeWithMeColors.mainColor),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search calls',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: BeWithMeColors.mainColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCallItem(
    BuildContext context,
    CallUser user,
    DateTime callTime,
    double duration,
    String callType,
  ) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle call item tap
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                    'https://bewtihme-001-site1.jtempurl.com/${user.pictureUrl}'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy - hh:mm a').format(callTime),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        callType == 'Incoming'
                            ? Icons.call_received
                            : Icons.call_made,
                        color: callType == 'Incoming'
                            ? Colors.green
                            : BeWithMeColors.mainColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        callType,
                        style: TextStyle(
                          color: callType == 'Incoming'
                              ? Colors.green
                              : BeWithMeColors.mainColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$secs';
    } else {
      return '$minutes:$secs';
    }
  }
}
