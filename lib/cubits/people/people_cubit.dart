import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/data/models/person/person_model.dart';
import 'package:paperopoli_terminal/data/repositories/people_repository.dart';

part 'people_state.dart';

class PeopleCubit extends Cubit<PeopleState> {
  final PeopleRepository repository;

  PeopleCubit({
    required this.repository,
  }) : super(
          PeopleInitial(),
        );

  Future<void> fetch({
    required User user,
  }) async {
    try {
      emit(
        PeopleLoading(),
      );
      emit(
        PeopleLoaded(
          people: await repository.fetch(
            user: user,
          ),
        ),
      );
    } on ServerException catch (e, _) {
      emit(
        PeopleError(e),
      );
    }
  }
}
