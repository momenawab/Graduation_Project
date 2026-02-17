import 'api_client.dart';

/// Instructions API stub with methods for tutorials and FAQ content.
///
/// This is a stub implementation that returns mock data.
/// In production, this would make actual HTTP requests to the backend API.
class InstructionsApi {
  /// The API client instance
  final ApiClient apiClient;

  /// Creates a new InstructionsApi instance.
  InstructionsApi({required this.apiClient});

  /// Gets tutorial categories.
  Future<List<Map<String, dynamic>>> getCategories() async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get<List<dynamic>>('/instructions/categories');
    // return response.data.cast<Map<String, dynamic>>();

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'id': 'getting-started', 'name': 'Getting Started', 'icon': 'rocket'},
      {'id': 'ai-detection', 'name': 'AI Detection', 'icon': 'eye'},
      {'id': 'safety-alerts', 'name': 'Safety Alerts', 'icon': 'bell'},
      {'id': 'reports', 'name': 'Reports', 'icon': 'chart'},
      {'id': 'workers', 'name': 'Worker Profiles', 'icon': 'users'},
    ];
  }

  /// Gets a list of tutorials.
  Future<List<Map<String, dynamic>>> getTutorials() async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get<List<dynamic>>('/instructions/tutorials');
    // return response.data.cast<Map<String, dynamic>>();

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        'id': '1',
        'title': 'Activating AI Scanning',
        'description':
            'Learn how to enable and configure real-time PPE detection',
        'category': 'getting-started',
        'icon': 'scan',
        'readTime': '5 min',
      },
      {
        'id': '2',
        'title': 'Hazard Identification',
        'description': 'Understand how the system identifies safety hazards',
        'category': 'ai-detection',
        'icon': 'warning',
        'readTime': '3 min',
      },
      {
        'id': '3',
        'title': 'Safety Reports',
        'description': 'Navigate and interpret compliance analytics',
        'category': 'reports',
        'icon': 'chart',
        'readTime': '4 min',
      },
      {
        'id': '4',
        'title': 'Worker Profiles',
        'description': 'Manage personnel and their required PPE',
        'category': 'workers',
        'icon': 'user',
        'readTime': '6 min',
      },
    ];
  }

  /// Gets a specific tutorial by ID.
  Future<Map<String, dynamic>> getTutorial(String tutorialId) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get<Map<String, dynamic>>('/instructions/tutorials/$tutorialId');
    // return response.data;

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    throw Exception('Tutorial not found');
  }

  /// Gets FAQ items.
  Future<List<Map<String, dynamic>>> getFaq() async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get<List<dynamic>>('/instructions/faq');
    // return response.data.cast<Map<String, dynamic>>();

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': '1',
        'question': 'How do I enable AI detection?',
        'answer':
            'Navigate to the Monitoring screen and tap the start button to begin real-time PPE detection.',
        'category': 'getting-started',
      },
      {
        'id': '2',
        'question': 'What does the red bounding box mean?',
        'answer':
            'A red bounding box indicates that the detected person is missing required PPE items.',
        'category': 'ai-detection',
      },
      {
        'id': '3',
        'question': 'How do I add a new worker?',
        'answer':
            'Go to the Personnel screen and tap "Add New Worker" to register a new employee.',
        'category': 'workers',
      },
      {
        'id': '4',
        'question': 'How often are reports updated?',
        'answer': 'Reports are synchronized with edge sensors every 5 minutes.',
        'category': 'reports',
      },
    ];
  }

  /// Searches tutorials and FAQs by query string.
  Future<Map<String, List<Map<String, dynamic>>>> searchContent(
    String query,
  ) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get<Map<String, dynamic>>(
    //   '/instructions/search',
    //   queryParameters: {'q': query},
    // );
    // return {
    //   'tutorials': response.data['tutorials'].cast<Map<String, dynamic>>(),
    //   'faqs': response.data['faqs'].cast<Map<String, dynamic>>(),
    // };

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'tutorials': <Map<String, dynamic>>[],
      'faqs': <Map<String, dynamic>>[],
    };
  }
}
