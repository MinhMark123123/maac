class AppRoutes {
  AppRoutes._();
  static const landing = "/";
  
  // Level 1: Basic
  static const basic = "/01_basic";
  static const basicDetail = "/01_basic/detail/:id";
  
  // Level 2: DI
  static const di = "/02_di";
  static const diDetail = "/02_di/detail/:id";
  
  // Level 3: Full Power
  static const full = "/03_full";
  static const fullDetail = "/03_full/detail/:id";
}