import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
import 'package:be_with_me_new_new/features/patient/vision/domain/usecases/create_post_usecase.dart';
import 'package:be_with_me_new_new/features/patient/vision/domain/usecases/get_accepts_usecase.dart';
import 'package:be_with_me_new_new/features/patient/vision/domain/usecases/get_my_posts_usecase.dart';
import 'package:be_with_me_new_new/features/patient/vision/presentation/blocs/post%20bloc/post_events.dart';
import 'package:be_with_me_new_new/features/patient/vision/presentation/blocs/post%20bloc/post_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/response/get_accepts_response_model.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final CreatePostUseCase createPostUseCase;
  final GetMyPostsUseCase getMyPostsUseCase;
  final GetAcceptsUseCase getAcceptsUseCase;
  List<GetAcceptsResponse>? cachedAccepts;


  PostBloc({
    required this.createPostUseCase,
    required this.getMyPostsUseCase,
    required this.getAcceptsUseCase,
  }) : super(PostInitState()) {
    on<CreatePostEvent>(_createPost);
    on<GetInitialDataEvent>(_getInitialData);
    on<GetAcceptsEvent>(_getAccepts);
  }

  Future<void> _createPost(CreatePostEvent event, Emitter<PostState> emit) async {
    try {
      emit(CreatePostLoading());
      final token = SharedPreferencesManager.getToken();
      final response = await createPostUseCase.call(token!, event.request);
      emit(CreatePostSuccess(response: response));
    } catch (e) {
      emit(CreatePostError(message: e.toString()));
    }
  }

  Future<void> _getInitialData(GetInitialDataEvent event, Emitter<PostState> emit) async {
    try {
      emit(GetMyPostsLoading());
      final token = SharedPreferencesManager.getToken();

      // تحميل المنشورات
      final posts = await getMyPostsUseCase.call(token!);

      // تحميل المساعدين
      final accepts = await getAcceptsUseCase.call(token);
      cachedAccepts = accepts;

      emit(GetMyPostsSuccess(response: posts));
    } catch (e) {
      emit(GetMyPostsError(message: e.toString()));
    }
  }


  Future<void> _getMyPosts(GetMyPostsEvent event, Emitter<PostState> emit) async {
    try {
      emit(GetMyPostsLoading());
      final token = SharedPreferencesManager.getToken();
      final posts = await getMyPostsUseCase.call(token!);
      emit(GetMyPostsSuccess(response: posts));
    } catch (e) {
      emit(GetMyPostsError(message: e.toString()));
    }
  }

  Future<void> _getAccepts(GetAcceptsEvent event, Emitter<PostState> emit) async {
    try {
      if (cachedAccepts != null) {
        emit(GetAcceptsSuccess(response: cachedAccepts!));
        return;
      }

      emit(GetAcceptsLoading());
      final token = SharedPreferencesManager.getToken();
      final accepts = await getAcceptsUseCase.call(token!);
      cachedAccepts = accepts;
      emit(GetAcceptsSuccess(response: accepts));
    } catch (e) {
      emit(GetAcceptsError(message: e.toString()));
    }
  }
}


