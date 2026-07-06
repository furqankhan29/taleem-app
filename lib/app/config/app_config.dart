enum Environment { dev, staging, prod }

class AppConfig {
  AppConfig._();

  static Environment environment = Environment.dev;

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://localhost:5001/taleem-dev/us-central1';
      case Environment.staging:
        return 'https://us-central1-taleem-staging.cloudfunctions.net';
      case Environment.prod:
        return 'https://us-central1-taleem-prod.cloudfunctions.net';
    }
  }

  static bool get showDebugBanner => environment != Environment.prod;
}
