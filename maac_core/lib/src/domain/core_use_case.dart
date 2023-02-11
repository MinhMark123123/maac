abstract class UseCase<Result, Param> {
  Result execute({Param? param});
}

abstract class FutureUseCase<Result, Param> {
  Future<Result> execute({Param? param});
}

abstract class StreamUseCase<Result, Param> {
  Stream<Result> execute({Param? param});
}
