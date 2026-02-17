import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/api/instructions_api.dart';

/// Controller for instructions screen managing tutorials, FAQs, and search.
@immutable
class InstructionsController extends GetxController {
  /// The Instructions API instance
  final InstructionsApi instructionsApi;

  /// Observable for selected tab
  final RxInt selectedTab = 0.obs;

  /// Observable for search query
  final RxString searchQuery = ''.obs;

  /// Observable for tutorials list
  final RxList<Map<String, dynamic>> tutorials = <Map<String, dynamic>>[].obs;

  /// Observable for FAQs list
  final RxList<Map<String, dynamic>> faqs = <Map<String, dynamic>>[].obs;

  /// Observable for expanded FAQ items
  final RxSet<String> expandedFaqs = <String>{}.obs;

  /// Observable for loading state
  final RxBool isLoading = false.obs;

  /// Observable for selected tutorial (for detail view)
  final Rx<Map<String, dynamic>?> selectedTutorial = Rx<Map<String, dynamic>?>(
    null,
  );

  /// Observable for search results
  final RxList<Map<String, dynamic>> searchTutorials =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> searchFaqs = <Map<String, dynamic>>[].obs;

  /// Observable for showing search results
  final RxBool isSearching = false.obs;

  /// Tab labels
  static const List<String> tabLabels = [
    'Getting Started',
    'AI Detection',
    'Safety Alerts',
  ];

  /// Creates a new InstructionsController instance.
  InstructionsController({required this.instructionsApi});

  /// Selects a tab by index.
  void selectTab(int index) {
    selectedTab.value = index;
  }

  /// Updates search query and filters content.
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      isSearching.value = false;
      searchTutorials.clear();
      searchFaqs.clear();
    } else {
      performSearch(query);
    }
  }

  /// Performs search on tutorials and FAQs.
  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      isSearching.value = false;
      searchTutorials.clear();
      searchFaqs.clear();
      return;
    }

    try {
      isLoading.value = true;
      isSearching.value = true;

      // Filter locally for now (in production, use API)
      searchTutorials.value = tutorials.where((t) {
        final title = t['title']?.toString().toLowerCase() ?? '';
        final description = t['description']?.toString().toLowerCase() ?? '';
        return title.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase());
      }).toList();

      searchFaqs.value = faqs.where((f) {
        final question = f['question']?.toString().toLowerCase() ?? '';
        final answer = f['answer']?.toString().toLowerCase() ?? '';
        return question.contains(query.toLowerCase()) ||
            answer.contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      // Handle error silently for now
    } finally {
      isLoading.value = false;
    }
  }

  /// Shows tutorial detail view.
  void showTutorialDetail(Map<String, dynamic> tutorial) {
    selectedTutorial.value = tutorial;
    // TODO: Navigate to tutorial detail screen
    // Get.toNamed(AppRoutes.TUTORIAL_DETAIL, arguments: tutorial);
  }

  /// Closes tutorial detail view.
  void closeTutorialDetail() {
    selectedTutorial.value = null;
  }

  /// Toggles FAQ expansion state.
  void toggleFaqExpansion(String faqId) {
    if (expandedFaqs.contains(faqId)) {
      expandedFaqs.remove(faqId);
    } else {
      expandedFaqs.add(faqId);
    }
  }

  /// Gets tutorials filtered by selected tab category.
  List<Map<String, dynamic>> getFilteredTutorials() {
    if (isSearching.value) {
      return searchTutorials;
    }

    final category = getCategoryForTab(selectedTab.value);
    if (category == null) {
      return tutorials;
    }

    return tutorials
        .where((t) => t['category']?.toString() == category)
        .toList();
  }

  /// Gets FAQs filtered by selected tab category.
  List<Map<String, dynamic>> getFilteredFaqs() {
    if (isSearching.value) {
      return searchFaqs;
    }

    final category = getCategoryForTab(selectedTab.value);
    if (category == null) {
      return faqs;
    }

    return faqs.where((f) => f['category']?.toString() == category).toList();
  }

  /// Gets category ID for a given tab index.
  String? getCategoryForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'getting-started';
      case 1:
        return 'ai-detection';
      case 2:
        return 'safety-alerts';
      default:
        return null;
    }
  }

  /// Loads tutorials from API.
  Future<void> loadTutorials() async {
    try {
      isLoading.value = true;
      final loadedTutorials = await instructionsApi.getTutorials();
      tutorials.value = loadedTutorials;
    } catch (e) {
      // Handle error silently for now
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads FAQs from API.
  Future<void> loadFaqs() async {
    try {
      isLoading.value = true;
      final loadedFaqs = await instructionsApi.getFaq();
      faqs.value = loadedFaqs;
    } catch (e) {
      // Handle error silently for now
    } finally {
      isLoading.value = false;
    }
  }

  /// Refreshes all content.
  Future<void> refreshContent() async {
    await Future.wait([loadTutorials(), loadFaqs()]);
  }

  /// Gets icon data for tutorial icon string.
  IconData getIconForTutorial(String? icon) {
    switch (icon) {
      case 'scan':
        return Icons.scanner;
      case 'warning':
        return Icons.warning;
      case 'chart':
        return Icons.bar_chart;
      case 'user':
        return Icons.person;
      default:
        return Icons.article;
    }
  }

  /// Gets color for tutorial category.
  Color getColorForCategory(String? category) {
    switch (category) {
      case 'getting-started':
        return const Color(0xFF2196F3); // Blue
      case 'ai-detection':
        return const Color(0xFFFF9800); // Orange
      case 'safety-alerts':
        return const Color(0xFF4CAF50); // Green
      case 'reports':
        return const Color(0xFF9C27B0); // Purple
      case 'workers':
        return const Color(0xFFE91E63); // Pink
      default:
        return const Color(0xFF757575); // Gray
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadTutorials();
    loadFaqs();
  }

  @override
  void onClose() {
    selectedTab.close();
    searchQuery.close();
    tutorials.close();
    faqs.close();
    expandedFaqs.close();
    isLoading.close();
    selectedTutorial.close();
    searchTutorials.close();
    searchFaqs.close();
    isSearching.close();
    super.onClose();
  }
}
