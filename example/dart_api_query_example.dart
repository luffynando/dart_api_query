import 'package:dart_api_query/dart_api_query.dart';
import 'package:dio/dio.dart';

/// More examples see
/// https://github.com/luffynando/dart_api_query/tree/main/test/unit
void main() async {
  final dio = Dio(BaseOptions());
  ApiQuery.http = dio;
  ApiQuery.baseURL = 'http://localhost';

  // Get first post
  final post = await ApiQuery.of(Post.create).first();
  print(post.id);

  // If user exists print relationship
  if (post.user != null) {
    print(post.user!.fullname);
  }

  // Get all posts
  final posts = await ApiQuery.of(Post.create).get();
  print(posts.length);

  // Create post
  final newPost = Post({'text': 'Cool!'});

  try {
    await ApiQuery.of(Post.create, current: newPost).save();
    print('Post created');
  } catch (error) {
    print('Post not created');
    print(error);
  }
}

final class Post extends Schema {
  // Constructors
  Post([super.attributes]);

  Post.create(super.resourceObject) : super.create();

  // Attributes
  String get text => getAttribute<String>('text');

  set text(String value) => setAttribute<String>('text', value);

  // Relationships
  User? get user => hasOneOrNull('user', User.create);
}

final class User extends Schema {
  // Constructors
  User([super.attributes]);

  User.create(super.objectResource) : super.create();

  // Attributes
  String get firstname => getAttribute<String>('firstname');

  String get lastname => getAttribute<String>('lastname');

  String get fullname => '$firstname $lastname';

  // Dynamically create a api Query with model
  ApiQuery<Post> posts({Post? current}) {
    return load(Post.create, current: current);
  }
}
