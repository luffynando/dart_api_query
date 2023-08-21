/// Wrapped response from json and helper to assign properties on
/// Schema model
class ResourceObject {
  /// Default constructor
  ResourceObject(this.attributes);

  /// Create a resource object from another object
  ResourceObject.from(ResourceObject other)
      : this(Map<String, dynamic>.from(other.attributes));

  /// Attributes of resource object
  Map<String, dynamic> attributes;

  /// Retrieve attribute and return to specific type. Use dot notation in key
  /// to access nested keys.
  T getAttribute<T>(String key) {
    final rawAttribute = mapGetter<T>(attributes, key);

    switch (T.toString()) {
      case 'bool':
        return (rawAttribute ?? false) as T;
      case 'String':
        return (rawAttribute ?? '') as T;
      case 'int':
        return (rawAttribute ?? 0) as T;
      case 'double':
        return (rawAttribute ?? 0.0) as T;
      case 'List<bool>':
        return rawAttribute == null
            ? List<bool>.empty() as T
            : (rawAttribute as List).cast<bool>() as T;
      case 'List<String>':
        return rawAttribute == null
            ? List<String>.empty() as T
            : (rawAttribute as List).cast<String>() as T;
      case 'List<int>':
        return rawAttribute == null
            ? List<int>.empty() as T
            : (rawAttribute as List).cast<int>() as T;
      case 'List<double>':
        return rawAttribute == null
            ? List<double>.empty() as T
            : (rawAttribute as List).cast<double>() as T;
    }

    return rawAttribute as T;
  }

  /// Set attribute from key, value. Use dot notation in key
  /// to access nested keys.
  void setAttribute<T>(String key, T value) {
    dynamic rawValue;
    switch (T) {
      case String:
        rawValue = value == '' ? null : value;
      default:
        rawValue = value;
    }

    attributes = mapSetter(attributes, key, rawValue);
  }

  /// Get value from a Map by path. Use dot notation in path to access nested
  /// keys. If location path does´t exist, it will return null.
  T? mapGetter<T>(dynamic map, String path) {
    final keys = path.split('.');
    final key = keys[0];

    if (map is! Map) {
      return null;
    }

    if (!map.containsKey(key)) {
      return null;
    }

    if (keys.length == 1) {
      return map[key] as T;
    }

    return mapGetter(map[keys.removeAt(0)], keys.join('.'));
  }

  /// Sets value to the Map by path. If location of path does´t exist,
  /// it will created.
  Map<String, dynamic> mapSetter<T>(
    Map<String, dynamic>? map,
    String path,
    T value,
  ) {
    final keys = path.split('.');
    final key = keys[0];
    final target = map ?? {};

    if (keys.length == 1) {
      return Map<String, dynamic>.from({
        ...target,
        key: value,
      });
    }

    return Map<String, dynamic>.from({
      ...target,
      key: mapSetter(
        target[keys.removeAt(0)] is Map<String, dynamic>
            ? target[keys.removeAt(0)] as Map<String, dynamic>
            : {},
        keys.join('.'),
        value,
      ),
    });
  }
}
