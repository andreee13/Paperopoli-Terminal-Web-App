part of 'trips_cubit.dart';

@immutable
abstract class TripsState {
  const TripsState();
}

class TripsInitial extends TripsState {
  const TripsInitial();

  @override
  String toString() => 'Initial';
}

class TripsLoading extends TripsState {
  const TripsLoading();

  @override
  String toString() => 'Logging';
}

class TripsLoaded extends TripsState {
  final List<TripModel> trips;

  const TripsLoaded({
    required this.trips,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TripsLoaded && other.trips == trips;
  }

  @override
  int get hashCode => trips.hashCode;

  @override
  String toString() => 'Loaded';
}

class TripsError extends TripsState {
  final Exception exception;

  const TripsError(
    this.exception,
  );
}
