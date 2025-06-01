import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
import 'package:be_with_me_new_new/features/helper/data/models/response/get_calls_history_response_model.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_notification_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/mark_all_notification_as_read_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/mark_notification_read_usecase.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/calls%20bloc/call_events.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/calls%20bloc/calls_bloc.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/calls%20bloc/calls_states.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/notification%20bloc/notification_bloc.dart';
import 'package:be_with_me_new_new/features/helper/presintation/pages/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PeopleScreen extends StatelessWidget {
  PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Treated Patients",
            style: TextStyle(color: Colors.white)),
        backgroundColor: BeWithMeColors.mainColor,
        leading: Container(),
        centerTitle: true,
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
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CallsBloc, CallsStates>(
        builder: (context, state) {
          if (state is CallsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CallsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is GetCallsHistorySuccess) {
            return _buildPeopleGrid(state.callsHistory);
          } else {
            // Trigger loading calls history if not already loaded
            final userId = SharedPreferencesManager.getUserId();
            if (userId != null) {
              context.read<CallsBloc>().add(GetCallsHistoryEvent());
            }
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildPeopleGrid(List<GetCallHistoryResponseModel> callsHistory) {
    // Extract unique users from calls history
    final userId = SharedPreferencesManager.getUserId();
    final Set<CallUser> uniqueUsers = {};

    for (var call in callsHistory) {
      if (call.caller.id != userId) {
        uniqueUsers.add(call.caller);
      }
      if (call.callee.id != userId) {
        uniqueUsers.add(call.callee);
      }
    }

    if (uniqueUsers.isEmpty) {
      return const Center(child: Text('No contacts found.'));
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(
                  Icons.search,
                  color: BeWithMeColors.mainColor,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.filter_list,
                    color: BeWithMeColors.mainColor,
                  ),
                  onPressed: () {},
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Grid of People
          Expanded(
            child: GridView.builder(
              itemCount: uniqueUsers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1, // Square items
              ),
              itemBuilder: (context, index) {
                final user = uniqueUsers.elementAt(index);
                return _buildPersonCard(
                  user.fullName,
                  'https://bewtihme-001-site1.jtempurl.com/${user.pictureUrl}',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(String name, String imageUrl) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        // More options icon at the top-right
        Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
