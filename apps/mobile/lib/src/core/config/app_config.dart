class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  factory AppConfig.fromEnvironment() {
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    return const AppConfig(apiBaseUrl: apiBaseUrl);
  }

  final String apiBaseUrl;

  bool get isConfigured => apiBaseUrl.trim().isNotEmpty;
}
