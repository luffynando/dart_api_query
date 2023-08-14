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

  /// Helper function to get attribute
  T getAttribute<T>(String key) => resourceObject.getAttribute<T>(key);

  /// Helper function to set attribute
  void setAttribute<T>(String key, T value) =>
      resourceObject.setAttribute<T>(key, value);

  /// Check if id is assigned
  bool get isNew => resourceObject.isNew;

  /// Retrieve id of relationship name for has one
  String? idFor(String relationshipName, {String idKey = 'id'}) =>
      resourceObject.idFor(relationshipName, idKey: idKey);

  /// Retrieve data of relationship for has one
  Map<String, dynamic> dataForHasOne(String relationshipName) =>
      resourceObject.dataForHasOne(relationshipName);

  /// Retrieve data of relationship for has Many
  Iterable<dynamic>? dataForHasMany(String relationshipName) =>
      resourceObject.dataForHasMany(relationshipName);

  /// Retrieve List of ids from relationship name
  Iterable<String> idsFor(String relationshipName, {String idKey = 'id'}) =>
      resourceObject.idsFor(relationshipName, idKey: idKey);

  /// From data to Resource Object
  ResourceObject deserializeOne(Map<String, dynamic> data) =>
      _serializer.deserialize(data);

  /// From data to Resource Collection
  ResourceCollection deserializeMany(dynamic data) {
    return _serializer.deserializeMany(data);
  }

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
