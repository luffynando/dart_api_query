import 'package:dart_api_query/src/qs/stringify_options.dart';
import 'package:dart_api_query/src/query_parameters.dart';
import 'package:dart_api_query/src/resource_collection.dart';
import 'package:dart_api_query/src/resource_object.dart';
import 'package:dart_api_query/src/serializer.dart';

/// Schemas provide getters and setters that help us transform responses into
/// objects with their own attributes, relationships, related objects and
/// errors.
class Schema {
  /// Default constructor
  Schema(this.resourceObject);

  /// Create schema with attributes
  Schema.create({Map<String, dynamic>? attributes})
      : resourceObject =
            ResourceObject.create(attributes ?? <String, dynamic>{});

  /// Create empty schema model
  Schema.init() : this.create();

  /// Create from another schema model
  Schema.from(Schema other) : this(ResourceObject.from(other.resourceObject));

  /// Create from other mode shallow copy
  Schema.shallowCopy(Schema other) : this(other.resourceObject);

  final Serializer _serializer = Serializer();

  /// A wrap object from raw response
  ResourceObject resourceObject;

  /// Retrieve raw attributes of model schema
  Map<String, dynamic> get attributes => resourceObject.attributes;

  /// Retrieve id of schema
  dynamic get id => resourceObject.id;

  /// Helper function to get attribute. Use dot notation in key to access
  /// nested keys.
  T getAttribute<T>(String key) => resourceObject.getAttribute<T>(key);

  /// Helper function to set attribute. Use dot notation in key to access
  /// nested keys.
  void setAttribute<T>(String key, T value) =>
      resourceObject.setAttribute<T>(key, value);

  /// Load relation hasOne for Schema specified. Throws a StateError if
  /// relationshipPath not exists or is null.
  T hasOne<T>(
    String relationshipPath,
    T Function(ResourceObject object) createInstance,
  ) {
    final instanceModel = hasOneOrNull(relationshipPath, createInstance);
    if (instanceModel == null) {
      throw StateError('Relation not found.');
    }

    return instanceModel;
  }

  /// Load relation hasOne for Schema specified. Or returns null if
  /// relationshipPath not exists or is null.
  T? hasOneOrNull<T>(
    String relationshipPath,
    T Function(ResourceObject object) createInstance,
  ) {
    final data = getAttribute<Map<String, dynamic>?>(relationshipPath);
    return data != null ? createInstance(deserializeOne(data)) : null;
  }

  /// Load relation hasMap for Schema specified. Throws a StateError if
  /// relationshipPath not exists or is null.
  Iterable<T> hasMany<T>(
    String relationshipPath,
    T Function(ResourceObject object) createInstance,
  ) {
    final iterableModels = hasManyOrNull(relationshipPath, createInstance);
    if (iterableModels == null) {
      throw StateError('Relation not found.');
    }

    return iterableModels;
  }

  /// Load relation hasMap for Schema specified. Or returns null if
  /// relationshipPath not exists or is null.
  Iterable<T>? hasManyOrNull<T>(
    String relationshipPath,
    T Function(ResourceObject object) createInstance,
  ) {
    final data = getAttribute<dynamic>(relationshipPath);

    try {
      return deserializeMany(data)
          .map((resourceObject) => createInstance(resourceObject));
    } catch (e) {
      return null;
    }
  }

  /// Check if id is assigned
  bool get isNew => resourceObject.isNew;

  /// From data to Resource Object
  ResourceObject deserializeOne(Map<String, dynamic> data) =>
      _serializer.deserialize(data);

  /// From data to Resource Collection
  ResourceCollection deserializeMany(dynamic data) =>
      _serializer.deserializeMany(data);

  /// Override baseURL for only model. Not for all.
  String? baseURL() {
    return null;
  }

  /// Get model name or target endpoint route
  String resource() {
    // ignore: no_runtimeType_toString
    return '${runtimeType}s'.toLowerCase();
  }

  /// Get default parameterNames
  QueryParameters parameterNames() {
    return QueryParameters(
      include: 'include',
      filter: 'filter',
      sort: 'sort',
      fields: 'fields',
      append: 'append',
      page: 'page',
      limit: 'limit',
    );
  }

  /// Default stringifyOptions
  StringifyOptions stringifyOptions() {
    return StringifyOptions(arrayFormat: ArrayFormat.comma);
  }
}
