/// Shared state that flows through the sequential API demo pipeline.
class ApiContext {
  bool configFetched = false;
  bool profileFetched = false;
  bool dataSynced = false;

  int syncAttempts = 0;

  // Configurations from UI
  bool forceProfileDelay = false;
  bool forceSyncFail = false;
}
