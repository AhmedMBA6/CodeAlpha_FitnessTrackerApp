import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_profile_model.dart';
import '../../data/repos/user_profile_repository.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/di.dart';

part 'user_profile_state.dart';

/// Cubit for managing user profile state and actions.
class UserProfileCubit extends Cubit<UserProfileState> {
  final UserProfileRepository _repository = getIt<UserProfileRepository>();

  /// Creates an [UserProfileCubit].
  UserProfileCubit() : super(UserProfileInitial());

  /// Saves the user [profile] and emits loading/success/error states.
  Future<void> saveProfile(UserProfileModel profile) async {
    if (isClosed) return;
    emit(UserProfileLoading());
    try {
      await _repository.saveProfile(profile);
      if (!isClosed) {
        emit(UserProfileSuccess());
      }
    } catch (e, stack) {
      debugPrint(' [31mSave profile failed: $e');
      debugPrint(' [33mStackTrace: $stack');
      if (!isClosed) {
        emit(UserProfileError('Could not save profile. Please try again.'));
      }
    }
  }

  /// Fetches the user profile for the given uid and emits loading/loaded/error states.
  Future<void> getProfile(String uid) async {
    if (isClosed) return;
    emit(UserProfileLoading());
    try {
      final profile = await _repository.getProfile(uid);
      if (profile != null) {
        if (!isClosed) {
          emit(UserProfileLoaded(profile));
        }
      } else {
        if (!isClosed) {
          emit(UserProfileError('Profile not found.'));
        }
      }
    } catch (e, stack) {
      debugPrint(' [31mFetch profile failed: $e');
      debugPrint(' [33mStackTrace: $stack');
      if (!isClosed) {
        emit(UserProfileError('Could not fetch profile. Please try again.'));
      }
    }
  }
}
