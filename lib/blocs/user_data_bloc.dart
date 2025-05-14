import 'package:flutter_bloc/flutter_bloc.dart';
import '../events/user_data_event.dart';
import '../states/user_data_state.dart';
import '../data/user_model.dart';

class UserDataBloc extends Bloc<UserDataEvent, UserDataState> {
  UserDataBloc() : super(UserDataInitial()) {
    on<AddUserData>((event, emit) {
      emit(UserDataLoaded(event.user));
    });
  }
}
