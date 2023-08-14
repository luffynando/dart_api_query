import 'package:dart_api_query/src/schema.dart';

final class User extends Schema {
  User(super.resourceObject);

  User.init() : super.init();

  String get firstname => getAttribute<String>('firstname');

  String get lastname => getAttribute<String>('lastname');

  String get fullname => '$firstname $lastname';
}
