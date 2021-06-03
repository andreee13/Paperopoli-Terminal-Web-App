import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:paperopoli_terminal/data/models/trip/trip_model.dart';
import 'package:paperopoli_terminal/data/repositories/trips_repository.dart';

part 'trips_state.dart';

class TripsCubit extends Cubit<TripsState> {
  final TripsRepository repository;

  TripsCubit({
    required this.repository,
  }) : super(
          TripsInitial(),
        );

  Future<void> fetch({
    required User user,
  }) async {
    try {
      emit(
        TripsLoading(),
      );
      emit(
        TripsLoaded(
          trips: await repository.fetch(
            user: user,
          ),
        ),
      );
    } on Exception catch (e, _) {
      emit(
        TripsError(e),
      );
    }
  }
}
