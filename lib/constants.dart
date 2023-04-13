class Constants {
  Constants._();

  static const String encryptionKey = 'encryption_key';

  /// ------- Sensitive
  static const String firebaseWebAPIKey =
      'AIzaSyBmi7yBY3WTjLyciXXvkkYfQS9HG4X_emk';

  static const String openAIKey = 'openai_api_key';

  /// ------- Data
  static const String firebaseFunctionsBaseURL =
      'us-central1-saad-ardati.cloudfunctions.net';
  static const String user = 'user';

  // FireDart
  static const String auth = 'auth';
  static const String authToken = 'authToken';
  static const String userModel = 'userModel';

  /// ------- Firestore
  static const String collectionUsers = 'users';
  static const String collectionChats = 'chats';

  /// ------- General
  static const String gptModels = 'gpt_models';
  static const String isFirstTime = 'is_first_time';
  static const String history = 'history';

  /// ------- Settings
  static const String settings = 'settings';
  static const String alwaysOnTop = 'always_on_top';
  static const String checkForUpdates = 'check_for_updates';
  static const String launchOnStartup = 'launch_on_startup';
  static const String openHistoryOnWideScreen = 'open_history_on_wide_screen';
  static const String shouldPreserveWindowPosition =
      'should_preserve_window_position';
  static const String showTitleBar = 'show_title_bar';
  static const String moveToSystemDock = 'move_to_system_dock';
  static const String macOSLeftClickOpensApp = 'macos_left_click_opens_app';

  /// ------- Window Meta
  static const String retainedWindowX = 'retained_window_x';
  static const String retainedWindowY = 'retained_window_y';
  static const String retainedWindowWidth = 'retained_window_width';
  static const String retainedWindowHeight = 'retained_window_height';

  static const String windowX = 'window_x';
  static const String windowY = 'window_y';
  static const String windowWidth = 'window_width';
  static const String windowHeight = 'window_height';

  /// ------- System Meta
  static const String trayPositionX = 'tray_position_x';
  static const String trayPositionY = 'tray_position_y';
  static const String systemDockPosition = 'system_dock_position';
}
