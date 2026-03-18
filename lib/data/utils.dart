String cStringToDartString(Iterable<int> source) {
  List<int> target = [];
  for (int c in source) {
    if (c == 0) {
      break;
    }
    target.add(c);
  }
  return String.fromCharCodes(target);
}
