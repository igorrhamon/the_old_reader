import 'provider_registry.dart';
import 'feed_provider.dart';
import 'theoldreader/theoldreader_provider.dart';

void initializeProviders() {
  ProviderRegistry.register(
    'theoldreader',
    () => TheOldReaderProvider(),
    const ProviderInfo(
      id: 'theoldreader',
      name: 'The Old Reader',
      supportsWebProxy: true,
      authTypes: [AuthType.googleLogin],
    ),
  );
}