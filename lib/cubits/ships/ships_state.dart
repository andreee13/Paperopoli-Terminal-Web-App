part of 'ships_cubit.dart';

@immutable
abstract class ShipsState {
  const ShipsState();
}

class ShipsInitial extends ShipsState {
  const ShipsInitial();

  @override
  String toString() => 'Initial';
}

class ShipsLoading extends ShipsState {
  const ShipsLoading();

  @override
  String toString() => 'Logging';
}

class ShipsLoaded extends ShipsState {
  final List<ShipModel> ships;

  const ShipsLoaded({
    required this.ships,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShipsLoaded && other.ships == ships;
  }

  @override
  int get hashCode => ships.hashCode;

  @override
  String toString() => 'Loaded';
}

class ShipsError extends ShipsState {
  final Exception exception;

  const ShipsError(
    this.exception,
  );
}
