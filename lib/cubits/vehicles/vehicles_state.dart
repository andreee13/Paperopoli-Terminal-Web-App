part of 'vehicles_cubit.dart';

@immutable
abstract class VehiclesState {
  const VehiclesState();
}

class VehiclesInitial extends VehiclesState {
  const VehiclesInitial();

  @override
  String toString() => 'Initial';
}

class VehiclesLoading extends VehiclesState {
  const VehiclesLoading();

  @override
  String toString() => 'Loading';
}

class VehiclesLoaded extends VehiclesState {
  final List<VehicleModel> vehicles;

  const VehiclesLoaded({
    required this.vehicles,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehiclesLoaded && other.vehicles == vehicles;
  }

  @override
  int get hashCode => vehicles.hashCode;

  @override
  String toString() => 'Loaded';
}

class VehiclesError extends VehiclesState {
  final Exception exception;

  const VehiclesError(
    this.exception,
  );
}
