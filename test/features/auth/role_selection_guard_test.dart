import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/session/app_user_session.dart';
import 'package:artisans_app/features/auth/presentation/widgets/role_selection/role_selection_page.dart';
import 'package:artisans_app/features/auth/widgets/role_option_card.dart';
import 'package:artisans_app/shared/models/onboarding_session.dart';
import 'package:artisans_app/shared/models/user_profile_view.dart';

void main() {
  tearDown(() {
    AppUserSession.instance.clear();
  });

  group('RoleOptionCard', () {
    testWidgets('calls onTap when enabled and tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleOptionCard(
              title: 'I need a worker',
              subtitle: 'Find skilled professionals',
              icon: PhosphorIcons.desktop,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('I need a worker'), findsOneWidget);
      await tester.tap(find.text('I need a worker'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap and shows badge when disabled',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleOptionCard(
              title: 'I need a worker',
              subtitle: 'You already have an active Client profile.',
              icon: PhosphorIcons.desktop,
              isDisabled: true,
              statusBadge: 'Current Role',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Current Role'), findsOneWidget);
      expect(find.text('You already have an active Client profile.'), findsOneWidget);

      await tester.tap(find.text('I need a worker'));
      await tester.pump();

      expect(tapped, isFalse);
    });
  });

  group('RoleSelectionPage Guard', () {
    testWidgets('disables client role and allows worker role when user is already a client',
        (WidgetTester tester) async {
      // Set up authenticated client user
      final clientUser = AppUser(
        id: 'user-client-1',
        email: 'officiallykbk@gmail.com',
        signupType: 'client',
        lastActiveMode: 'client',
        hasWorkerProfile: false,
        fullName: 'Kwabena Boateng Konadu',
      );
      AppUserSession.instance.updateUser(clientUser);

      UserRole? selectedRole;
      final session = OnboardingSession.instance;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleSelectionPage(
              session: session,
              onRoleSelected: (role) => selectedRole = role,
            ),
          ),
        ),
      );

      expect(find.text('Current Role'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('You already have an active Client profile.'), findsOneWidget);

      // Attempt tapping the client card
      await tester.tap(find.text('I need a worker'));
      await tester.pump();
      expect(selectedRole, isNull);

      // Tapping the worker card succeeds
      await tester.tap(find.text('I offer services'));
      await tester.pump();
      expect(selectedRole, UserRole.worker);
    });

    testWidgets('allows both roles when no existing user profile exists',
        (WidgetTester tester) async {
      AppUserSession.instance.clear();

      UserRole? selectedRole;
      final session = OnboardingSession.instance;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleSelectionPage(
              session: session,
              onRoleSelected: (role) => selectedRole = role,
            ),
          ),
        ),
      );

      expect(find.text('Current Role'), findsNothing);
      expect(find.text('Available'), findsNothing);

      // Tap client card
      await tester.tap(find.text('I need a worker'));
      await tester.pump();
      expect(selectedRole, UserRole.client);

      // Tap worker card
      await tester.tap(find.text('I offer services'));
      await tester.pump();
      expect(selectedRole, UserRole.worker);
    });
  });
}
