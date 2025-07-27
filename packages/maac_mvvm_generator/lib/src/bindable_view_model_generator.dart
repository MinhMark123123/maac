import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// Generates extensions for classes annotated with `@BindableViewModel`.
///
/// This generator looks for classes marked with the `@BindableViewModel`
/// annotation and, for each such class, it generates an extension that
/// provides getters for fields annotated with `@Bind`. These getters
/// expose the `StreamData` associated with the bound fields.
class BindableViewModelGenerator extends GeneratorForAnnotation<BindableViewModel> {
  @override
  dynamic generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // Check if the element is a class
    if (element is! ClassElement2) {
      return null;
    }
    // Cast the element to ClassElement2 for easier access to its properties
    final classElement2 = element;
    // Extract fields with the @Bind annotation
    final bindableFields = extractBindableFields(classElement2);
    // Generate code for each bindable field
    final generatedFieldCode = bindableFields.map((field) {
      return generateFieldCode(classElement2, field);
    }).join();
    // Build the extension if there is at least one field
    if (generatedFieldCode.isNotEmpty) {
      return buildExtension(classElement2, generatedFieldCode);
    }
    return null;
  }

  /// Extracts fields with the `@Bind` annotation.
  List<FieldElement2> extractBindableFields(ClassElement2 classElement) {
    final fields = classElement.firstFragment.fields2.map((e) => e.element);
    return fields.where(isBindableField).toList();
  }

  /// Checks if a field is annotated with `@Bind`.
  bool isBindableField(FieldElement2 field) {
    if (field.metadata2.annotations.isEmpty) {
      return false;
    }
    return field.metadata2.annotations.any(
      (e) => e.computeConstantValue()?.toString().contains("Bind") ?? false,
    );
  }

  /// Generates the code for a single bindable field.
  String generateFieldCode(ClassElement2 classElement, FieldElement2 field) {
    // Validate field name (must be private)
    validateFieldName(classElement, field);
    if (field.name3 == null) return "";
    // Derive public field name
    final publicFieldName = field.name3!.substring(1);

    // Get the type of the field
    final fieldType = field.type.getDisplayString();
    final genericType = extractTypeArgument(fieldType);
    // Build the getter
    final getter = buildGetter(genericType, field.name3!, publicFieldName);

    return getter;
  }

  /// Validates that the field name is private.
  void validateFieldName(ClassElement2 classElement, FieldElement2 field) {
    if (field.name3?.startsWith('_') == false) {
      throw InvalidGenerationSourceError(
        '`@Bind` should only be used on private fields (starting with an underscore).',
        element: classElement,
      );
    }
  }

  /// Builds the getter for a bindable field.
  String buildGetter(
    String genericType,
    String fieldName,
    String publicFieldName,
  ) {
    final getterType = 'StreamData<$genericType>';
    return '''
    /// This getter is used to access the stream of data 
    /// associated with the private field $fieldName.
    $getterType get $publicFieldName => $fieldName.streamData;
    ''';
  }

  /// Builds the extension for the class.
  String buildExtension(ClassElement2 classElement, String generatedFieldCode) {
    return '''
      extension \$${classElement.name3} on ${classElement.name3} {
        $generatedFieldCode
      }
    ''';
  }

  /// Extracts the type argument from a generic type string.
  String extractTypeArgument(String input) {
    final match = RegExp(r'<(.+)>$').firstMatch(input);
    return match?.group(1) ?? '';
  }
}
