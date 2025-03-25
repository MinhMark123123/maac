import 'package:build/build.dart';
import 'package:maac_mvvm_generator/src/bindable_view_model_generator.dart';
import 'package:source_gen/source_gen.dart';

/// Defines a builder for generating binding code.
///
/// This function creates a [SharedPartBuilder] that utilizes the
/// [BindableViewModelGenerator] to generate binding code for
/// classes annotated with @BindableViewModel.
///
/// It returns a [SharedPartBuilder] which is a builder that generates a part file.
/// This part file will contain the generated code for binding,
/// and can be included in other files using `part 'my_file.binding.dart';`.
Builder bindingBuilder(BuilderOptions options) =>
    //SharedPartBuilder is a builder that combines multiple code generators.
    //It receives a list of generators and a name for the part file.
    SharedPartBuilder(
      [
        BindableViewModelGenerator(),
      ],
      'binding',
    );
