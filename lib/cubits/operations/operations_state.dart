part of 'operations_cubit.dart';

@immutable
abstract class OperationsState {
  const OperationsState();
}

class OperationsInitial extends OperationsState {
  const OperationsInitial();

  @override
  String toString() => 'Initial';
}

class OperationsLoading extends OperationsState {
  const OperationsLoading();

  @override
  String toString() => 'Logging';
}

class OperationsLoaded extends OperationsState {
  final List<OperationModel> operations;

  const OperationsLoaded({
    required this.operations,
  });

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is OperationsLoaded && o.operations == operations;
  }

  @override
  int get hashCode => operations.hashCode;

  @override
  String toString() => 'Loaded';
}

class OperationsError extends OperationsState {
  final Exception exception;

  const OperationsError(
    this.exception,
  );
}
