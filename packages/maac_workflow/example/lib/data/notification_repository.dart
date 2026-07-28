/// Simulates the OS notification-permission prompt behind the sequential
/// API demo's second, independent pipeline.
class NotificationRepository {
  /// [forceDeny] simulates the user denying the (fake) permission prompt,
  /// driven by the UI's "force deny" toggle.
  Future<void> requestPermission({required bool forceDeny}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (forceDeny) {
      throw Exception('Notification permission denied');
    }
  }
}
