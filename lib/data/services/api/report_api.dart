import '../../../core/constants/api_constants.dart';
import '../../models/report_data.dart';
import 'api_client.dart';

/// Report API — wired to the SafeSight Django reports endpoints.
class ReportApi {
  /// The API client instance
  final ApiClient apiClient;

  /// Creates a new ReportApi instance.
  ReportApi({required this.apiClient});

  /// Gets a summary of safety metrics and maps it to [ReportData].
  /// GET /api/reports/summary/
  Future<ReportData> getSummary() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.reportSummary.fullPath,
    );
    final data = response.data ?? <String, dynamic>{};
    final overview = (data['overview'] as Map<String, dynamic>?) ?? {};
    final period = (data['period'] as Map<String, dynamic>?) ?? {};
    final dailyTrend = (data['daily_trend'] as List?) ?? const [];

    DateTime parseDate(String? s, DateTime fallback) =>
        s != null ? (DateTime.tryParse(s) ?? fallback) : fallback;

    final now = DateTime.now();
    final start = parseDate(
      period['start_date'] as String?,
      now.subtract(const Duration(days: 30)),
    );
    final end = parseDate(period['end_date'] as String?, now);

    final chart = dailyTrend.map<ChartDataPoint>((e) {
      final m = e as Map<String, dynamic>;
      final label = (m['date'] ?? m['day'] ?? m['label'] ?? '').toString();
      final raw = m['violations'] ?? m['count'] ?? m['compliance_rate'] ?? m['value'] ?? 0;
      return ChartDataPoint(label: label, value: (raw as num).toDouble());
    }).toList();

    return ReportData(
      incidents: (overview['total_violations'] as num?)?.toInt() ?? 0,
      incidentsTrend: 0,
      compliance: (overview['compliance_rate'] as num?)?.round() ?? 0,
      complianceTrend: 0,
      dateRange: DateRange(start: start, end: end),
      chartData: chart,
      lastUpdate: now,
    );
  }

  /// Gets compliance time-series data for charting.
  /// GET /api/reports/compliance/?group_by=day
  Future<List<Map<String, dynamic>>> getChartData({String groupBy = 'day'}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.reportCompliance.fullPath,
      queryParameters: {'group_by': groupBy},
    );
    final grouped = (response.data?['grouped_data'] as List?) ?? const [];
    return grouped.cast<Map<String, dynamic>>();
  }

  /// Gets a list of safety violations.
  /// GET /api/reports/violations/
  Future<List<Map<String, dynamic>>> getViolations({
    Map<String, dynamic>? filters,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.reportViolations.fullPath,
      queryParameters: filters,
    );
    final data = response.data ?? {};
    final results = (data['results'] ?? data['violations'] ?? []) as List;
    return results.cast<Map<String, dynamic>>();
  }

  /// Gets a report for a specific worker.
  /// GET /api/reports/worker/?worker_id=...
  Future<Map<String, dynamic>> getWorkerReport(String workerId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/reports/worker/'.fullPath,
      queryParameters: {'worker_id': workerId},
    );
    return response.data ?? <String, dynamic>{};
  }

  /// Exports a report in the specified format.
  /// POST /api/reports/export/
  Future<String> exportReport({
    required String format,
    String reportType = 'summary',
    Map<String, dynamic>? filters,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.reportExport.fullPath,
      data: {
        'format': format,
        'report_type': reportType,
        if (filters != null) 'filters': filters,
      },
    );
    final data = response.data ?? {};
    return (data['file_path'] ?? data['downloadUrl'] ?? data['report_id'] ?? '')
        .toString();
  }
}
