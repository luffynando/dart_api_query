import 'package:dart_api_query/src/schema.dart';

/// Wrapped response collection from json and helper to assign
/// properties on Schema model
class ResourcePagination<T extends Schema> extends Iterable<T> {
  /// Default constructor
  ResourcePagination(this.models, this.total);

  /// Collection of models
  Iterable<T> models;

  /// Total of all resourceObjects
  int total;

  @override
  Iterator<T> get iterator => models.iterator;
}
