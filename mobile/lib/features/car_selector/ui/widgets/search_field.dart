import 'package:flutter/material.dart';

/// Reusable search [TextField] with 48 dp height, dark fill (#2A2D36),
/// prefix search icon, and a clear button when text is non-empty.
///
/// Used on MakeListPage and ModelListPage (no search on generation — UI-SPEC §Screen 4).
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
  });

  final String hintText;

  /// Called on every keystroke — no debounce (list is in-memory, ≤200 rows).
  final ValueChanged<String> onChanged;

  final TextEditingController? controller;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final newText = _controller.text;
    if (newText != _text) {
      setState(() => _text = newText);
      widget.onChanged(newText);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48, // UI-SPEC §Spacing — search field 48 dp
      child: TextField(
        controller: _controller,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFFE0E0E0),
            size: 20,
          ),
          suffixIcon: _text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFFE0E0E0),
                    size: 20,
                  ),
                  // ≥48 dp tap zone is provided by IconButton default constraints
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF2A2D36),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFF5A623), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
