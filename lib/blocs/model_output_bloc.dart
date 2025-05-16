import 'package:flutter_bloc/flutter_bloc.dart';
import '../events/model_output_event.dart';
import '../states/model_output_state.dart';

class ModelOutputBloc extends Bloc<ModelOutputEvent, ModelOutputState> {
  ModelOutputBloc() : super(ModelOutputState.initial()) {
    on<UpdateModelOutputEvent>((event, emit) {
      emit(ModelOutputState.success(event.result));
    });

    on<ClearModelOutputEvent>((event, emit) {
      emit(ModelOutputState.initial());
    });
  }
}