enum RequestMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE'),
  head('HEAD'),
  options('OPTIONS');

  final String value;

  const RequestMethod(this.value);

  /// Get method name as string (uppercase)
  String get name => value;
}
