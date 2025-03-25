import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// Generates extensions for classes annotated with `@BindableViewModel`.
///
/// This generator looks for classes marked with the `@BindableViewModel`
/// annotation and, for each such class, it generates an extension that
/// provides getters for fields annotated with `@Bind`. These getters
/// expose the `StreamData` associated with the bound fields.
class BindableViewModelGenerator
    extends GeneratorForAnnotation<BindableViewModel> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // Check if the element is a class
    if (element is! ClassElement) {
      return null;
    }
    // Cast the element to ClassElement for easier access to its properties
    final classElement = element;
    // Extract fields with the @Bind annotation
    final bindableFields = extractBindableFields(classElement);
    // Generate code for each bindable field
    final generatedFieldCode = bindableFields.map((field) {
      return generateFieldCode(classElement, field);
    }).join();
    // Build the extension if there is at least one field
    if (generatedFieldCode.isNotEmpty) {
      return buildExtension(classElement, generatedFieldCode);
    }
    return null;
  }

  /// Extracts fields with the `@Bind` annotation.
  List<FieldElement> extractBindableFields(ClassElement classElement) {
    final fields = classElement.fields;
    return fields.where(isBindableField).toList();
  }

  /// Checks if a field is annotated with `@Bind`.
  bool isBindableField(FieldElement field) {
    if (field.metadata.isEmpty) {
      return false;
    }
    return field.metadata.any(
      (e) => e.computeConstantValue()?.toString().contains("Bind") ?? false,
    );
  }

  /// Generates the code for a single bindable field.
  String generateFieldCode(ClassElement classElement, FieldElement field) {
    // Validate field name (must be private)
    validateFieldName(classElement, field);

    // Derive public field name
    final publicFieldName = field.name.substring(1);

    // Get the type of the field
    final fieldType = field.type.getDisplayString();
    final genericType = extractTypeArgument(fieldType);

    // Build the getter
    final getter = buildGetter(genericType, field.name, publicFieldName);

    return getter;
  }

  /// Validates that the field name is private.
  void validateFieldName(ClassElement classElement, FieldElement field) {
    if (!field.name.startsWith('_')) {
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
  String buildExtension(ClassElement classElement, String generatedFieldCode) {
    return '''
      extension \$${classElement.name} on ${classElement.name} {
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
