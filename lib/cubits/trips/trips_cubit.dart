import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:paperopoli_terminal/data/models/trip/trip_model.dart';
import 'package:paperopoli_terminal/data/repositories/trips_repository.dart';

part 'trips_state.dart';

class TripsCubit extends Cubit<TripsState> {
  final TripsRepository repository;

  TripsCubit({
    required this.repository,
  }) : super(
          const TripsInitial(),
        );

  Future<void> fetch({
    required User user,
  }) async {
    try {
      emit(
        const TripsLoading(),
      );
      emit(
        TripsLoaded(
          trips: await repository.fetch(
            user: user,
          ),
        ),
      );
    } on Exception catch (e) {
      emit(
        TripsError(e),
      );
    }
  }
}
