import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:maac_mvvm_generator/builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  group(
    'bindingBuilder',
    () {
      late BuilderOptions options;

      setUp(() {
        // Create a minimal BuilderOptions instance
        options = const BuilderOptions({});
      });

      test('returns a SharedPartBuilder instance', () {
        final builder = bindingBuilder(options);
        expect(builder, isA<SharedPartBuilder>());
      });

      test('does not throw with default options', () {
        expect(() => bindingBuilder(options), returnsNormally);
      });

      test('creates a builder instance with expected part name', () {
        final builder = bindingBuilder(options);
        // We can't access the name directly, but we can verify it doesn't crash
        // and rely on integration tests for the actual output file name
        expect(builder, isNotNull);
        expect(builder.toString(), contains('binding')); // Basic sanity check
      });

      test(
        'bindingBuilder generates expected binding part file',
        () async {
          // Define a fake input file with a class annotated with @BindableViewModel
          const input = '''
          import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
          import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
    
          part 'example_view_model.g.dart';
          class ViewModel {}
          class StreamData<T> {}
          class StreamDataViewModel<T> extends StreamData<T> {}
          extension IntMtd on int {
            StreamDataViewModel<T> mtd<T>(ViewModel vm) => StreamDataViewModel<T>();
          }
          @BindableViewModel()
          class MockViewModel extends ViewModel {
            @Bind()
            late final StreamDataViewModel<int> _count = 0.mtd(this);
          }
    ''';

          // Create the builder
          final builder = bindingBuilder(const BuilderOptions({}));
          final reader =
              await PackageAssetReader.currentIsolate(rootPackage: "a");
          var outputs = <String, Object>{
            'a|test/mock_view_model_test.binding.g.part': decodedMatches(
              allOf(
                contains('extension \$MockViewModel on MockViewModel {'),
                contains('StreamData<int> get count => _count.streamData'),
              ),
            )
          };
          // Simulate the build process
          await testBuilder(
            builder,
            {'a|test/mock_view_model_test.dart': input},
            generateFor: {'a|test/mock_view_model_test.dart'},
            reader: reader,
            outputs: outputs,
          );
        },
      );
    },
  );
}
