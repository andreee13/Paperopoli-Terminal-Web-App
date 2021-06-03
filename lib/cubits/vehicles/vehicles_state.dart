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
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is VehiclesLoaded && o.vehicles == vehicles;
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
