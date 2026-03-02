// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTab => 'Home';

  @override
  String get classesTab => 'Classes';

  @override
  String get historyTab => 'History';

  @override
  String get statisticsTab => 'Statistics';

  @override
  String get settingsTab => 'Settings';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get loading => 'Loading...';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get confirm => 'Confirm';

  @override
  String get loadMore => 'Load more';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied to clipboard';

  @override
  String get download => 'Download';

  @override
  String fieldRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalidFormat => 'Invalid email format';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters long';

  @override
  String get confirmPasswordRequired => 'You must confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String nameMinLength(String fieldName) {
    return '$fieldName must be at least 3 characters long';
  }

  @override
  String nameInvalidCharacters(String fieldName) {
    return '$fieldName can only contain letters and spaces';
  }

  @override
  String get atLeastOneClassRequired => 'You must select at least one class';

  @override
  String get firstNameField => 'First name';

  @override
  String get lastNameField => 'Last name';

  @override
  String get loginTitle => 'Login';

  @override
  String get registerTitle => 'Create account';

  @override
  String get forgotPasswordTitle => 'Recover password';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get loginSubtitle => 'Login to continue';

  @override
  String get createAccountTitle => 'Create your account';

  @override
  String get createAccountSubtitle => 'Complete the form to register';

  @override
  String get forgotPasswordQuestion => 'Forgot your password?';

  @override
  String get forgotPasswordInstructions =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get accountTypeLabel => 'Account type';

  @override
  String get emailHint => 'user@example.com';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordMinLengthHint => 'Minimum 6 characters';

  @override
  String get confirmPasswordHint => 'Repeat your password';

  @override
  String get firstNameHint => 'Enter your first name';

  @override
  String get lastNameHint => 'Enter your last name';

  @override
  String get teacherRole => 'Teacher';

  @override
  String get studentRole => 'Student';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get sendRecoveryLinkButton => 'Send recovery link';

  @override
  String get noAccountQuestion => 'Don\'t have an account? ';

  @override
  String get registerLink => 'Register';

  @override
  String get alreadyHaveAccountQuestion => 'Already have an account? ';

  @override
  String get loginLink => 'Login';

  @override
  String get forgotPasswordLink => 'Forgot your password?';

  @override
  String get rememberPasswordQuestion => 'Remembered your password? ';

  @override
  String get acceptTermsPrefix => 'I accept the ';

  @override
  String get termsAndConditions => 'terms and conditions';

  @override
  String get acceptTermsMiddle => ' and the ';

  @override
  String get privacyPolicy => 'privacy policy';

  @override
  String get emailSentTitle => 'Email sent';

  @override
  String get emailSentMessage =>
      'Check your inbox. If you don\'t find the email, check your spam folder.';

  @override
  String get termsNotAcceptedMessage =>
      'You must accept the terms and conditions';

  @override
  String get loginErrorSemanticLabel => 'Login error. Check the entered data.';

  @override
  String get registerErrorSemanticLabel =>
      'Registration error. Check the form information.';

  @override
  String get forgotPasswordSuccessSemanticLabel =>
      'Recovery link sent successfully.';

  @override
  String get forgotPasswordErrorSemanticLabel =>
      'Could not send recovery link.';

  @override
  String get teacherHomeTitle => 'Teacher Home';

  @override
  String welcomeUser(String name) {
    return 'Hello, $name';
  }

  @override
  String get studentHomeTitle => 'Student Home';

  @override
  String get quickActionsTitle => 'Quick Actions';

  @override
  String get teacherWelcomeTitle => 'Your classes are ready';

  @override
  String get teacherWelcomeSubtitle =>
      'Manage your classes, assign tasks, and monitor your students\' progress.';

  @override
  String get studentWelcomeTitle => 'Your practice continues';

  @override
  String get studentWelcomeSubtitle =>
      'Review your active classes, join new sections, and keep your sessions logged.';

  @override
  String get teacherQuickActionsSubtitle =>
      'Manage your day-to-day from one place.';

  @override
  String get studentQuickActionsSubtitle =>
      'Keep moving forward with your classes and pending tasks.';

  @override
  String get manageClassesAction => 'My classes';

  @override
  String get manageClassesDescription =>
      'Check or create new classes for your students.';

  @override
  String get createClassAction => 'Create class';

  @override
  String get createClassDescription =>
      'Open a new class and share its access code.';

  @override
  String get teacherTasksAction => 'Assigned tasks';

  @override
  String get teacherTasksDescription => 'Create, edit, or review active tasks.';

  @override
  String get teacherStatsAction => 'Statistics';

  @override
  String get teacherStatsDescription =>
      'Analyze weekly progress and active students.';

  @override
  String get studentClassesAction => 'My classes';

  @override
  String get studentClassesDescription =>
      'Explore the classes you\'re enrolled in.';

  @override
  String get joinClassAction => 'Join class';

  @override
  String get joinClassDescription => 'Enter the code shared by your teacher.';

  @override
  String get studentTasksAction => 'My tasks';

  @override
  String get studentTasksDescription =>
      'Review your pending tasks and mark your progress.';

  @override
  String get practiceAction => 'Continue practice';

  @override
  String get practiceDescription =>
      'Log new sessions and keep your streak active.';

  @override
  String get studentStatsAction => 'My statistics';

  @override
  String get studentStatsDescription =>
      'Check your personal metrics and celebrate your achievements.';

  @override
  String get highlightsTitle => 'Quick summary';

  @override
  String get teacherHighlightsDescription =>
      'Soon you\'ll see alerts for low-activity classes and upcoming task deadlines.';

  @override
  String get studentHighlightsDescription =>
      'Soon you\'ll be able to see your upcoming tasks and total time spent.';

  @override
  String get myClassesTitle => 'My Classes';

  @override
  String get classesCreatedTitle => 'Created classes';

  @override
  String get noClassesCreated => 'You have no created classes';

  @override
  String get createFirstClass => 'Create your first class to begin';

  @override
  String get noClassesJoined => 'You\'re not in any class';

  @override
  String get joinClassWithCode => 'Join a class with a code';

  @override
  String studentsCount(int count) {
    return '$count students';
  }

  @override
  String get teacherLabel => 'Teacher: ';

  @override
  String get classNameLabel => 'Class name';

  @override
  String get classNameHint => 'Ex: Piano Level 1';

  @override
  String get classDescriptionLabel => 'Description';

  @override
  String get classDescriptionHint => 'Class description';

  @override
  String get accessCodeLabel => 'Access code';

  @override
  String get accessCodeGenerated => 'Will be generated automatically';

  @override
  String get accessCodeInvalidFormat => 'The code must be 6 valid characters';

  @override
  String get classStatusActive => 'Active';

  @override
  String get classStatusArchived => 'Archived';

  @override
  String get archiveClassAction => 'Archive class';

  @override
  String get activateClassAction => 'Activate class';

  @override
  String get deleteClassConfirmation =>
      'Are you sure you want to permanently delete this class? This action cannot be undone.';

  @override
  String get regenerateAccessCodeAction => 'Regenerate code';

  @override
  String get regenerateCodeConfirmation =>
      'We will generate a new code and the previous one will stop working.';

  @override
  String get accessCodeHint => 'Enter class code';

  @override
  String get accessCodeInstructions =>
      'Ask your teacher for the access code to join the class.';

  @override
  String get classCreateSuccess => 'Class created successfully.';

  @override
  String tasksCount(int count) {
    return '$count tasks';
  }

  @override
  String get createdDateLabel => 'Created on';

  @override
  String activeStudentsCount(int count) {
    return '$count active students';
  }

  @override
  String get assignedToLabel => 'Assigned to';

  @override
  String get averageDurationLabel => 'Average per student';

  @override
  String get classStatusUpdatedSuccess => 'Class status updated successfully.';

  @override
  String get classDeleteSuccess => 'Class was deleted successfully.';

  @override
  String get membershipJoinSuccess => 'You joined the class successfully.';

  @override
  String get membershipRegenerateSuccess =>
      'Access code regenerated successfully.';

  @override
  String get membershipServiceError =>
      'An error occurred while processing the request.';

  @override
  String get genericOperationSuccess => 'Operation completed successfully.';

  @override
  String get membershipInactiveError =>
      'You cannot join this class because your membership has been deactivated. Contact your teacher.';

  @override
  String get classGenericError =>
      'An error occurred while managing your classes.';

  @override
  String get classCreateError => 'Failed to create class. Try again.';

  @override
  String get classUpdateError => 'Failed to update class.';

  @override
  String get classLoadError => 'An error occurred while loading your classes.';

  @override
  String get classRefreshNoTeacherError =>
      'No teacher configured to update classes.';

  @override
  String get deleteClassAction => 'Delete class';

  @override
  String get joinButtonLabel => 'Join';

  @override
  String get createClassButtonLabel => 'Create class';

  @override
  String get tasksTab => 'Tasks';

  @override
  String get studentsTab => 'Students';

  @override
  String get infoTab => 'Information';

  @override
  String get classDetailTitle => 'Class detail';

  @override
  String get manageStudentsTitle => 'Manage students';

  @override
  String get classStatisticsTitle => 'Class statistics';

  @override
  String get totalTime => 'Total time';

  @override
  String get totalTimeDescription => 'Total time of all students';

  @override
  String get totalSessions => 'Total sessions';

  @override
  String get activeStudents => 'Active students';

  @override
  String get classArchivedExitMessage =>
      'This class was archived and is no longer available.';

  @override
  String get classDeletedExitMessage =>
      'The class was deleted and we\'ll return to the list.';

  @override
  String get membershipRevokedExitMessage =>
      'Your access to this class was revoked.';

  @override
  String get studentsListTitle => 'Class Students';

  @override
  String get joinedAtLabel => 'Joined on';

  @override
  String sessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String hoursCount(int count) {
    return '$count hours';
  }

  @override
  String get removeStudent => 'Remove student';

  @override
  String get removeStudentConfirmation =>
      'This action will remove the student from the class.';

  @override
  String get noStudentsInClass => 'No students in this class';

  @override
  String get studentsJoinWithCode => 'Students can join with the access code';

  @override
  String get createTask => 'Create new task';

  @override
  String get myTasksTitle => 'My tasks';

  @override
  String get taskDetailTitle => 'Task detail';

  @override
  String get assignedTo => 'Assigned to';

  @override
  String get startStudySession => 'Start study session';

  @override
  String get taskTitleLabel => 'Task title';

  @override
  String get taskTitleHint => 'Ex: C Major Scales';

  @override
  String get taskDescriptionLabel => 'Description';

  @override
  String get estimatedTimeLabel => 'Estimated time (minutes)';

  @override
  String get noTasksInClass => 'No tasks in this class';

  @override
  String get confirmDeleteTaskMessage =>
      'This action will delete the task for all students.';

  @override
  String daysRemaining(int days) {
    return '$days days remaining';
  }

  @override
  String overdueDays(int days) {
    return 'Overdue by $days days';
  }

  @override
  String get timerTitle => 'Timer';

  @override
  String get sessionHistoryTitle => 'Session History';

  @override
  String get sessionHistoryDescription =>
      'Check your practice history and progress.';

  @override
  String get elapsedTime => 'Elapsed time';

  @override
  String get noSessions => 'No sessions logged';

  @override
  String get generalOverview => 'General Overview';

  @override
  String get currentStreak => 'Current streak';

  @override
  String daysStreak(int days) {
    return '$days days';
  }

  @override
  String get profileSection => 'Profile';

  @override
  String get taskDescriptionHint => 'Explain what the student should practice';

  @override
  String get estimatedTimeHint => 'Ex: 20';

  @override
  String get dueDateHint => 'No due date';

  @override
  String get taskCreateSuccess => 'Task created successfully.';

  @override
  String get noStudentsInClassError =>
      'You cannot assign tasks to a class with no students.';

  @override
  String get addAttachment => 'Add attachment';

  @override
  String get deselectAllStudents => 'Deselect all';

  @override
  String get selectAllStudents => 'Select all';

  @override
  String get attachmentsLabel => 'Attachments';

  @override
  String get noAttachments => 'No attachments';

  @override
  String get attachmentsHint => 'You can add links or files';

  @override
  String get createTaskButton => 'Create task';

  @override
  String get myAssignmentsTitle => 'My assigned tasks';

  @override
  String get filters => 'Filters';

  @override
  String get adjustFilters => 'Adjust filters to see more results';

  @override
  String get noAssignmentsReceived => 'You haven\'t received tasks yet';

  @override
  String get filterByActiveStatus => 'Filter by status';

  @override
  String get showActiveOnly => 'Active only';

  @override
  String get showArchivedOnly => 'Archived only';

  @override
  String get filterByDate => 'Filter by date';

  @override
  String get selectCreatedDate => 'Creation date';

  @override
  String get selectDueDate => 'Due date';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get assignTask => 'Assign task';

  @override
  String get selectClassToAssign => 'Select a class to assign';

  @override
  String get recipientsTitle => 'Recipients';

  @override
  String get assignToAllStudents => 'All students';

  @override
  String selectedRecipients(int count) {
    return '$count selected';
  }

  @override
  String get assignToSelectedStudents => 'Selected students';

  @override
  String get filterByAssignmentStatus => 'Task status';

  @override
  String get pending => 'Pending';

  @override
  String get inProgress => 'In progress';

  @override
  String get completed => 'Completed';

  @override
  String get dueToday => 'Due today';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String get noDueDate => 'No deadline';

  @override
  String extraStudyTime(String time) {
    return 'Extra study: $time';
  }

  @override
  String get studyGoalReached => 'Goal reached!';

  @override
  String studyTimeRemaining(String time) {
    return '$time remaining';
  }

  @override
  String get taskProgressTitle => 'Task Progress';

  @override
  String get keepGoing => 'Keep it up!';

  @override
  String get confirmDeleteTask => 'Confirm deletion';

  @override
  String get confirmDeleteTaskWarning =>
      'WARNING: This action will PERMANENTLY delete the task and all student assignments. This information cannot be recovered. Do you want to continue?';

  @override
  String get deleteTaskAction => 'Delete task';

  @override
  String get editTaskAction => 'Edit task';

  @override
  String get activeTaskLabel => 'Active task';

  @override
  String get activeTaskSubtitle => 'Visible to students';

  @override
  String get inactiveTaskSubtitle => 'Not visible to students';

  @override
  String get startTimerAction => 'Start timer';

  @override
  String get estimatedTimeRowLabel => 'Estimated time';

  @override
  String get createdDateRowLabel => 'Creation date';

  @override
  String get dueDateRowLabel => 'Deadline';

  @override
  String get recipientsRowLabel => 'Recipients';

  @override
  String get noRecipientsLabel => 'No recipients assigned';

  @override
  String get reTryLoadAction => 'Retry loading';

  @override
  String get loadingTaskMessage => 'Loading task...';

  @override
  String get createTaskAction => 'Create task';

  @override
  String get noTasksFound => 'No tasks found';

  @override
  String get taskUpdateSuccess => 'Task updated successfully';

  @override
  String get taskDeleteSuccess => 'Task deleted successfully';

  @override
  String get loadingError => 'Error loading data';

  @override
  String get activitySummary => 'Activity summary';

  @override
  String get workedTasks => 'Worked tasks';

  @override
  String sessionsLabelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
      zero: 'No sessions',
    );
    return '$_temp0';
  }

  @override
  String get timerStart => 'Start';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerResume => 'Resume';

  @override
  String get timerReset => 'Reset';

  @override
  String get timerFinish => 'Finish session';

  @override
  String get startFirstSession => 'Start your first study session to begin';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get all => 'All';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get accountSection => 'Account';

  @override
  String get inDevelopment => 'This section is under development.';

  @override
  String get sessionDuration => 'Session duration';

  @override
  String get sessionDate => 'Session date';

  @override
  String get noFilteredSessions => 'No sessions for this filter';

  @override
  String get adjustDateFilter => 'Try changing the date filter';

  @override
  String get errorLoadingHistory => 'Error loading history';

  @override
  String get taskHistory => 'Task history';

  @override
  String get discardSessionTitle => 'Discard session?';

  @override
  String get discardSessionMessage =>
      'You will lose all progress from this practice session. Are you sure?';

  @override
  String get discardAction => 'Discard';

  @override
  String get sessionSavedTitle => 'Session Saved!';

  @override
  String timePracticedLabel(String time) {
    return 'Time practiced: $time';
  }

  @override
  String get continueAction => 'Continue';

  @override
  String get runningStatus => 'In progress...';

  @override
  String get pausedStatus => 'Paused';

  @override
  String get readyToStartStatus => 'Ready to start';

  @override
  String get notesLabel => 'Session notes (optional)';

  @override
  String get notesHint => 'Write your observations here...';

  @override
  String get confirmAndSaveAction => 'Confirm and save';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get themeSettings => 'Theme settings';

  @override
  String get futureFeatures =>
      'Future sprints will include:\n- Profile management\n- Notification preferences\n- Theme settings\n- Logout';

  @override
  String get studentsLabel => 'Students';

  @override
  String get logout => 'Logout';

  @override
  String get languageSection => 'Language & region';

  @override
  String get languageSettings => 'Language';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'Automatic (System)';

  @override
  String get colorSettings => 'Primary color';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get generalSection => 'General';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get termsAndConditionsLink => 'Terms and conditions';

  @override
  String get privacyPolicyLink => 'Privacy policy';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorRed => 'Red';

  @override
  String get filterThisWeek => 'This week';

  @override
  String get filterThisMonth => 'This month';

  @override
  String get filterLast3Months => 'Last 3 months';

  @override
  String get filterLast9Months => 'Last 9 months';

  @override
  String get filterAllTime => 'All time';
}
