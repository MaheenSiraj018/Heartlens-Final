import 'package:equatable/equatable.dart';
import '../data/user_health_data.dart';

// MUST be marked abstract
abstract class UserHealthEvent extends Equatable {
  const UserHealthEvent();

  @override
  List<Object> get props => [];
}

// MUST use exact same name as when dispatching
class UpdateUserHealthData extends UserHealthEvent {
  final UserHealthData userData;

  // Constructor MUST be const
  const UpdateUserHealthData(this.userData);

  @override
  List<Object> get props => [userData];
}