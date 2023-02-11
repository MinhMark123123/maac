class SecondScreenUIState  {

  int counter = 0;


  SecondScreenUIState({ this.counter = 0});

  SecondScreenUIState copyWith({int? counter}) {
    return SecondScreenUIState(counter: counter?? this.counter);
  }
}
