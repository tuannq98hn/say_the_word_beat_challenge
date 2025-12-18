import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class BaseRepository {
  Future<Either<Failure, T>> handleError<T>(Function() function) async {
    try {
      final result = await function();
      return Right(result);
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

