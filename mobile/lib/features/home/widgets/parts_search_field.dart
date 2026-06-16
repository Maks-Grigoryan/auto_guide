import 'package:flutter/material.dart';

/// OEM/text search field — submit-triggered only (D-03, T-03-10).
///
/// Submits on keyboard action or the prefix icon tap.
/// Empty submit is a no-op (T-03-10 guard: no empty request).
/// Query is sent verbatim — no client-side stripping (D-03 note).
class PartsSearchField extends StatefulWidget {
  const PartsSearchField({
    super.key,
    required this.onSubmit,
  });

  /// Called with the non-empty, trimmed text. Empty submit is swallowed here.
  final ValueChanged<String> onSubmit;

  @override
  State<PartsSearchField> createState() => _PartsSearchFieldState();
}

class _PartsSearchFieldState extends State<PartsSearchField> {
  final _controller = TextEditingController();

  void _trySubmit() {
    final text = _controller.text;
    if (text.isEmpty) return; // D-03 guard: empty submit no-op
    widget.onSubmit(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _trySubmit(),
        style: const TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
        decoration: InputDecoration(
          hintText: 'Артикул или OEM-номер',
          prefixIcon: GestureDetector(
            onTap: _trySubmit,
            child: const Icon(Icons.search, color: Color(0xFFE0E0E0)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
      ),
    );
  }
}
