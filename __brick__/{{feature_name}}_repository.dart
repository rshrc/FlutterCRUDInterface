// Package imports:
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:{{project_name}}/domain/{{feature_name}}/entities/{{feature_name}}.dart';
import 'package:{{project_name}}/domain/{{feature_name}}/imp_{{feature_name}}_repository.dart';

@LazySingleton(as: Imp{{feature_name.pascalCase()}}Repository)
class {{feature_name.pascalCase()}}Repository extends Imp{{feature_name.pascalCase()}}Repository {
  final APIClient apiClient;

  {{feature_name.pascalCase()}}Repository(this.apiClient);

  @override
  Future<Either<String, (int, List<{{feature_name.pascalCase()}}>)>> getAll(
      {Map<String, dynamic>? filters}) async {
    try {
      final response = await apiClient.get('/{{feature_name}}', query: filters);

      // logger.w("{{feature_name.pascalCase()}} Response : ${response.data}");

      final {{feature_name}}s = (response.data['results'] as List)
          .map((e) => {{feature_name.pascalCase()}}.fromJson(e))
          .toList();

      final count = response.data['count'];

      return Right((count, {{feature_name}}s));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, {{feature_name.pascalCase()}}>> getById(int id) async {
    try {
      final response = await apiClient.get('/{{feature_name}}/$id');

      final {{feature_name}} = {{feature_name.pascalCase()}}.fromJson(response.data);

      return Right({{feature_name}});
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, {{feature_name.pascalCase()}}>> create(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/{{feature_name}}', data: data);

      final {{feature_name}} = {{feature_name.pascalCase()}}.fromJson(response.data);

      return Right({{feature_name}});
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, {{feature_name.pascalCase()}}>> update(
      Map<String, dynamic> data, int id) async {
    try {
      final response = await apiClient.put('/{{feature_name}}/$id', data: data);

      final {{feature_name}} = {{feature_name.pascalCase()}}.fromJson(response.data);

      return Right({{feature_name}});
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> delete(int id) async {
    try {
      final response = await apiClient.delete('/{{feature_name}}/$id');

      return Right(response.ok);
    } catch (e) {
      return Left(e.toString());
    }
  }

 
}
