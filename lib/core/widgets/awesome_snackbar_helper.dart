import 'package:material_ui/material_ui.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class AwesomeSnackbarHelper {
  AwesomeSnackbarHelper._();

  /// Shortcut untuk varian success
  static void success(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) => showSnackBar(
    context,
    title: title,
    message: message,
    contentType: ContentType.success,
    duration: duration,
  );

  /// Shortcut untuk varian failure
  static void failure(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) => showSnackBar(
    context,
    title: title,
    message: message,
    duration: duration,
  );

  /// Shortcut untuk varian warning
  static void warning(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) => showSnackBar(
    context,
    title: title,
    message: message,
    contentType: ContentType.warning,
    duration: duration,
  );

  /// Shortcut untuk varian help
  static void help(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) => showSnackBar(
    context,
    title: title,
    message: message,
    contentType: ContentType.help,
    duration: duration,
  );

  /// Menampilkan Awesome SnackBar (floating)
  static void showSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    ContentType contentType = ContentType.failure,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsetsGeometry? margin,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          // Wajib agar tampilan awesome_snackbar_content maksimal
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: behavior,
          duration: duration,
          margin: margin,
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: contentType,
          ),
        ),
      );
  }

  /// Menampilkan Awesome MaterialBanner
  static void showBanner(
    BuildContext context, {
    required String title,
    required String message,
    ContentType contentType = ContentType.success,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          // Wajib agar tampilan awesome_snackbar_content maksimal
          elevation: 0,
          backgroundColor: Colors.transparent,
          forceActionsBelow: true,
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: contentType,
            inMaterialBanner: true,
          ),
          actions: const [SizedBox.shrink()],
        ),
      );
  }
}
