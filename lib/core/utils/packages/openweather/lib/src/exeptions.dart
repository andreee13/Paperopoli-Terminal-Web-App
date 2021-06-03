class MAXCNTException implements Exception {
  String errMsg() => 'Max cnt Value is 8.';
}

class ValueNotPermittedException implements Exception {
  String errMsg() => 'Given value is not permitted for this field.';
}
