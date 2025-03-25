import 'package:example/mock/mock_class.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';

part 'example_view_model.g.dart';

@BindableViewModel()
class ExampleViewModel extends ViewModel {
  @Bind()
  late final _count = 0.mtd(this);

  @Bind()
  late final _listPerson = <Person>[].mtd(this);

  @Bind()
  late final _sata = Sata<String>("").mtd(this);

  void incrementCounter() => _count.postValue(_count.data + 1);
}
