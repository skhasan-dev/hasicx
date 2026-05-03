import 'package:fpdart/fpdart.dart';
import 'package:hasicx/core/index.dart' show Failure;

typedef ResultFuture<T> = Future<Either<Failure, T>>;
