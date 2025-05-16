import 'package:equatable/equatable.dart';
import '../data/user_health_data.dart';

abstract class UserHealthState extends Equatable {
  const UserHealthState();

  @override
  List<Object> get props => [];
}

class UserHealthInitial extends UserHealthState {}

class UserHealthLoading extends UserHealthState {}

class UserHealthLoaded extends UserHealthState {
  final UserHealthData userData;
  final String recommendations;

  const UserHealthLoaded({
    required this.userData,
    required this.recommendations,
  });

  @override
  List<Object> get props => [userData, recommendations];
}

class UserHealthError extends UserHealthState {
  final String message;

  const UserHealthError(this.message);

  @override
  List<Object> get props => [message];
}