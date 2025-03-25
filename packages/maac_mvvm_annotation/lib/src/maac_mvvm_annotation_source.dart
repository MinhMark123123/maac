import 'package:meta/meta_meta.dart';

/// {@template bind}
/// Annotation to mark a field as bindable.
/// {@endtemplate}
///
/// This annotation is applied to fields within a class that is annotated
/// with [BindableViewModel]. It signals that the field should be
/// automatically bound to a corresponding property in the ViewModel.
@Target({TargetKind.field})
class Bind {
  /// {@macro bind}
  /// The const constructor for the [Bind] annotation.
  /// This annotation is applied to fields within a class that is annotated
  /// with [BindableViewModel]. It signals that the field should be
  /// automatically bound to a corresponding property in the ViewModel.
  const Bind();
}

/// {@template bindable_view_model}
/// Annotation to mark a class as a bindable ViewModel.
/// {@endtemplate}
///
/// This annotation is applied to classes that represent ViewModels.
/// It indicates that the class's fields annotated with [Bind] should be
/// automatically bound.
@Target({TargetKind.classType})
class BindableViewModel {
  /// {@macro bindable_view_model}
  /// The const constructor for the [BindableViewModel] annotation.
  /// This annotation is applied to classes that represent ViewModels.
  /// It indicates that the class's fields annotated with [Bind] should be
  /// automatically bound.
  const BindableViewModel();
}
