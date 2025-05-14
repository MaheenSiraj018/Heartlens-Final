import 'package:equatable/equatable.dart';
import '../data/user_model.dart';

abstract class UserDataEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddUserData extends UserDataEvent {
  final User user;

  AddUserData(this.user);

  @override
  List<Object?> get props => [user];
}
