/// Wrapped response from json and helper to assign properties on
/// Schema model
class ResourceObject {
  /// Default constructor
  ResourceObject(this.id, this.attributes);

  /// Create a resource object with specific attributes
  ResourceObject.create(this.attributes);

  /// Create a resource object from another object
  ResourceObject.from(ResourceObject other)
      : this(other.id, Map<String, dynamic>.from(other.attributes));

  /// Id of current resource object
  dynamic id;

  /// Attributes of resource object
  Map<String, dynamic> attributes;

  /// Check if id is assigned
  bool get isNew => id == null;

  /// Retrieve attribute and return to specific type
  T getAttribute<T>(String key) {
    final rawAttribute = attributes[key];

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

  /// Set attribute from key, value
  void setAttribute<T>(String key, T value) {
    dynamic rawValue;
    switch (T) {
      case String:
        rawValue = value == '' ? null : value;
      default:
        rawValue = value;
    }

    attributes[key] = rawValue;
  }

  /// Retrieve id of relationship name for has one
  String? idFor(String relationshipName, {String idKey = 'id'}) =>
      dataForHasOne(relationshipName)[idKey] as String;

  /// Retrieve List of ids from relationship name
  Iterable<String> idsFor(String relationshipName, {String idKey = 'id'}) =>
      attributes.containsKey(relationshipName)
          ? dataForHasMany(relationshipName)
              .map((record) => (record as Map<String, String>)[idKey]!)
          : <String>[];

  /// Retrieve data of relationship for has one
  Map<String, dynamic> dataForHasOne(String relationshipName) =>
      attributes.containsKey(relationshipName)
          ? (attributes[relationshipName] as Map<String, dynamic>? ??
              <String, dynamic>{})
          : <String, dynamic>{};

  /// Retrieve data of relationship for has Many
  Iterable<dynamic> dataForHasMany(String relationshipName) =>
      attributes[relationshipName] as Iterable<dynamic>? ?? [];
}
