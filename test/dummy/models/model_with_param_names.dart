import 'package:dart_api_query/src/query_parameters.dart';
import 'package:dart_api_query/src/schema.dart';

final class ModelWithParamNames extends Schema {
  ModelWithParamNames([super.attributes]);

  ModelWithParamNames.create(super.resourceObject) : super.create();

  @override
  QueryParameters parameterNames() {
    return QueryParameters(
      include: 'include_custom',
      filter: 'filter_custom',
      sort: 'sort_custom',
      fields: 'fields_custom',
      append: 'append_custom',
      page: 'page_custom',
      limit: 'limit_custom',
    );
  }
}
