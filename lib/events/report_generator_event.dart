import '../blocs/report_generator_bloc.dart';
import 'package:equatable/equatable.dart';


abstract class ReportGeneratorEvent extends Equatable {
  const ReportGeneratorEvent();
}

class GenerateReport extends ReportGeneratorEvent {
  final Map<String, dynamic> mlResults;

  const GenerateReport(this.mlResults);

  @override
  List<Object> get props => [mlResults];
}