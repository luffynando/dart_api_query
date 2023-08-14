import 'package:dart_api_query/src/builder.dart';
import 'package:dart_api_query/src/resource_collection.dart';
import 'package:dart_api_query/src/resource_object.dart';
import 'package:dart_api_query/src/schema.dart';
import 'package:dart_api_query/src/serializer.dart';
import 'package:dio/dio.dart';

/// Adapter for connect with api
final class ApiQuery {
  /// Retrieve singleton
  ApiQuery.of(this._schema, {Options? options})
      : _builder = Builder(_schema),
        _options = options,
        _serializer = Serializer() {
    if (ApiQuery.baseURL == null && _schema.baseURL() == null) {
      throw ArgumentError(
        'You must assign ApiQuery.baseURL property or model baseURL() method.',
      );
    }

    if (ApiQuery.http == null) {
      throw ArgumentError('You must set ApiQuery.http property.');
    }
  }

  /// Singleton instance of the HTTP client which is used to make requests.
  static Dio? http;

  /// Define a base url for a REST API
  static String? baseURL;

  final Builder _builder;
  final Schema _schema;
  final Serializer _serializer;
  String? _customResource;
  Options? _options;

  /// Retrieve instance of builder
  Builder getBuilder() {
    return _builder;
  }

  /// Retrieve current baseURL
  String baseUrl() {
    return _schema.baseURL() ?? ApiQuery.baseURL!;
  }

  /// Customize options of dio client
  void config(Options options) {
    _options = options;
  }

  /// Sometimes, we will want to eager load a relationship, and to do so,
  /// we can use the include method or its alias load.
  /// The arguments are the names of the relationships we want to include.
  /// We can pass as many arguments as we want.
  void include(List<String> args) {
    _builder.include(args);
  }

  /// Sometimes, we will want to eager load a relationship, and to do so,
  /// we can use the by method or its alias include.
  /// The arguments are the names of the relationships we want to include.
  /// We can pass as many arguments as we want.
  void load(List<String> args) {
    return include(args);
  }

  /// We can also append attributes to our queries using the append method.
  /// The arguments are the names of the attributes we want to append.
  /// We can pass as many arguments as we want.
  void append(List<String> attributes) {
    _builder.append(attributes);
  }

  /// The arguments are the names of the fields we want to select of the model
  void select(List<String> fields) {
    _builder.select(fields);
  }

  /// The argument is an object, which the name of the first key is the resource
  /// defined in the model class, the name of the other keys are the included
  /// relationships, and the values are arrays of fields.
  void selectFromRelations(Map<String, List<String>> fieldsFromRelationships) {
    _builder.selectFromRelations(fieldsFromRelationships);
  }

  /// The where method can be used to filter the query by evaluating a value
  /// against the column. The first argument is the name of the column, and the
  /// second argument is the value to evaluate.
  void where(String key, dynamic value) {
    _builder.where(key, value);
  }

  /// The whereNested method can be used to filter the query by evaluating a
  /// nested filter.
  void whereNested(Map<String, dynamic> nestedFilters) {
    _builder.whereNested(nestedFilters);
  }

  /// The whereIn method is similar to where, but it accepts multiple values
  /// instead of a single one. The first argument is the name of the column,
  /// and the second argument is an array of values to evaluate.
  void whereIn(String key, List<String> searchArray) {
    _builder.whereIn(key, searchArray);
  }

  /// The whereInNested method is similar to whereIn, but is used to filter the
  /// query using a nested filter. You can use whereNested or this alias.
  void whereInNested(Map<String, dynamic> nestedFilters) {
    _builder.whereInNested(nestedFilters);
  }

  /// The method orderBy. The arguments are the names of the properties we want
  /// to sort. We can pass as many arguments as we want.
  void orderBy(List<String> fields) {
    _builder.orderBy(fields);
  }

  /// Set the current page.
  void page(int value) {
    _builder.page(value);
  }

  /// Set the limit of records per page.
  void limit(int value) {
    _builder.limit(value);
  }

  /// We may also need to use parameters that are not provided by
  /// dart_api_query, and that's when the params method comes in to help.
  void params(Map<String, dynamic> payload) {
    _builder.params(payload);
  }

  /// We may need to add a clause based on a condition, and we can do so by
  /// using the when method. The first argument is the flag, and the second
  /// argument is the callback with the clause we want.
  void when(dynamic value, void Function(Builder, dynamic) callback) {
    _builder.when(value, callback);
  }

  /// Build custom endpoints.
  void custom(List<dynamic> args) {
    if (args.isEmpty) {
      throw ArgumentError(
        'The custom() method takes a minimum of one argument.',
      );
    }

    // It would be unintuitive for users to manage where the '/' has to be for
    // multiple arguments. We don't need it for the first argument if it's
    // a string, but subsequent string arguments need the '/' at the beginning.
    // We handle this implementation detail here to simplify the readme.
    var slash = '';
    final resource = StringBuffer();

    for (final value in args) {
      if (value is String) {
        resource.write('$slash${value.replaceFirst(r'/^\/+/', '')}');
      } else if (value is Schema) {
        resource.write('$slash${value.resource()}');

        if (!value.isNew) {
          resource.write('/${value.id}');
        }
      } else {
        throw ArgumentError(
          'Arguments to custom() must be strings or instances of model.',
        );
      }

      if (slash.isEmpty) {
        slash = '/';
      }
    }

    _customResource = resource.toString();
  }

  String? _fromResource;

  void _from(String url) {
    _fromResource = url;
  }

  /// Create a new related model.
  void forModel(List<Schema> args) {
    if (args.isEmpty) {
      throw ArgumentError(
        'The forModel() method takes a minimum of one argument.',
      );
    }

    final url = StringBuffer(baseUrl());

    for (final object in args) {
      if (object.isNew) {
        throw ArgumentError(
          'The object referenced of forModel() method has an invalid id.',
        );
      }

      url.write('/${object.resource()}/${object.id}');
    }

    url.write('/${_schema.resource()}');

    _from(url.toString());
  }

  /// Retrieve current endpoint.
  String endpoint() {
    if (_fromResource != null) {
      if (!_schema.isNew) {
        return '$_fromResource/${_schema.id}';
      } else {
        return '$_fromResource';
      }
    }

    if (!_schema.isNew) {
      return '${baseUrl()}/${_schema.resource()}/${_schema.id}';
    } else {
      return '${baseUrl()}/${_schema.resource()}';
    }
  }

  /// Execute the query and get all results.
  Future<ResourceCollection> all() async {
    var base = _fromResource ?? '${baseUrl()}/${_schema.resource()}';
    base = _customResource != null ? '${baseUrl()}/$_customResource' : base;
    final url = '$base${_builder.query()}';
    final response = await ApiQuery.http!.get<dynamic>(
      url,
      options: _options,
    );
    return _deserializeMany(response.data);
  }

  /// Execute the query and get first result.
  Future<ResourceObject?> first() async {
    return all().then((value) => value.firstOrNull);
  }

  /// Find a model by its primary key.
  Future<ResourceObject> find(dynamic id) async {
    final base = _fromResource ?? '${baseUrl()}/${_schema.resource()}';
    final url = '$base/$id${_builder.query()}';
    final response = await ApiQuery.http!.get<Map<String, dynamic>>(
      url,
      options: _options,
    );

    return _serializer.deserialize(response.data!);
  }

  ResourceCollection _deserializeMany(dynamic responseData) {
    return _serializer.deserializeMany(responseData);
  }
}
