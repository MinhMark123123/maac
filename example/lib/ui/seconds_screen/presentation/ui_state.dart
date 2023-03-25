class SecondPageUIState {
  int counter = 0;

  SecondPageUIState({this.counter = 0});

  SecondPageUIState copyWith({int? counter}) {
    return SecondPageUIState(counter: counter ?? this.counter);
  }
}
