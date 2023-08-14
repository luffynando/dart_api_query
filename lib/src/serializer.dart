import 'package:dart_api_query/src/exceptions.dart';
import 'package:dart_api_query/src/resource_collection.dart';
import 'package:dart_api_query/src/resource_object.dart';

/// Serializer dio response to scheme resource object or resource collection
class Serializer {
  /// From responseData of dio to Resource Object
  ResourceObject deserialize(Map<String, dynamic> responseData) {
    final data = responseData['data'] ?? responseData;
    if (data is! Map<String, dynamic>) {
      throw DeserializationException();
    }

    return ResourceObject(data['id'], data);
  }

  /// From responseData of dio to Resource Collection
  ResourceCollection deserializeMany(dynamic responseData) {
    final collection = (responseData is Iterable
            ? responseData
            : (responseData is Map<String, dynamic> &&
                    responseData['data'] is Iterable
                ? responseData['data'] as Iterable
                : <dynamic>[]))
        .map((item) {
      if (item is! Map<String, dynamic>) {
        throw DeserializationException();
      }

      return ResourceObject(item['id'], item);
    });

    return ResourceCollection(collection);
  }
}
