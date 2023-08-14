import 'package:dart_api_query/src/resource_object.dart';

/// Wrapped response collection from json and helper to assign
/// properties on Schema model
class ResourceCollection extends Iterable<ResourceObject> {
  /// Default constructor
  ResourceCollection(this.docs);

  /// Response collection
  Iterable<ResourceObject> docs;

  @override
  Iterator<ResourceObject> get iterator => docs.iterator;
}
