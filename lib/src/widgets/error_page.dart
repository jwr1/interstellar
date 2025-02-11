import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/utils.dart';

class FirstPageErrorIndicator extends StatelessWidget {
  const FirstPageErrorIndicator({
    required this.error,
    required this.onTryAgain,
    super.key,
  });

  final dynamic error;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 32,
          horizontal: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l(context).errorPage_firstPage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 48,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: onTryAgain,
                icon: const Icon(Icons.refresh),
                label: Text(
                  l(context).errorPage_firstPage_button,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewPageErrorIndicator extends StatelessWidget {
  const NewPageErrorIndicator({
    required this.error,
    required this.onTryAgain,
    super.key,
  });

  final dynamic error;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTryAgain,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${l(context).errorPage_newPage}\n$error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 4,
                ),
                const Icon(
                  Icons.refresh,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      );
}
