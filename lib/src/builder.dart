import 'package:dart_api_query/src/parser.dart';
import 'package:dart_api_query/src/schema.dart';

/// Create a query url with different params
class Builder {
  /// Create a instance of builder with a model has parameter
  Builder(this.model)
      : includes = [],
        appends = [],
        sorts = [],
        fields = {},
        filters = {},
        pageValue = null,
        limitValue = null,
        payload = null,
        _parser = null;

  /// List of names of the relationships we want to include.
  List<String> includes;

  /// List of names of the attributes we want to append.
  List<String> appends;

  /// Object with a fields we want to select.
  final Map<String, List<String>> fields;

  /// Object with a filters we want apply.
  Map<String, dynamic> filters;

  /// List names of the properties we want to sort
  List<String> sorts;

  /// Object with a parameters to include in query
  Map<String, dynamic>? payload;

  /// Current Schema to usage
  Schema model;

  /// Page
  int? pageValue;

  /// Limit
  int? limitValue;

  Parser? _parser;

  /// Query string parsed
  String query() {
    _parser ??= Parser(this);

    return _parser!.query();
  }

  /// Sometimes, we will want to eager load a relationship, and to do so,
  /// we can use the include method or its alias with.
  /// The arguments are the names of the relationships we want to include.
  /// We can pass as many arguments as we want.
  void include(List<String> relationships) {
    includes = relationships;
  }

  /// We can also append attributes to our queries using the append method.
  /// The arguments are the names of the attributes we want to append.
  /// We can pass as many arguments as we want.
  void append(List<String> attributes) {
    appends = attributes;
  }

  /// The arguments are the names of the fields we want to select of the model
  void select(List<String> fields) {
    if (fields.isEmpty) {
      throw ArgumentError('You must specify the fields on select() method.');
    }
    this.fields[model.resource()] = fields;
  }

  /// The argument is an object, which the name of the first key is the resource
  /// defined in the model class, the name of the other keys are the included
  /// relationships, and the values are arrays of fields.
  void selectFromRelations(Map<String, List<String>> fieldsFromRelationships) {
    fieldsFromRelationships.forEach((key, value) {
      fields[key] = value;
    });
  }

  /// The where method can be used to filter the query by evaluating a value
  /// against the column. The first argument is the name of the column, and the
  /// second argument is the value to evaluate.
  void where(String key, dynamic value) {
    if (value == null) {
      throw ArgumentError('The VALUE is required on where() method.');
    }

    if (value is! String &&
        value is! int &&
        value is! double &&
        value is! BigInt &&
        value is! bool) {
      throw ArgumentError('The VALUE must be primitive on where() method.');
    }

    filters[key] = value;
  }

  /// The whereNested method can be used to filter the query by evaluating a
  /// nested filter.
  void whereNested(Map<String, dynamic> nestedFilters) {
    filters = _mapMerge(filters, nestedFilters);
  }

  /// The whereIn method is similar to where, but it accepts multiple values
  /// instead of a single one. The first argument is the name of the column,
  /// and the second argument is an array of values to evaluate.
  void whereIn(String key, List<String> searchArray) {
    filters[key] = searchArray;
  }

  /// The whereInNested method is similar to whereIn, but is used to filter the
  /// query using a nested filter. You can use whereNested or this alias.
  void whereInNested(Map<String, dynamic> nestedFilters) {
    filters = _mapMerge(filters, nestedFilters);
  }

  /// The method orderBy. The arguments are the names of the properties we want
  /// to sort. We can pass as many arguments as we want.
  void orderBy(List<String> fields) {
    sorts = fields;
  }

  /// Set the current page.
  void page(int value) {
    pageValue = value;
  }

  /// Set the limit of records per page.
  void limit(int value) {
    limitValue = value;
  }

  /// We may also need to use parameters that are not provided by
  /// dart_api_query, and that's when the params method comes in to help.
  void params(Map<String, dynamic> payload) {
    this.payload = payload;
  }

  /// We may need to add a clause based on a condition, and we can do so by
  /// using the when method. The first argument is the flag, and the second
  /// argument is the callback with the clause we want.
  void when(dynamic value, void Function(Builder, dynamic) callback) {
    if (value != null && value != false && value != '') {
      callback(this, value);
    }
  }

  Map<String, dynamic> _mapMerge(
    Map<String, dynamic> a,
    Map<String, dynamic>? b,
  ) {
    if (b == null) return a;
    b.forEach((k, v) {
      if (!a.containsKey(k)) {
        a[k] = v;
      } else {
        if (a[k] is Map<String, dynamic>) {
          _mapMerge(a[k] as Map<String, dynamic>, b[k] as Map<String, dynamic>);
        } else {
          a[k] = b[k];
        }
      }
    });

    return a;
  }
}
