/// Query Parameters names of query builder.
class QueryParameters {
  /// Create a QueryParameters instance.
  QueryParameters({
    required this.include,
    required this.filter,
    required this.sort,
    required this.fields,
    required this.append,
    required this.page,
    required this.limit,
  });

  /// Parameter name for include.
  String include;

  /// Parameter name for filter.
  String filter;

  /// Parameter name for sort.
  String sort;

  /// Parameter name for fields.
  String fields;

  /// Parameter name for append.
  String append;

  /// Parameter name for page.
  String page;

  /// Parameter name for limit.
  String limit;
}
