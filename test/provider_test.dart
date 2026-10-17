import 'package:flutter_test/flutter_test.dart';

import '../lib/services/bms_dashboard_provider.dart';

void main() {
  test('invalid gateway endpoints fall back to clearly labeled demo data', () {
    final model = BmsDashboardProvider(
      gatewayEndpoint: 'not-a-websocket-url',
      startClock: false,
      refreshDemo: false,
    );
    addTearDown(model.dispose);

    expect(model.isLive, isFalse);
    expect(model.connectionLabel, 'DEMO • GATEWAY UNAVAILABLE');
    expect(model.sourceLabel, 'SIMULATED DATA');
  });
}
