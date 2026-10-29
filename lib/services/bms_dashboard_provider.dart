import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/demo_telemetry.dart';
import '../models/bms_telemetry.dart';
import 'gateway_client.dart';

class BmsDashboardProvider extends ChangeNotifier {
  BmsDashboardProvider({
    String? gatewayEndpoint,
    bool startClock = true,
    bool refreshDemo = true,
  }) : _now = DateTime.now(),
       _telemetry = demoTelemetry(DateTime.now()),
       _refreshDemo = refreshDemo {
    if (startClock) {
      _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_disposed) return;
        _now = DateTime.now();
        if (_isLive && lastSyncAge > const Duration(seconds: 15)) {
          final client = _gatewayClient;
          if (client != null) {
            _handleGatewayFailure(client, 'telemetry timeout');
          }
        }
        notifyListeners();
      });
    }

    final endpoint =
        gatewayEndpoint ??
        const String.fromEnvironment('BMS_GATEWAY_WS_URL', defaultValue: '');
    final candidate = endpoint.trim();
    _gatewayEndpoint = _isValidGatewayEndpoint(candidate) ? candidate : null;
    if (candidate.isEmpty) {
      _startDemoStream();
    } else if (_gatewayEndpoint == null) {
      _startDemoStream(reason: 'invalid gateway endpoint');
    } else {
      _startDemoStream();
      unawaited(_connect(_gatewayEndpoint!));
    }
  }

  DateTime _now;
  BmsTelemetry _telemetry;
  final bool _refreshDemo;
  Timer? _clockTimer;
  Timer? _demoTimer;
  Timer? _reconnectTimer;
  StreamSubscription<BmsTelemetry>? _readingsSubscription;
  WebSocketBmsGatewayClient? _gatewayClient;
  String? _gatewayEndpoint;
  int _connectAttempt = 0;
  bool _disposed = false;
  bool _hadLiveReading = false;
  int _selectedTab = 0;
  String _trendRange = '1H';
  bool _isLive = false;
  bool _simulatedWarning = false;
  String _connectionLabel = 'CONNECTED • DEMO';
  String _sourceLabel = 'SIMULATED DATA';

  DateTime get now => _now;
  BmsTelemetry get telemetry => _telemetry;
  int get selectedTab => _selectedTab;
  String get trendRange => _trendRange;
  bool get isLive => _isLive;
  bool get isTelemetryStale => _hadLiveReading && !_isLive;
  bool get simulatedWarning => _simulatedWarning;
  String get connectionLabel =>
      isTelemetryStale ? 'STALE • LIVE' : _connectionLabel;
  String get sourceLabel => _sourceLabel;

  List<BmsAlert> get activeAlerts {
    final alerts = <BmsAlert>[..._telemetry.alerts, ..._telemetry.safetyAlerts];
    if (isTelemetryStale) {
      alerts.add(
        BmsAlert(
          title: 'Gateway telemetry stale',
          detail:
              'The last live reading is ${lastSyncAge.inSeconds} seconds old.',
          severity: AlertSeverity.critical,
          time: _formatClock(_now),
        ),
      );
    }
    if (_isLive || !_simulatedWarning) return alerts;
    return [
      ...alerts,
      BmsAlert(
        title: 'Temperature variance warning',
        detail: 'One demo zone is above its normal operating range.',
        severity: AlertSeverity.warning,
        time: _formatClock(_now),
      ),
    ];
  }

  int get warningCount =>
      activeAlerts.where((a) => a.severity == AlertSeverity.warning).length;
  int get criticalCount =>
      activeAlerts.where((a) => a.severity == AlertSeverity.critical).length;
  Duration get lastSyncAge {
    final age = _now.difference(_telemetry.timestamp);
    return age.isNegative ? Duration.zero : age;
  }

  void selectTab(int index) {
    if (index < 0 || index > 4 || index == _selectedTab) return;
    _selectedTab = index;
    notifyListeners();
  }

  void setTrendRange(String range) {
    if (_trendRange == range) return;
    _trendRange = range;
    notifyListeners();
  }

  void setSimulatedWarning(bool enabled) {
    if (_isLive || _simulatedWarning == enabled) return;
    _simulatedWarning = enabled;
    notifyListeners();
  }

  void _startDemoStream({String? reason}) {
    if (_disposed) return;
    _isLive = false;
    _sourceLabel = _hadLiveReading && reason != null
        ? 'STALE LIVE DATA'
        : 'SIMULATED DATA';
    _connectionLabel = reason == null
        ? 'CONNECTED • DEMO'
        : 'DEMO • GATEWAY UNAVAILABLE';
    if (_refreshDemo && (!_hadLiveReading || _gatewayEndpoint == null)) {
      _demoTimer ??= Timer.periodic(const Duration(seconds: 5), (_) {
        if (_disposed) return;
        _telemetry = demoTelemetry(DateTime.now());
        _now = DateTime.now();
        notifyListeners();
      });
    }
    notifyListeners();
    if (reason != null && _gatewayEndpoint != null) _scheduleReconnect();
  }

  Future<void> _connect(String endpoint) async {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    final client = WebSocketBmsGatewayClient(endpoint);
    _gatewayClient = client;
    try {
      await client.connect();
      if (_disposed || !identical(_gatewayClient, client)) {
        await client.close();
        return;
      }
      _connectAttempt = 0;
      _connectionLabel = 'WAITING FOR TELEMETRY';
      notifyListeners();
      _readingsSubscription = client.readings.listen(
        (reading) {
          if (_disposed || !identical(_gatewayClient, client)) return;
          _telemetry = reading;
          _now = DateTime.now();
          _isLive = true;
          _hadLiveReading = true;
          _sourceLabel = 'LIVE GATEWAY';
          _connectionLabel = 'CONNECTED';
          _simulatedWarning = false;
          _demoTimer?.cancel();
          _demoTimer = null;
          notifyListeners();
        },
        onError: (Object error, StackTrace stack) {
          if (error is TelemetryValidationException) {
            notifyListeners();
            return;
          }
          _handleGatewayFailure(client, 'connection error');
        },
        onDone: () => _handleGatewayFailure(client, 'connection closed'),
      );
    } on Object {
      await client.close();
      if (identical(_gatewayClient, client)) _gatewayClient = null;
      _startDemoStream(reason: 'connection unavailable');
    }
  }

  void _handleGatewayFailure(WebSocketBmsGatewayClient client, String reason) {
    if (_disposed || !identical(_gatewayClient, client)) return;
    _readingsSubscription = null;
    _gatewayClient = null;
    unawaited(client.close());
    _startDemoStream(reason: reason);
  }

  void _scheduleReconnect() {
    if (_disposed || _gatewayEndpoint == null || _reconnectTimer != null) {
      return;
    }
    final delaySeconds = (2 << _connectAttempt.clamp(0, 3)).clamp(2, 16);
    _connectAttempt++;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      _reconnectTimer = null;
      final endpoint = _gatewayEndpoint;
      if (endpoint != null) unawaited(_connect(endpoint));
    });
  }

  static String _formatClock(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';

  static bool _isValidGatewayEndpoint(String endpoint) {
    final uri = Uri.tryParse(endpoint);
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'ws' && uri.scheme != 'wss')) {
      return false;
    }
    return !(kIsWeb && Uri.base.scheme == 'https' && uri.scheme != 'wss');
  }

  @override
  void dispose() {
    _disposed = true;
    _clockTimer?.cancel();
    _demoTimer?.cancel();
    _reconnectTimer?.cancel();
    unawaited(_readingsSubscription?.cancel());
    unawaited(_gatewayClient?.close());
    super.dispose();
  }
}
