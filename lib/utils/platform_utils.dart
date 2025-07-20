import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

bool isDesktopOrTablet() {
  // On web, we consider it as desktop for UI purposes
  if (kIsWeb) {
    return true;
  }

  // Use defaultTargetPlatform which is safe across all platforms
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.macOS:
    case TargetPlatform.linux:
      return true;
    case TargetPlatform.iOS:
      // Check if running on iPad
      final window = WidgetsBinding.instance.window;
      final size = window.physicalSize;
      final pixelRatio = window.devicePixelRatio;
      final width = size.width / pixelRatio;

      // iPad typically has a width greater than 768 points
      return width >= 768;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
      return false;
  }
}
