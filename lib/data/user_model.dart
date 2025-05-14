import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String name;
  final String age;
  final String gender;

  const User({required this.name, required this.age, required this.gender});

  @override
  List<Object?> get props => [name, age, gender];
}
