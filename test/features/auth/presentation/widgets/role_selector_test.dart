import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_tracker/features/auth/domain/enums/user_role.dart';
import 'package:playing_tracker/features/auth/presentation/widgets/role_selector.dart';
import 'package:playing_tracker/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest({
    required UserRole selectedRole,
    required ValueChanged<UserRole> onRoleSelected,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: Scaffold(
        body: Center(
          child: RoleSelector(
            selectedRole: selectedRole,
            onRoleSelected: onRoleSelected,
          ),
        ),
      ),
    );
  }

  group('RoleSelector Tests', () {
    testWidgets('shows both role options', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          selectedRole: UserRole.teacher,
          onRoleSelected: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Docente'), findsOneWidget);
      expect(find.text('Alumno'), findsOneWidget);
      expect(find.byIcon(Icons.school_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('calls onRoleSelected when student is tapped', (WidgetTester tester) async {
      UserRole? selected;

      await tester.pumpWidget(
        createWidgetUnderTest(
          selectedRole: UserRole.teacher,
          onRoleSelected: (role) => selected = role,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alumno'));
      await tester.pump();

      expect(selected, UserRole.student);
    });

    testWidgets('calls onRoleSelected when teacher is tapped', (WidgetTester tester) async {
      UserRole? selected;

      await tester.pumpWidget(
        createWidgetUnderTest(
          selectedRole: UserRole.student,
          onRoleSelected: (role) => selected = role,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Docente'));
      await tester.pump();

      expect(selected, UserRole.teacher);
    });
  });
}
