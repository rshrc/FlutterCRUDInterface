import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:opmaint/application/entity_provider.dart';
import 'package:{{project_name}}/domain/{{feature_name}}/entities/{{feature_name}}.dart';
import 'package:{{project_name}}/infrastructure/{{feature_name}}/imp_{{feature_name}}_repository.dart';

@injectable
class {{feature_name.pascalCase()}}Provider extends EntityProvider {
  final Imp{{feature_name.pascalCase()}}Repository repository;

  {{feature_name.pascalCase()}}Provider(this.repository);

  @override
  void handleNavigationAfterOperation(BuildContext context, {{feature_name.pascalCase()}} entity) {
    // Navigation logic here
  }
}
