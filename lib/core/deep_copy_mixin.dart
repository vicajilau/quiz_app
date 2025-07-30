/// A mixin that provides the capability to create deep copies of instances.
/// 
/// Classes that use this mixin must implement the `copy()` method, which
/// returns a new instance of the class with the same properties. This
/// ensures that any mutable fields are also deeply copied when necessary.
mixin DeepCopy<T> {
  /// Creates a deep copy of the current instance.
  T copy();
}