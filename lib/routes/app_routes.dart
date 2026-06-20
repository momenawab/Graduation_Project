abstract class AppRoutes {
  static const String SPLASH = '/';
  static const String HOME = '/home';
  static const String MONITORING = '/monitoring';
  static const String VIDEO_TEST = '/video-test';
  static const String ADD_WORKER = '/worker/add';
  static const String UPLOAD_DETECTION = '/upload';
  static const String REPORTS = '/reports';
  static const String ALERT_CONFIG = '/alerts/config';
  static const String INSTRUCTIONS = '/instructions';
  static const String WORKER_MONITOR = '/worker-monitor';
  static const String CAMERA_MANAGEMENT = '/cameras-manage';
  static const String SETTINGS = '/settings';

  // Incident reporting (F15)
  static const String REPORT_INCIDENT = '/incidents/report';

  // Coming Soon placeholder
  static const String COMING_SOON = '/coming-soon';

  // Workers routes
  static const String WORKERS_LIST = '/workers';
  static const String WORKER_DETAILS = '/workers/:id';

  // Power BI embedded dashboard
  static const String POWER_BI = '/power-bi';

  // Auth routes
  static const String LOGIN = '/login';

  // Worker routes
  static const String WORKER_HOME = '/worker/home';
  static const String WORKER_NOTIFICATIONS = '/worker/notifications';
  static const String WORKER_VIOLATIONS = '/worker/violations';
}
