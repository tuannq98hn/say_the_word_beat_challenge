import 'package:dartz/dartz.dart';
import '../error/failures.dart';
import '../remote/api_service.dart';
import 'base_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class ExampleRepository extends BaseRepository {
  final ApiService _apiService;

  ExampleRepository(this._apiService);

  Future<Either<Failure, dynamic>> getExample() async {
    return handleError(() => _apiService.getExample());
  }
}

