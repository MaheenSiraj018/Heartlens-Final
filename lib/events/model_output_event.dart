import 'package:equatable/equatable.dart';
import '../../models/ecg_analysis_result.dart';

abstract class ModelOutputEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateModelOutputEvent extends ModelOutputEvent {
  final EcgAnalysisResult result;

  UpdateModelOutputEvent(this.result);

  @override
  List<Object?> get props => [result];
}

class ClearModelOutputEvent extends ModelOutputEvent {}

