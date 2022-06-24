part of 'people_cubit.dart';

@immutable
abstract class PeopleState {
  const PeopleState();
}

class PeopleInitial extends PeopleState {
  const PeopleInitial();

  @override
  String toString() => 'Initial';
}

class PeopleLoading extends PeopleState {
  const PeopleLoading();

  @override
  String toString() => 'Loading';
}

class PeopleLoaded extends PeopleState {
  final List<PersonModel> people;

  const PeopleLoaded({
    required this.people,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeopleLoaded && other.people == people;
  }

  @override
  int get hashCode => people.hashCode;

  @override
  String toString() => 'Loaded';
}

class PeopleError extends PeopleState {
  final Exception exception;

  const PeopleError(
    this.exception,
  );
}
