import "dart:async";

import "package:astro_tale/App/Model/place/place_suggestion.dart";
import "package:astro_tale/App/views/Auth/Sign_up/services/city_services.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

Future<String?> showPlaceSuggestionSheet({
  required BuildContext context,
  required String title,
  String initialValue = "",
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (_) =>
        _PlaceSuggestionSheet(title: title, initialValue: initialValue),
  );
}

class _PlaceSuggestionSheet extends StatefulWidget {
  final String title;
  final String initialValue;

  const _PlaceSuggestionSheet({
    required this.title,
    required this.initialValue,
  });

  @override
  State<_PlaceSuggestionSheet> createState() => _PlaceSuggestionSheetState();
}

class _PlaceSuggestionSheetState extends State<_PlaceSuggestionSheet> {
  static const Duration _debounceDuration = Duration(milliseconds: 280);

  late final TextEditingController _searchController;
  Timer? _debounce;
  List<PlaceSuggestion> _results = const <PlaceSuggestion>[];
  bool _isLoading = false;
  String _error = "";
  int _searchToken = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialValue);
    final seed = widget.initialValue.trim();
    if (seed.length >= 2) {
      _searchPlaces(seed);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _results = const <PlaceSuggestion>[];
        _isLoading = false;
        _error = "";
      });
      return;
    }
    setState(() {});
    _debounce = Timer(_debounceDuration, () => _searchPlaces(query));
  }

  Future<void> _searchPlaces(String query) async {
    final token = ++_searchToken;
    setState(() {
      _isLoading = true;
      _error = "";
    });

    try {
      final list = await PlaceApiService.searchPlaces(query);
      if (!mounted || token != _searchToken) {
        return;
      }
      final unique = _dedupePlaces(list);
      setState(() {
        _results = unique;
        _isLoading = false;
        _error = "";
      });
    } catch (_) {
      if (!mounted || token != _searchToken) {
        return;
      }
      setState(() {
        _results = const <PlaceSuggestion>[];
        _isLoading = false;
        _error = "Unable to load places right now";
      });
    }
  }

  List<PlaceSuggestion> _dedupePlaces(List<PlaceSuggestion> input) {
    final seen = <String>{};
    final output = <PlaceSuggestion>[];
    for (final place in input) {
      final namePart = place.name.trim().toLowerCase();
      final countryPart = place.country.trim().toLowerCase();
      if (namePart.isEmpty && countryPart.isEmpty) {
        continue;
      }
      final key = "$namePart|$countryPart";
      if (seen.contains(key)) {
        continue;
      }
      seen.add(key);
      output.add(place);
    }
    return output;
  }

  String _formatPlaceLabel(PlaceSuggestion place) {
    final city = place.name.trim();
    if (city.isNotEmpty) {
      return city;
    }
    return place.country.trim();
  }

  void _selectValue(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) {
      return;
    }
    Navigator.of(context).pop(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;
    final sheetBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FBFF);
    final cardBg = isDark ? const Color(0xFF162035) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : const Color(0xFFD4E2F7);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          top: 12,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.76,
          ),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: mutedColor.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.dmSans(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(Icons.close_rounded, color: textColor),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    cursorColor: colors.primary,
                    style: GoogleFonts.dmSans(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: _onQueryChanged,
                    decoration: InputDecoration(
                      hintText: "Search city name",
                      hintStyle: GoogleFonts.dmSans(color: mutedColor),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colors.primary,
                      ),
                      suffixIcon: _searchController.text.trim().isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _onQueryChanged("");
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                color: mutedColor,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildBody(
                  textColor: textColor,
                  mutedColor: mutedColor,
                  borderColor: borderColor,
                  cardBg: cardBg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required Color textColor,
    required Color mutedColor,
    required Color borderColor,
    required Color cardBg,
  }) {
    final query = _searchController.text.trim();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
    }

    if (query.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            "Type at least 2 letters to see place suggestions.",
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(color: mutedColor),
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            _error,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(color: mutedColor),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 14),
      itemCount: _results.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _manualEntryTile(
            query: query,
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            mutedColor: mutedColor,
          );
        }

        final place = _results[index - 1];
        final label = _formatPlaceLabel(place);
        return Material(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _selectValue(label),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: ListTile(
                leading: Icon(Icons.location_on_rounded, color: textColor),
                title: Text(
                  place.name.isEmpty ? label : place.name,
                  style: GoogleFonts.dmSans(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  place.country.isEmpty
                      ? "City result"
                      : "Under: ${place.country}",
                  style: GoogleFonts.dmSans(color: mutedColor),
                ),
                trailing: Icon(Icons.north_west_rounded, color: mutedColor),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _manualEntryTile({
    required String query,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color mutedColor,
  }) {
    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _selectValue(query),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: ListTile(
            leading: Icon(Icons.check_circle_outline_rounded, color: textColor),
            title: Text(
              "Use \"$query\"",
              style: GoogleFonts.dmSans(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              "Select typed place",
              style: GoogleFonts.dmSans(color: mutedColor),
            ),
          ),
        ),
      ),
    );
  }
}
