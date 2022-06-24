import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/data/models/person/person_model.dart';
import 'package:paperopoli_terminal/data/repositories/people_repository.dart';

part 'people_state.dart';

class PeopleCubit extends Cubit<PeopleState> {
  final PeopleRepository repository;

  PeopleCubit({
    required this.repository,
  }) : super(
          const PeopleInitial(),
        );

  Future<void> fetch({
    required User user,
  }) async {
    try {
      emit(
        const PeopleLoading(),
      );
      emit(
        PeopleLoaded(
          people: await repository.fetch(
            user: user,
          ),
        ),
      );
    } on ServerException catch (e) {
      emit(
        PeopleError(e),
      );
    }
  }
}
