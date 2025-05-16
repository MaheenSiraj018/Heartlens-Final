// lib/bloc/model_output/model_output_state.dart
import 'package:equatable/equatable.dart';
import '../../models/ecg_analysis_result.dart';

class ModelOutputState extends Equatable {
  final EcgAnalysisResult? result;
  final bool isLoading;
  final String? error;

  const ModelOutputState({
    this.result,
    this.isLoading = false,
    this.error,
  });

  ModelOutputState copyWith({
    EcgAnalysisResult? result,
    bool? isLoading,
    String? error,
  }) {
    return ModelOutputState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory ModelOutputState.initial() {
    return const ModelOutputState();
  }

  factory ModelOutputState.loading() {
    return const ModelOutputState(isLoading: true);
  }

  factory ModelOutputState.success(EcgAnalysisResult result) {
    return ModelOutputState(result: result);
  }

  factory ModelOutputState.error(String error) {
    return ModelOutputState(error: error);
  }

  @override
  List<Object?> get props => [result, isLoading, error];
}