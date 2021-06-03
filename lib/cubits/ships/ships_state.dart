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
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ShipsLoaded && o.ships == ships;
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
