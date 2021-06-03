import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/data/models/operation/operation_model.dart';
import 'package:paperopoli_terminal/data/repositories/operations_repository.dart';

part 'operations_state.dart';

class OperationsCubit extends Cubit<OperationsState> {
  final OperationsRepository repository;

  OperationsCubit({
    required this.repository,
  }) : super(
          OperationsInitial(),
        );

  Future<void> fetch({
    required User user,
  }) async {
    try {
      emit(
        OperationsLoading(),
      );
      emit(
        OperationsLoaded(
          operations: await repository.fetch(
            user: user,
          ),
        ),
      );
    } on ServerException catch (e, _) {
      emit(
        OperationsError(e),
      );
    }
  }
}
