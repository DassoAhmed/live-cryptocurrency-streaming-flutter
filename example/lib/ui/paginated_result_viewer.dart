import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/ui/text_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Displays a column of Widgets built from a [ably.PaginatedResult.items], and
/// allows users to navigate between others pages of a [ably.PaginatedResult]
/// by going to the next page, and going back to the first page.
// ignore: must_be_immutable
class PaginatedResultViewer<T> extends HookWidget {
  final String title;
  final Widget? subtitle;

  ably.PaginatedResult<T>? firstPaginatedResult;
  final ValueWidgetBuilder<T> builder;
  final Future<ably.PaginatedResult<T>> Function() query;

  PaginatedResultViewer({
    required this.title,
    required this.query,
    required this.builder,
    this.subtitle,
    Key? key,
  }) : super(key: key);

  Future<void> getFirstPaginatedResult(
      ValueNotifier<ably.PaginatedResult<T>?> currentPaginatedResult,
      ValueNotifier<int> pageNumber) async {
    final result = await query();
    firstPaginatedResult = result;
    currentPaginatedResult.value = result;
    pageNumber.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    final pageNumber = useState<int>(1);
    final currentPaginatedResult = useState<ably.PaginatedResult<T>?>(null);
    final items = currentPaginatedResult.value?.items ?? [];

    useEffect(() {
      if (currentPaginatedResult.value == null) {
        return;
      }
      if (pageNumber.value == 1) {
        currentPaginatedResult.value!
            .first()
            .then((result) => currentPaginatedResult.value = result);
      } else if (currentPaginatedResult.value!.hasNext()) {
        currentPaginatedResult.value!.next().then((result) {
          currentPaginatedResult.value = result;
        });
      }
      return;
    }, [pageNumber.value]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => currentPaginatedResult.value = null,
              icon: const Icon(Icons.delete),
            ),
            IconButton(
              onPressed: () =>
                  getFirstPaginatedResult(currentPaginatedResult, pageNumber),
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: subtitle,
          )
        else
          const SizedBox.shrink(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: (items.isEmpty)
              ? [const Text('No messages')]
              : items
                  .map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: builder(context, item, null),
                      ))
                  .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextRow('Page', '#${pageNumber.value}'),
            TextButton(
              onPressed:
                  pageNumber.value != 1 ? () => pageNumber.value = 1 : null,
              child: const Text('Go to first page'),
            ),
            TextButton(
              onPressed: currentPaginatedResult.value?.hasNext() ?? false
                  ? () {
                      pageNumber.value += 1;
                    }
                  : null,
              child: const Text('Next page'),
            ),
          ],
        )
      ],
    );
  }
}
