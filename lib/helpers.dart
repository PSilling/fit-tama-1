extension ListNullSafety<T> on List<T> {
  T? elementAtOrNull(int index) {
    try {
      return elementAt(index);
    } on RangeError {
      return null;
    }
  }
}

extension NullableListSafety<T> on List<T?> {
  /// Maps elements of list to nullable, null elements after mapping are filtered out
  List<R> compactMap<R>(R? Function(T? element) mapper) {
    var result = <R>[];
    for (final element in this) {
      final mapped = mapper(element);
      if (mapped != null) {
        result.add(mapped);
      }
    }
    return result;
  }
}

extension FunctionalNullable<T> on T? {
  /// Transform value if not null, basically functor map from Haskell
  R? flatMap<R>(R? Function(T value) mapper) {
    final wrapped = this;
    if (wrapped != null) {
      return mapper(wrapped);
    } else {
      return null;
    }
  }
}