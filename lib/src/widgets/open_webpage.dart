import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interstellar/src/utils/variables.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void openWebpage(BuildContext context, Uri uri) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Open link'),
      content: Text(uri.toString()),
      actions: <Widget>[
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.tonal(
          onPressed: () {
            Navigator.pop(context);

            Clipboard.setData(
              ClipboardData(text: uri.toString()),
            );
          },
          child: const Text('Copy'),
        ),
        if (isWebViewSupported)
          FilledButton.tonal(
            onPressed: () {
              Navigator.pop(context);

              var controller = WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(uri);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(),
                    body: WebViewWidget(controller: controller),
                  ),
                ),
              );
            },
            child: const Text('Open in WebView'),
          ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);

            launchUrl(uri);
          },
          child: const Text('Open in Browser'),
        ),
      ],
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actionsOverflowButtonSpacing: 8,
      actionsOverflowDirection: VerticalDirection.up,
    ),
  );
}
