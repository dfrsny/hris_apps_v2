import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:material_ui/material_ui.dart';

class AppSnackbar {
  AppSnackbar._();

  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(
    BuildContext context, {
    String title = 'Berhasil',
    required String message,
  }) {
    _show(
      context,
      title: title,
      message: message,
      contentType: ContentType.success,
    );
  }

  static void showError(
    BuildContext context, {
    String title = 'Terjadi Kesalahan',
    required String message,
  }) {
    _show(
      context,
      title: title,
      message: message,
      contentType: ContentType.failure,
    );
  }

  static void showWarning(
    BuildContext context, {
    String title = 'Perhatian',
    required String message,
  }) {
    _show(
      context,
      title: title,
      message: message,
      contentType: ContentType.warning,
    );
  }

  static void showInfo(
    BuildContext context, {
    String title = 'Informasi',
    required String message,
  }) {
    _show(
      context,
      title: title,
      message: message,
      contentType: ContentType.help,
    );
  }

  static void _show(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    final messenger =
        rootScaffoldMessengerKey.currentState ??
        ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
