import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserImageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateImageEvent extends UserImageEvent {
  final File image;
  UpdateImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class UserImageState extends Equatable {
  final File? image;

  UserImageState({this.image});

  UserImageState copyWith({File? image}) {
    return UserImageState(image: image ?? this.image);
  }

  @override
  List<Object?> get props => [image];
}

class UserImageBloc extends Bloc<UserImageEvent, UserImageState> {
  UserImageBloc() : super(UserImageState()) {
    on<UpdateImageEvent>((event, emit) {
      emit(state.copyWith(image: event.image));
    });
  }
}
