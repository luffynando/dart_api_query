import 'package:weak_map/weak_map.dart';

/// Store information about any value in a side channel.
class SideChannel {
  /// Get a instance of side channel.
  SideChannel() : _wm = null;

  WeakMap<dynamic, dynamic>? _wm;

  /// Check if side channel contain key or thrown if not.
  void contain(dynamic key) {
    if (!has(key)) {
      throw AssertionError('Side channel does not contain key');
    }
  }

  /// Retrieve a value if key exists or returns null if not.
  dynamic get(dynamic key) {
    if (key != null && _wm != null) {
      return _wm!.get(key);
    }

    return null;
  }

  /// Check if side channel contain key
  bool has(dynamic key) {
    if (key != null && _wm != null) {
      return _wm!.contains(key);
    }

    return false;
  }

  /// Add value in side channel with specific key
  void set(dynamic key, dynamic value) {
    if (key != null) {
      _wm ??= WeakMap();
      _wm!.add(key: key, value: value);
    }
  }
}
