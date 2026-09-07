import 'package:artisans_app/core/navigation/app_routes.dart';
import 'package:artisans_app/core/navigation/route_policy.dart';
import 'package:artisans_app/core/navigation/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every declared route has exactly one access classification', () {
    final classified = <String>{
      ...RoutePolicy.publicRoutes,
      ...RoutePolicy.protectedRoutes,
    };
    expect(classified, containsAll(AppRoutes.all));
    expect(RoutePolicy.publicRoutes.intersection(RoutePolicy.protectedRoutes), isEmpty);
  });

  test('every canonical route is registered by the central router', () {
    expect(AppRouter.registeredRoutes, equals(AppRoutes.all));
  });

  test('canonical and legacy client shell routes are protected', () {
    expect(RoutePolicy.isProtected(AppRoutes.clientHome), isTrue);
    expect(RoutePolicy.isProtected(AppRoutes.clientHomeLegacy), isTrue);
  });

  test('payment callback is public while checkout is protected', () {
    expect(RoutePolicy.publicRoutes, contains(AppRoutes.paymentSuccess));
    expect(RoutePolicy.isProtected(AppRoutes.paymentCheckout), isTrue);
  });

  test('worker destinations require worker capability', () {
    expect(RoutePolicy.requiresWorkerCapability(AppRoutes.workerHome), isTrue);
    expect(RoutePolicy.requiresWorkerCapability(AppRoutes.workerEarnings), isTrue);
    expect(RoutePolicy.requiresWorkerCapability(AppRoutes.clientHome), isFalse);
  });
}
