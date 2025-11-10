import 'package:flutter/widgets.dart';

/// Global RouteObserver instance. Add this to MaterialApp.navigatorObservers:
/// MaterialApp(
///   navigatorObservers: [routeObserver],
///   ...
/// )
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();