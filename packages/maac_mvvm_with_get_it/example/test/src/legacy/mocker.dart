import 'package:maac_mvvm_with_get_it_example/main.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<ExamplePageViewModel>(),
  MockSpec<ExampleAPageViewModel>(),
  MockSpec<ExampleBPageViewModel>(),
])
class A {}