import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/data/models/ship/ship_model.dart';
import 'package:paperopoli_terminal/data/repositories/ships_repository.dart';

part 'ships_state.dart';

class ShipsCubit extends Cubit<ShipsState> {
  final ShipsRepository repository;

  ShipsCubit({
    required this.repository,
  }) : super(
          const ShipsInitial(),
        );

  Future<void> fetch({
    required User user,
  }) async {
    try {
      emit(
        const ShipsLoading(),
      );
      emit(
        ShipsLoaded(
          ships: await repository.fetch(
            user: user,
          ),
        ),
      );
    } on ServerException catch (e) {
      emit(
        ShipsError(e),
      );
    }
  }
}
