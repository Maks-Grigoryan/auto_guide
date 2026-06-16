import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_view.dart';

/// Generic widget that maps a Riverpod [AsyncValue<T>] to the correct UI state:
/// - loading → centered [CircularProgressIndicator] (accent #F5A623)
/// - error   → [ErrorView] with screen-specific heading + retry callback
/// - data    → [dataBuilder] with the resolved [T]
///
/// An optional [emptyCheck] + [emptyWidget] handles the "data loaded but list
/// is empty after filtering" case.
class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.asyncValue,
    required this.errorHeading,
    required this.onRetry,
    required this.dataBuilder,
    this.emptyCheck,
    this.emptyWidget,
  });

  final AsyncValue<T> asyncValue;

  /// Screen-specific heading shown on error, e.g. "Не удалось загрузить марки".
  final String errorHeading;

  /// Called when user taps "Повторить" — must trigger ref.refresh() of the provider.
  final VoidCallback onRetry;

  /// Builds the success UI from the resolved [T].
  final Widget Function(T data) dataBuilder;

  /// If provided, called after data resolves to check whether the result is
  /// "empty" (e.g. filtered list is empty).
  final bool Function(T data)? emptyCheck;

  /// Widget to show when [emptyCheck] returns true.
  final Widget? emptyWidget;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF5A623),
        ),
      ),
      error: (_, __) => ErrorView(
        heading: errorHeading,
        onRetry: onRetry,
      ),
      data: (data) {
        if (emptyCheck != null && emptyCheck!(data) && emptyWidget != null) {
          return emptyWidget!;
        }
        return dataBuilder(data);
      },
    );
  }
}
