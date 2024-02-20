import 'dart:async';

import 'package:http/http.dart' as http;

class JwtHttpClient extends http.BaseClient {
  final String _jwt;

  http.Client? _httpClient;

  JwtHttpClient(this._jwt);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['authorization'] = 'Bearer $_jwt';
    _httpClient ??= http.Client();
    var response = await _httpClient!.send(request);

    return response;
  }

  /// Closes this client and its underlying HTTP client.
  @override
  void close() {
    _httpClient?.close();
    _httpClient = null;
  }
}
