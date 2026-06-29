import 'provider_registry.dart';
import 'feed_provider.dart';
import 'theoldreader/theoldreader_provider.dart';
import 'inoreader/inoreader_provider.dart';
import 'freshrss/freshrss_provider.dart';
import 'miniflux/miniflux_provider.dart';
import 'ttrss/ttrss_provider.dart';
import 'feedbin/feedbin_provider.dart';
import 'newsblur/newsblur_provider.dart';
import 'local_opml/local_opml_provider.dart';
import 'package:the_old_reader/providers/feedly/feedly_provider.dart';

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

  ProviderRegistry.register(
    'inoreader',
    () => InoreaderProvider(),
    const ProviderInfo(
      id: 'inoreader',
      name: 'Inoreader',
      supportsWebProxy: true,
      authTypes: [AuthType.apiKey],
    ),
  );

  ProviderRegistry.register(
    'freshrss',
    () => FreshRssProvider(),
    const ProviderInfo(
      id: 'freshrss',
      name: 'FreshRSS',
      supportsWebProxy: true,
      requiresBaseUrl: true,
      authTypes: [AuthType.basicAuth],
    ),
  );

  ProviderRegistry.register(
    'miniflux',
    () => MinifluxProvider(),
    const ProviderInfo(
      id: 'miniflux',
      name: 'Miniflux',
      supportsWebProxy: true,
      requiresBaseUrl: true,
      authTypes: [AuthType.apiKey],
    ),
  );

  ProviderRegistry.register(
    'ttrss',
    () => TtrssProvider(),
    const ProviderInfo(
      id: 'ttrss',
      name: 'Tiny Tiny RSS',
      supportsWebProxy: true,
      requiresBaseUrl: true,
      authTypes: [AuthType.basicAuth],
    ),
  );

  ProviderRegistry.register(
    'feedbin',
    () => FeedbinProvider(),
    const ProviderInfo(
      id: 'feedbin',
      name: 'Feedbin',
      supportsWebProxy: true,
      authTypes: [AuthType.basicAuth],
    ),
  );

  ProviderRegistry.register(
    'newsblur',
    () => NewsBlurProvider(),
    const ProviderInfo(
      id: 'newsblur',
      name: 'NewsBlur',
      supportsWebProxy: true,
      requiresBaseUrl: true,
      authTypes: [AuthType.basicAuth],
    ),
  );

  ProviderRegistry.register(
    'local_opml',
    () => LocalOpmlProvider(),
    const ProviderInfo(
      id: 'local_opml',
      name: 'Local OPML',
      authTypes: [AuthType.localFile],
    ),
  );

  ProviderRegistry.register(
    'feedly',
    () => FeedlyProvider(),
    const ProviderInfo(
      id: 'feedly',
      name: 'Feedly',
      supportsWebProxy: false,
      requiresBaseUrl: false,
      authTypes: [AuthType.oauth2],
    ),
  );
}
