import 'package:flutter/material.dart';

/// Band shown across the top of the map when the search returned nothing.
///
/// The map deliberately stays visible and unobstructed underneath: it is the
/// whole point of the «Карта» tab, and a user looking at an empty result still
/// wants to see the area being searched. An earlier version centred this text
/// over the map, hiding precisely the part worth looking at.
///
/// Icon plus text, never colour alone (ACC-02), on an opaque band so it stays
/// legible over any part of the map tiles.
class MapEmptyNotice extends StatelessWidget {
  const MapEmptyNotice({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2A2D36),
      child: SafeArea(
        bottom: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.search_off,
                  color: Color(0xFFE0E0E0),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFE0E0E0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
