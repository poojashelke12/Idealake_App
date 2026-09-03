/// Centralized Asset Paths for images, icons, and SVG assets
class AssetPaths {
  AssetPaths._();

  static const String _imagesBase = 'assets/images';
  static const String _iconsBase = 'assets/icons';

  // Images
  static const String appLogo = '$_imagesBase/idealake_logo.png';
  static const String ltfsLogo = '$_imagesBase/ltfs_logo.png';
  static const String splashBackground = '$_imagesBase/splash_bg.png';
  static const String placeholderImage = '$_imagesBase/placeholder.png';
  static const String emptyState = '$_imagesBase/empty_state.png';
  static const String errorState = '$_imagesBase/error_state.png';

  // Icons
  static const String icHome = '$_iconsBase/ic_home.svg';
  static const String icServices = '$_iconsBase/ic_services.svg';
  static const String icSolutions = '$_iconsBase/ic_solutions.svg';
  static const String icProfile = '$_iconsBase/ic_profile.svg';
  static const String icNotification = '$_iconsBase/ic_notification.svg';
}
