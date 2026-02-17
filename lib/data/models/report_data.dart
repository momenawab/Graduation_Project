import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Model representing a date range for reports.
@immutable
class DateRange extends Equatable {
  /// Period start
  final DateTime start;

  /// Period end
  final DateTime end;

  const DateRange({required this.start, required this.end});

  /// Creates a DateRange instance from JSON data.
  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }

  /// Converts DateRange instance to JSON.
  Map<String, dynamic> toJson() {
    return {'start': start.toIso8601String(), 'end': end.toIso8601String()};
  }

  /// Creates a copy of this DateRange with optionally updated fields.
  DateRange copyWith({DateTime? start, DateTime? end}) {
    return DateRange(start: start ?? this.start, end: end ?? this.end);
  }

  @override
  List<Object?> get props => [start, end];

  @override
  String toString() => 'DateRange($start to $end)';
}

/// Model representing a data point for charts.
@immutable
class ChartDataPoint extends Equatable {
  /// X-axis label (date/time)
  final String label;

  /// Y-axis value
  final double value;

  /// Series name (for multi-series)
  final String? series;

  const ChartDataPoint({required this.label, required this.value, this.series});

  /// Creates a ChartDataPoint instance from JSON data.
  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      series: json['series'] as String?,
    );
  }

  /// Converts ChartDataPoint instance to JSON.
  Map<String, dynamic> toJson() {
    return {'label': label, 'value': value, 'series': series};
  }

  /// Creates a copy of this ChartDataPoint with optionally updated fields.
  ChartDataPoint copyWith({String? label, double? value, String? series}) {
    return ChartDataPoint(
      label: label ?? this.label,
      value: value ?? this.value,
      series: series ?? this.series,
    );
  }

  @override
  List<Object?> get props => [label, value, series];

  @override
  String toString() => 'ChartDataPoint($label: $value)';
}

/// Model representing aggregated safety metrics for reports screen.
@immutable
class ReportData extends Equatable {
  /// Total incidents in period
  final int incidents;

  /// Change from previous period (percentage)
  final double incidentsTrend;

  /// Compliance percentage (0-100)
  final int compliance;

  /// Change from previous period (percentage)
  final double complianceTrend;

  /// Report period
  final DateRange dateRange;

  /// Data for chart
  final List<ChartDataPoint> chartData;

  /// Last sync timestamp
  final DateTime lastUpdate;

  const ReportData({
    required this.incidents,
    required this.incidentsTrend,
    required this.compliance,
    required this.complianceTrend,
    required this.dateRange,
    required this.chartData,
    required this.lastUpdate,
  });

  /// Creates a ReportData instance from JSON data.
  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      incidents: json['incidents'] as int,
      incidentsTrend: (json['incidentsTrend'] as num).toDouble(),
      compliance: json['compliance'] as int,
      complianceTrend: (json['complianceTrend'] as num).toDouble(),
      dateRange: DateRange.fromJson(json['dateRange'] as Map<String, dynamic>),
      chartData: (json['chartData'] as List)
          .map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );
  }

  /// Converts ReportData instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'incidents': incidents,
      'incidentsTrend': incidentsTrend,
      'compliance': compliance,
      'complianceTrend': complianceTrend,
      'dateRange': dateRange.toJson(),
      'chartData': chartData.map((e) => e.toJson()).toList(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  /// Creates a copy of this ReportData with optionally updated fields.
  ReportData copyWith({
    int? incidents,
    double? incidentsTrend,
    int? compliance,
    double? complianceTrend,
    DateRange? dateRange,
    List<ChartDataPoint>? chartData,
    DateTime? lastUpdate,
  }) {
    return ReportData(
      incidents: incidents ?? this.incidents,
      incidentsTrend: incidentsTrend ?? this.incidentsTrend,
      compliance: compliance ?? this.compliance,
      complianceTrend: complianceTrend ?? this.complianceTrend,
      dateRange: dateRange ?? this.dateRange,
      chartData: chartData ?? this.chartData,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  List<Object?> get props => [
    incidents,
    incidentsTrend,
    compliance,
    complianceTrend,
    dateRange,
    chartData,
    lastUpdate,
  ];

  @override
  String toString() =>
      'ReportData(incidents: $incidents, compliance: $compliance%)';
}
