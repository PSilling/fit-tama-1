
extension NullSafety<T> on List<T> {
  T? elementAtOrNull(int index) {
    try {
      return elementAt(index);
    } on RangeError {
      return null;
    }
  }
}