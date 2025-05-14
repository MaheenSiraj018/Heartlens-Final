import 'package:equatable/equatable.dart';
import '../data/user_model.dart';

abstract class UserDataState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserDataInitial extends UserDataState {}

class UserDataLoaded extends UserDataState {
  final User user;

  UserDataLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserDataError extends UserDataState {
  final String error;

  UserDataError(this.error);

  @override
  List<Object?> get props => [error];
}
