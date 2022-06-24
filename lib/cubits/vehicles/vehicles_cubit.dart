import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/data/models/vehicle/vehicle_model.dart';
import 'package:paperopoli_terminal/data/repositories/vehicles_repository.dart';

part 'vehicles_state.dart';

class VehiclesCubit extends Cubit<VehiclesState> {
  final VehiclesRepository repository;

  VehiclesCubit({
    required this.repository,
  }) : super(
          const VehiclesInitial(),
        );

  Future<void> fetch({
    required User user,
  }) async {
    try {
      emit(
        const VehiclesLoading(),
      );
      emit(
        VehiclesLoaded(
          vehicles: await repository.fetch(
            user: user,
          ),
        ),
      );
    } on ServerException catch (e) {
      emit(
        VehiclesError(e),
      );
    }
  }
}
