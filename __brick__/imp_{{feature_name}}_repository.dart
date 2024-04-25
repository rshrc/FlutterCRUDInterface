import 'package:dartz/dartz.dart';
import 'package:{{project_name}}/domain/imp_base_repository.dart';
import 'package:{{project_name}}/domain/{{feature_name}}/entities/{{feature_name}}.dart';

abstract class Imp{{feature_name.pascalCase()}}Repository extends IBaseRepository{
  // Functions other than crud can be implemented here
}