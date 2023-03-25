dynamic executeCondition(bool condition, dynamic Function() invoker){
  if(!condition){
    return;
  }
  return invoker.call();
}