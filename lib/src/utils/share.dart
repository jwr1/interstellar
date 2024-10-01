import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<ShareResult> shareUri(Uri uri) async {
  if (Platform.isAndroid || Platform.isIOS) {
    return await Share.shareUri(uri);
  } else {
    return await Share.share(uri.toString());
  }
}

Future<ShareResult> shareFile(Uri uri, String filename) async {
  final response = await http.get(uri);

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(response.bodyBytes);

  final result = await Share.shareXFiles([XFile(file.path)]);

  await file.delete();

  return result;
}

Future<File> downloadFile(Uri uri, String filename) async {
  final response = await http.get(uri);

  final dir = await getDownloadsDirectory();
  if (dir == null) throw Exception('Downloads directory not found');

  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(response.bodyBytes);

  return file;
}
