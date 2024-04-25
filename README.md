# crud_interface

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

### Overview

This Mason brick facilitates the rapid generation of CRUD logic for Flutter applications, specifically designed to interact seamlessly with backends following Django REST Framework (DRF) model viewsets or Rails' standard OpenAPI schemas. By automating the creation of repositories, providers, and implementation repositories, this brick allows developers to quickly scaffold functional interfaces that adhere to the conventions and requirements of these popular frameworks.

### Features

- **Repository Generation**: Automatically generates a repository interface and its implementation, ensuring separation of concerns and adherence to the repository pattern.
- **Provider Generation**: Creates a provider for state management, prepared to interact with the generated repository, facilitating a clean architecture approach.
- **DRF and RoR Compatibility**: Designed to work with JSON APIs that follow Django REST Framework conventions or Rails' Active Record patterns over OpenAPI, making it easy to plug into existing backends.
- **Freezed Integration**: Utilizes the Freezed package to alonside dartz for handling error returns. It does not generate the freezed classes but creates placeholders instead. Might add the freezed class as well in the future. 

### How It Works

The brick generates code structures that are pre-configured to integrate with Django and Rails backends by adhering to their respective patterns for CRUD operations. This includes:

- **Model Serialization**: Handling JSON serialization/deserialization that matches the expected format of DRF and Rails, enhanced by immutable models created using Freezed.
- **HTTP Operations**: Prepared methods for Create, Read, Update, and Delete operations that align with RESTful principles as implemented in DRF and Rails.
- **Error Handling**: Basic error handling setups that can be extended to accommodate specific business logic or user feedback requirements.

### Getting Started

1. **Installation**: Ensure you have Mason installed and configured in your project. See [Mason Documentation](https://github.com/felangel/mason) for installation instructions.

2. **Using the Brick**:
   - Run the following command to generate files for a new feature:
     ```
     mason make crud_interface --feature_name <FeatureName> --project_name <YourProjectName>
     ```
   - Replace `<FeatureName>` and `<YourProjectName>` with appropriate values for your project.

3. **Integration**:
   - Integrate the generated files into your project structure.
   - Ensure your backend API conforms to DRF or RoR standards as expected by the generated files.
   - Customize the generated code to further fit your project needs or specific API behavior.

### Advanced Usage

Below is a template for a custom `EntityProvider` class that you might find useful. This class is designed to enhance the interaction between the UI and the data layer, providing streamlined state management and additional utilities for CRUD operations:

```dart
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dartz/dartz.dart';

enum FetchStatus { initial, loading, loaded, error }

class EntityProvider<T extends Identifiable> extends BaseProvider {
  final IBaseRepository<T> repository;

  List<T> entities = [];
  List<T> cachedEntities = [];
  bool isSearchActive = false;
  Map<String, dynamic> mFilters = {};

  void setFilters(String key, dynamic value) {
    mFilters[key] = value;
    getEntities(filters: mFilters);
  }

  void removeFilter(String key) {
    mFilters.remove(key);
    getEntities(filters: mFilters);
  }

  FetchStatus fetchStatus = FetchStatus.initial;

  EntityProvider(this.repository);

  Future<void> createEntity(BuildContext context, Map<String, dynamic> data,
      {String successMessage = "Creation successful",
      String errorMessage = "Creation failed",
      UploadManager? uploadManager}) async {
    final result = await repository.create(data);

    result.fold((l) {
      logger.e("Error: $l");
      NotificationMessage.showError(context, message: errorMessage);
    }, (entity) {
      NotificationMessage.showSuccess(context, message: successMessage);

      entities.insert(0, entity);

      if (uploadManager != null) {
        uploadManager.clearCache();
      }

      notifyListeners();

      // Navigate to detail or do something else
      handleNavigationAfterOperation(context, entity);
    });
  }

  Future<void> updateEntity(
      BuildContext context, Map<String, dynamic> data, int id,
      {String successMessage = "Update successful",
      String errorMessage = "Update failed"}) async {
    final result = await repository.update(data, id);

    result.fold((l) {
      logger.e("Error: $l");
      NotificationMessage.showError(context, message: errorMessage);
    }, (entity) {
      NotificationMessage.showSuccess(context, message: successMessage);

      final index = entities.indexWhere((element) => element.id == id);
      entities[index] = entity;
      notifyListeners();

      // Navigate to detail or do something else
      handleNavigationAfterOperation(context, entity);
    });
  }

  int? nextPage;

  Future<void> getEntities({Map<String, dynamic>? filters}) async {
    final searchIntent = filters != null && filters.containsKey('search');

    if (searchIntent && filters['search'].isNotEmpty) {
      isSearchActive = true;
    } else if (searchIntent && filters['search'].isEmpty) {
      isSearchActive = false;
      if (cachedEntities.isNotEmpty) {
        // Restore from cache if available and not a search query
        entities = List<T>.from(cachedEntities);
        notifyListeners();
        return;
      }
    }

    fetchStatus = FetchStatus.loading;
    notifyListeners();

    final result = await repository.getAll(filters: filters);

    result.fold((l) {
      logger.e("Error: $l");
      fetchStatus = FetchStatus.error;
    }, (entities) {
      this.entities = entities.$2;
      nextPage = entities.$1;
      if (!isSearchActive) {
        cachedEntities = List<T>.from(entities.$2);
      }
      fetchStatus = FetchStatus.loaded;
      notifyListeners();
    });
  }

  Future<void> getNextPage() async {
    if (nextPage == null) {
      return;
    }

    final result = await repository.getAll(filters: {
      if (!isSearchActive) 'page': nextPage,
      ...mFilters,
    });

    result.fold((l) {
      logger.e("Error: $l");
      fetchStatus = FetchStatus.error;
    }, (entities) {
      this.entities.addAll(entities.$2);
      cachedEntities.addAll(entities.$2);
      fetchStatus = FetchStatus.loaded;
      notifyListeners();
    });
  }

  Future<void> deleteEntity(
    BuildContext context,
    int id, {
    String successMessage = "Deletion successful",
    String errorMessage = "Deletion failed",
  }) async {
    final result = await repository.delete(id);

    result.fold((l) {
      logger.e("Error: $l");
      NotificationMessage.showError(context, message: errorMessage);
    }, (success) {
      if (success) {
        entities.removeWhere((element) => element.id! == id);
        context.handleRouting();
        notifyListeners();
        NotificationMessage.showSuccess(context, message: successMessage);
      } else {
        NotificationMessage.showError(context, message: errorMessage);
      }
    });
  }

  Future<Either<String, T>> getById(int id) async {
    return await repository.getById(id);
  }

  void handleNavigationAfterOperation(BuildContext context, T entity) {
    // Define how to handle navigation after an operation like create or update
  }

  void clearSearch() {
    isSearchActive = false;
    entities = List<T>.from(cachedEntities);
    notifyListeners();
  }

  @override
  void clearFormCaches(BuildContext context) {
    // Implementation if needed
  }
}
```

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.