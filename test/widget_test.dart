// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/core/constants/app_strings.dart';
import 'package:playing_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/main.dart';

import 'helpers/mock_hydrated_storage.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository mockAuthRepository;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    initHydratedStorage();
    mockAuthRepository = _MockAuthRepository();
    when(() => mockAuthRepository.currentUser).thenReturn(null);
  });

  testWidgets('Playing Tracker app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      PlayingTrackerApp(
        authRepository: mockAuthRepository,
        authCubitBuilder: (repository) =>
            AuthCubit(repository, shouldCheckAuthState: false),
      ),
    );

    // Allow router to settle and verify that the login welcome title is shown
    await tester.pumpAndSettle();
    expect(find.text(AuthStrings.welcomeTitle), findsOneWidget);
  });
}
