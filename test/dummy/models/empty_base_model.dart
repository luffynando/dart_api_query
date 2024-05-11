import 'package:dart_api_query/src/api_query.dart';
import 'package:dart_api_query/src/schema.dart';
import 'package:dio/dio.dart';

final class EmptyBaseModel extends Schema {
  EmptyBaseModel([super.attributes]);

  EmptyBaseModel.create(super.resourceObject) : super.create();

  static void withBaseURL() {
    baseUrlCustom = 'foo';
  }

  static void withHttp() {
    ApiQuery.http = Dio();
  }

  static void reset() {
    ApiQuery.http = null;
    EmptyBaseModel.baseUrlCustom = null;
  }

  static String? baseUrlCustom;

  @override
  String? baseURL() {
    return EmptyBaseModel.baseUrlCustom;
  }
}
