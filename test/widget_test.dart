// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:playing_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:playing_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:playing_tracker/features/classes/domain/repositories/class_repository.dart';
import 'package:playing_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:playing_tracker/main.dart';

import 'helpers/mock_hydrated_storage.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockClassRepository extends Mock implements ClassRepository {}

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late _MockAuthRepository mockAuthRepository;
  late _MockClassRepository mockClassRepository;
  late _MockTaskRepository mockTaskRepository;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    initHydratedStorage();
    mockAuthRepository = _MockAuthRepository();
    mockClassRepository = _MockClassRepository();
    mockTaskRepository = _MockTaskRepository();
    when(() => mockAuthRepository.currentUser).thenReturn(null);
  });

  testWidgets('Playing Tracker app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      PlayingTrackerApp(
        authRepository: mockAuthRepository,
        authCubitBuilder: AuthCubit.new,
        classRepository: mockClassRepository,
        taskRepository: mockTaskRepository,
      ),
    );

    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Bienvenido'), findsOneWidget);
  });
}
