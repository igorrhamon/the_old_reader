import 'feed_provider.dart';

class ProviderInfo {
  final String id;
  final String name;
  final bool supportsWebProxy;
  final List<AuthType> authTypes;

  const ProviderInfo({
    required this.id,
    required this.name,
    required this.supportsWebProxy,
    required this.authTypes,
  });
}

class ProviderRegistry {
  static final Map<String, FeedProvider Function()> _factories = {};
  static final Map<String, ProviderInfo> _info = {};

  static void register(String providerId, FeedProvider Function() factory, ProviderInfo info) {
    _factories[providerId] = factory;
    _info[providerId] = info;
  }

  static FeedProvider? create(String providerId) {
    return _factories[providerId]?.call();
  }

  static List<ProviderInfo> getAvailableProviders() {
    return _info.values.toList();
  }

  static ProviderInfo? getProviderInfo(String providerId) {
    return _info[providerId];
  }

  static bool isRegistered(String providerId) {
    return _factories.containsKey(providerId);
  }
}