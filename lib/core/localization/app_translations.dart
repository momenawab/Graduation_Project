import 'package:get/get.dart';

/// F12 — GetX translations (English + Arabic). Switch at runtime with
/// `Get.updateLocale(const Locale('ar'))`; Flutter flips to RTL automatically
/// because `ar` is in supportedLocales with the Material/Widgets delegates.
///
/// Use in widgets via the `.tr` extension, e.g. `Text('login'.tr)`.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'app_name': 'SafeEye',
          'login': 'Login',
          'logout': 'Logout',
          'sign_in': 'Sign In',
          'enter_credentials': 'Enter your credentials to continue',
          'username': 'Username',
          'password': 'Password',
          'home': 'Home',
          'dashboard': 'Dashboard',
          'workers': 'Workers',
          'reports': 'Reports',
          'settings': 'Settings',
          'language': 'Language',
          'theme': 'Theme',
          'notifications': 'Notifications',
          'violations': 'Violations',
          'compliance_score': 'Compliance Score',
          'days_since_violation': 'Days Since Violation',
          'acknowledge': 'Acknowledge',
          'acknowledged': 'Acknowledged',
          'report_incident': 'Report Incident',
          'submit': 'Submit',
          'cancel': 'Cancel',
          'title': 'Title',
          'severity': 'Severity',
          'location': 'Location',
          'description': 'Description',
          'english': 'English',
          'arabic': 'Arabic',
        },
        'ar': {
          'app_name': 'سيف سايت',
          'login': 'تسجيل الدخول',
          'logout': 'تسجيل الخروج',
          'sign_in': 'تسجيل الدخول',
          'enter_credentials': 'أدخل بياناتك للمتابعة',
          'username': 'اسم المستخدم',
          'password': 'كلمة المرور',
          'home': 'الرئيسية',
          'dashboard': 'لوحة التحكم',
          'workers': 'العمال',
          'reports': 'التقارير',
          'settings': 'الإعدادات',
          'language': 'اللغة',
          'theme': 'المظهر',
          'notifications': 'الإشعارات',
          'violations': 'المخالفات',
          'compliance_score': 'نسبة الالتزام',
          'days_since_violation': 'أيام بدون مخالفة',
          'acknowledge': 'تأكيد',
          'acknowledged': 'تم التأكيد',
          'report_incident': 'الإبلاغ عن حادث',
          'submit': 'إرسال',
          'cancel': 'إلغاء',
          'title': 'العنوان',
          'severity': 'الخطورة',
          'location': 'الموقع',
          'description': 'الوصف',
          'english': 'الإنجليزية',
          'arabic': 'العربية',
        },
      };
}
