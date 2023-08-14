import 'package:dart_api_query/src/builder.dart';
import 'package:dart_api_query/src/qs/qs.dart';
import 'package:dart_api_query/src/qs/stringify_options.dart';
import 'package:dart_api_query/src/query_parameters.dart';

/// Parse attributes from Builder into query string
class Parser {
  /// Create a instance of Parser with a builder has parameter
  Parser(this._builder) : _uri = '';

  final Builder _builder;
  String _uri;

  /// Final query string
  String query() {
    reset();
    includes();
    appends();
    fields();
    filters();
    sorts();
    page();
    limit();
    payload();

    return _uri;
  }

  /// Reset query string
  void reset() {
    _uri = '';
  }

  /// Builder has includes
  bool hasIncludes() {
    return _builder.includes.isNotEmpty;
  }

  /// Builder has appends
  bool hasAppends() {
    return _builder.appends.isNotEmpty;
  }

  /// Builder has fields
  bool hasFields() {
    return _builder.fields.isNotEmpty;
  }

  /// Builder has filters
  bool hasFilters() {
    return _builder.filters.isNotEmpty;
  }

  /// Builder has sorts
  bool hasSorts() {
    return _builder.sorts.isNotEmpty;
  }

  /// Builder has page
  bool hasPage() {
    return _builder.pageValue != null;
  }

  /// Builder has limit
  bool hasLimit() {
    return _builder.limitValue != null;
  }

  /// Builder has payload
  bool hasPayload() {
    return _builder.payload != null;
  }

  /// Get query prepend symbol
  String prepend() {
    return _uri == '' ? '?' : '&';
  }

  /// Get a parameter names from model
  QueryParameters parameterNames() {
    return _builder.model.parameterNames();
  }

  /// Parser includes
  void includes() {
    if (!hasIncludes()) {
      return;
    }

    _uri += '${prepend()}${parameterNames().include}=';
    _uri += _builder.includes.join(',');
  }

  /// Parser appends
  void appends() {
    if (!hasAppends()) {
      return;
    }

    _uri += '${prepend()}${parameterNames().append}=';
    _uri += _builder.appends.join(',');
  }

  /// Parser fields
  void fields() {
    if (!hasFields()) {
      return;
    }

    final fields = {parameterNames().fields: _builder.fields};
    _uri += prepend();
    _uri += Qs.stringify(
      fields,
      opts: _builder.model.stringifyOptions().merge(
            StringifyOptions(encode: false),
          ),
    );
  }

  /// Parser filters
  void filters() {
    if (!hasFilters()) {
      return;
    }

    final filters = {parameterNames().filter: _builder.filters};
    _uri += prepend();
    _uri += Qs.stringify(
      filters,
      opts: _builder.model.stringifyOptions().merge(
            StringifyOptions(encode: false),
          ),
    );
  }

  /// Parser sorts
  void sorts() {
    if (!hasSorts()) {
      return;
    }

    _uri += prepend();
    _uri += '${parameterNames().sort}=${_builder.sorts.join(',')}';
  }

  /// Parser page
  void page() {
    if (!hasPage()) {
      return;
    }

    _uri += prepend();
    _uri += '${parameterNames().page}=${_builder.pageValue}';
  }

  /// Parser limit
  void limit() {
    if (!hasLimit()) {
      return;
    }

    _uri += prepend();
    _uri += '${parameterNames().limit}=${_builder.limitValue}';
  }

  /// Parser payload
  void payload() {
    if (!hasPayload()) {
      return;
    }

    _uri += prepend();
    _uri += Qs.stringify(
      _builder.payload,
      opts: _builder.model.stringifyOptions().merge(
            StringifyOptions(encode: false),
          ),
    );
  }
}
