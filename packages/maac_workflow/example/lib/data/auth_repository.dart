/// Simulates the backend calls the signup wizard depends on.
class AuthRepository {
  Future<String> createAccount(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return 'usr_mock_${DateTime.now().millisecondsSinceEpoch % 100000}';
  }

  Future<void> deleteAccount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  /// [forceFail] simulates the server rejecting final registration, driven
  /// by the review screen's "force fail" toggle.
  Future<void> finalizeRegistration({required bool forceFail}) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (forceFail) {
      throw Exception('Failed to finalize registration (forced API error).');
    }
  }
}
