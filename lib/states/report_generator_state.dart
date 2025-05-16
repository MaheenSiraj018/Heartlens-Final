import '../blocs/report_generator_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class ReportGeneratorState extends Equatable {
  const ReportGeneratorState();
}

class ReportGeneratorInitial extends ReportGeneratorState {
  @override List<Object> get props => [];
}

class ReportGeneratorLoading extends ReportGeneratorState {
  @override List<Object> get props => [];
}

class ReportGeneratorSuccess extends ReportGeneratorState {
  final Map<String, String> report;

  const ReportGeneratorSuccess(this.report);
  @override List<Object> get props => [report];
}

class ReportGeneratorError extends ReportGeneratorState {
  final String message;

  const ReportGeneratorError(this.message);
  @override List<Object> get props => [message];
}