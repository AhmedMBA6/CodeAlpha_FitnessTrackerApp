import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_profile_model.dart';
import '../../data/repos/user_profile_repository.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserProfileRepository _repository;

  UserProfileCubit(this._repository) : super(UserProfileInitial());

  Future<void> saveProfile(UserProfileModel profile) async {
    emit(UserProfileLoading());
    try {
      await _repository.saveProfile(profile);
      emit(UserProfileSuccess());
    } catch (e, stack) {
      debugPrint('❌ Save profile failed: $e');
      debugPrint('📍 StackTrace: $stack');
      emit(UserProfileError(e.toString()));
    }
  }
}
