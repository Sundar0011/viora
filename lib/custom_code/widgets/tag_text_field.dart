// Automatic FlutterFlow imports
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:async';

class TagTextField extends StatefulWidget {
  const TagTextField({
    super.key,
    this.width,
    this.height,
    required this.apikey,
    required this.jwtToken,
  });

  final double? width;
  final double? height;
  final String apikey;
  final String jwtToken;

  @override
  State<TagTextField> createState() => _TagTextFieldState();
}

class _TagTextFieldState extends State<TagTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounceTimer;
  Timer? _searchTimer;
  Timer? _syncTimer;

  bool _isInternalUpdate = false;
  String _internalText = '';

  @override
  void initState() {
    super.initState();
    _initializeAppState();
    _controller.addListener(_onTextChanged);
    _startSyncTimer();
    _syncFromAppState();
  }

  void _initializeAppState() {
    FFAppState().update(() {
      FFAppState().tagList ??= [];
      FFAppState().tagSuggestions ??= [];
      FFAppState().customText ??= '';
      FFAppState().showMentionList = false;
      FFAppState().cursorPosition ??= 0;
    });
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && !_isInternalUpdate) {
        _syncFromAppState();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _searchTimer?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }

  void _syncFromAppState() {
    final appStateText = FFAppState().customText ?? '';
    final appStateCursorPos = FFAppState().cursorPosition ?? 0;

    if (appStateText != _internalText) {
      _updateInternalText(appStateText, appStateCursorPos);
    }
  }

  void _updateInternalText(String newText, int cursorPos) {
    _internalText = newText;
    final displayText = _buildDisplayText(newText);

    if (displayText != _controller.text) {
      _isInternalUpdate = true;

      // Ensure cursor position is valid
      final validCursorPos =
          cursorPos <= displayText.length ? cursorPos : displayText.length;

      // Method 1: Using TextEditingValue (most reliable)
      _controller.value = TextEditingValue(
        text: displayText,
        selection: TextSelection.collapsed(offset: validCursorPos),
      );

      _isInternalUpdate = false;
      setState(() {});
    }
  }

  String _buildDisplayText(String internalText) {
    final tagList = FFAppState().tagList ?? [];
    String displayText = internalText;

    // Replace user IDs with @username format
    for (var tag in tagList) {
      if (tag is Map<String, dynamic> &&
          tag['id'] != null &&
          tag['name'] != null) {
        final userId = tag['id'] as String;
        final userName = tag['name'] as String;
        final tagDisplay = '@$userName';

        if (displayText.contains(userId)) {
          displayText = displayText.replaceAll(userId, tagDisplay);
        }
      }
    }

    return displayText;
  }

  void _onTextChanged() {
    if (_isInternalUpdate) return;

    final displayText = _controller.text;
    final cursorPosition = _controller.selection.baseOffset;

    // Convert display text back to internal format
    String internalText = displayText;
    final tagList = FFAppState().tagList ?? [];

    for (var tag in tagList) {
      if (tag is Map<String, dynamic> &&
          tag['id'] != null &&
          tag['name'] != null) {
        final tagDisplay = '@${tag['name']}';
        if (internalText.contains(tagDisplay)) {
          internalText = internalText.replaceAll(tagDisplay, tag['id']);
        }
      }
    }

    _internalText = internalText;

    // Update app state with both text and cursor position
    FFAppState().update(() {
      FFAppState().customText = internalText;
      FFAppState().cursorPosition = cursorPosition;
    });

    // Handle @ trigger for new searches
    if (cursorPosition > 0 && displayText[cursorPosition - 1] == '@') {
      _searchUsers('');
      FFAppState().update(() => FFAppState().showMentionList = true);
    }

    // Debounce other operations
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _handleTagCleanup(displayText, cursorPosition);
      }
    });
  }

  void _handleTagCleanup(String displayText, int cursorPosition) {
    // Clean up invalid tags
    final tagList = FFAppState().tagList ?? [];
    final validTags = <Map<String, dynamic>>[];

    for (var tag in tagList) {
      if (tag is Map<String, dynamic> && tag['name'] != null) {
        final tagDisplay = '@${tag['name']}';
        if (_isCompleteTagInText(displayText, tagDisplay)) {
          validTags.add(tag);
        }
      }
    }

    if (validTags.length != tagList.length) {
      FFAppState().update(() => FFAppState().tagList = validTags);
      setState(() {});
    }

    // Handle mention search for ongoing typing
    final activeSearch = _getActiveTagSearch(displayText, cursorPosition);
    if (activeSearch.isNotEmpty) {
      // User is typing after @, search with the term
      _searchTimer?.cancel();
      _searchTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          // Ensure focus is maintained during search
          if (!_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
          _searchUsers(activeSearch);
          FFAppState().update(() => FFAppState().showMentionList = true);
        }
      });
    } else if (cursorPosition > 0 && displayText[cursorPosition - 1] == '@') {
      // Just typed @, show all users
      FFAppState().update(() => FFAppState().showMentionList = true);
    } else {
      // No active search, hide suggestions
      FFAppState().update(() => FFAppState().showMentionList = false);
    }
  }

  bool _isCompleteTagInText(String text, String tagPattern) {
    int index = 0;
    while (index < text.length) {
      final foundIndex = text.indexOf(tagPattern, index);
      if (foundIndex == -1) break;

      final beforeTag = foundIndex > 0 ? text[foundIndex - 1] : ' ';
      final afterTagIndex = foundIndex + tagPattern.length;
      final afterTag = afterTagIndex < text.length ? text[afterTagIndex] : ' ';

      if (RegExp(r'[\s\n]|^').hasMatch(beforeTag) &&
          RegExp(r'[\s\n.,!?;:]|$').hasMatch(afterTag)) {
        return true;
      }

      index = foundIndex + 1;
    }
    return false;
  }

  String _getActiveTagSearch(String text, int cursorPosition) {
    if (cursorPosition <= 0) return '';

    final beforeCursor = text.substring(0, cursorPosition);
    final atIndex = beforeCursor.lastIndexOf('@');

    if (atIndex < 0) return '';
    final afterAt = beforeCursor.substring(atIndex + 1);

    if (!afterAt.contains(' ') && !afterAt.contains('\n')) {
      return afterAt;
    }
    return '';
  }

  Future<void> _searchUsers(String searchTerm) async {
    if (!mounted) return;

    try {
      final response = await http
          .post(
            Uri.parse(
                'https://hlmymmlkgirafodcnkgg.supabase.co/rest/v1/rpc/tag_search'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': widget.apikey,
              'Authorization': 'Bearer ${widget.jwtToken}',
            },
            body: json.encode({'search_name': searchTerm}),
          )
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final dynamic rawData = json.decode(response.body);
        final suggestions = (rawData is List)
            ? rawData.cast<Map<String, dynamic>>()
            : <Map<String, dynamic>>[];

        FFAppState().update(() => FFAppState().tagSuggestions = suggestions);
      }
    } catch (e) {
      if (mounted) {
        FFAppState().update(() => FFAppState().tagSuggestions = []);
      }
    }
  }

  void selectSuggestion(Map<String, dynamic> user) {
    final displayText = _controller.text;
    final cursorPosition = _controller.selection.baseOffset;
    final beforeCursor = displayText.substring(0, cursorPosition);
    final atIndex = beforeCursor.lastIndexOf('@');

    if (atIndex >= 0) {
      final beforeAt = displayText.substring(0, atIndex);
      final afterCursor = displayText.substring(cursorPosition);
      final userName = user['name'] ?? '';
      final userId = user['id'] ?? '';

      final insertedDisplayTag = '@$userName';
      final insertedInternalTag = userId;

      // Build new text
      final newDisplayText = '$beforeAt$insertedDisplayTag$afterCursor';
      final newInternalText = '$beforeAt$insertedInternalTag$afterCursor';

      // Calculate new cursor position (end of the tagged name)
      final newCursorPosition = beforeAt.length + insertedDisplayTag.length;

      // Stop listening to avoid conflicts
      _controller.removeListener(_onTextChanged);
      _isInternalUpdate = true;

      // Update tag list
      final currentTagList =
          List<Map<String, dynamic>>.from(FFAppState().tagList ?? []);
      if (!currentTagList.any((tag) => tag['id'] == userId)) {
        currentTagList.add(user);
      }

      // Update internal text
      _internalText = newInternalText;

      // Update app state with new text, cursor position, and tag list
      FFAppState().update(() {
        FFAppState().tagList = currentTagList;
        FFAppState().customText = newInternalText;
        FFAppState().cursorPosition = newCursorPosition;
        FFAppState().showMentionList = false;
      });

      // SOLUTION: Using TextEditingValue for atomic text and cursor update
      _controller.value = TextEditingValue(
        text: newDisplayText,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );

      _isInternalUpdate = false;

      // IMPORTANT: Maintain focus after selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Ensure focus is maintained
          _focusNode.requestFocus();

          // Double-check cursor position
          if (_controller.selection.baseOffset != newCursorPosition) {
            _controller.selection =
                TextSelection.collapsed(offset: newCursorPosition);
          }
        }
        // Re-add listener
        _controller.addListener(_onTextChanged);
      });

      setState(() {});
    }
  }

  void _handleBackspace() {
    final displayText = _controller.text;
    final cursorPosition = _controller.selection.baseOffset;

    if (cursorPosition <= 0) return;

    // Check if cursor is right after a tag
    final beforeCursor = displayText.substring(0, cursorPosition);
    final tagList = FFAppState().tagList ?? [];

    for (var tag in tagList) {
      if (tag is Map<String, dynamic> && tag['name'] != null) {
        final tagDisplay = '@${tag['name']}';

        if (beforeCursor.endsWith('$tagDisplay ') ||
            beforeCursor.endsWith(tagDisplay)) {
          final tagStart = beforeCursor.lastIndexOf(tagDisplay);
          if (tagStart >= 0) {
            final beforeTag = displayText.substring(0, tagStart);
            final afterCursor = displayText.substring(cursorPosition);
            final newDisplayText = beforeTag + afterCursor;
            final newCursorPosition = beforeTag.length;

            _isInternalUpdate = true;

            // Update internal text
            String newInternalText = _internalText;
            if (tag['id'] != null) {
              newInternalText = newInternalText.replaceAll(tag['id'], '');
            }
            _internalText = newInternalText;

            // Method 1: TextEditingValue
            _controller.value = TextEditingValue(
              text: newDisplayText,
              selection: TextSelection.collapsed(offset: newCursorPosition),
            );

            // Remove tag from list and update app state
            final updatedTagList = List<Map<String, dynamic>>.from(tagList);
            updatedTagList.removeWhere((t) => t['id'] == tag['id']);

            FFAppState().update(() {
              FFAppState().tagList = updatedTagList;
              FFAppState().customText = newInternalText;
              FFAppState().cursorPosition = newCursorPosition;
            });

            _isInternalUpdate = false;
            setState(() {});
            return;
          }
        }
      }
    }
  }

  Widget _buildStyledText(String displayText) {
    if (displayText.isEmpty) {
      return const Text(
        "What's happening in your neighborhood?",
        style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.2),
      );
    }

    final tagList = FFAppState().tagList ?? [];
    if (tagList.isEmpty) {
      return Text(
        displayText,
        style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.2),
      );
    }

    final spans = <TextSpan>[];
    final tagRanges = <MapEntry<int, int>>[];

    // Find all tag positions
    for (var tag in tagList) {
      if (tag is Map<String, dynamic> && tag['name'] != null) {
        final tagDisplay = '@${tag['name']}';
        int startIndex = 0;

        while (startIndex < displayText.length) {
          final index = displayText.indexOf(tagDisplay, startIndex);
          if (index == -1) break;

          final beforeTag = index > 0 ? displayText[index - 1] : ' ';
          final afterIndex = index + tagDisplay.length;
          final afterTag =
              afterIndex < displayText.length ? displayText[afterIndex] : ' ';

          if ((index == 0 || RegExp(r'[\s\n]').hasMatch(beforeTag)) &&
              (afterIndex >= displayText.length ||
                  RegExp(r'[\s\n.,!?;:]').hasMatch(afterTag))) {
            tagRanges.add(MapEntry(index, afterIndex));
          }

          startIndex = index + 1;
        }
      }
    }

    // Sort ranges
    tagRanges.sort((a, b) => a.key.compareTo(b.key));

    int currentIndex = 0;

    for (final range in tagRanges) {
      final start = range.key;
      final end = range.value;

      if (start < currentIndex) continue;

      // Add normal text before tag
      if (currentIndex < start) {
        spans.add(TextSpan(
          text: displayText.substring(currentIndex, start),
          style:
              const TextStyle(color: Colors.black, fontSize: 16, height: 1.2),
        ));
      }

      // Add styled tag text
      spans.add(TextSpan(
        text: displayText.substring(start, end),
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          height: 1.2,
        ),
      ));

      currentIndex = end;
    }

    // Add remaining text
    if (currentIndex < displayText.length) {
      spans.add(TextSpan(
        text: displayText.substring(currentIndex),
        style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.2),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  // Public methods
  String getStoredText() {
    return _internalText;
  }

  void setTextFromStored(String storedText) {
    _updateInternalText(storedText, storedText.length);
  }

  List<Map<String, dynamic>> getAllTags() {
    return List<Map<String, dynamic>>.from(FFAppState().tagList ?? []);
  }

  void clearAllTags() {
    _isInternalUpdate = true;
    _internalText = '';

    // Method 1: TextEditingValue for atomic clear
    _controller.value = const TextEditingValue(
      text: '',
      selection: TextSelection.collapsed(offset: 0),
    );

    FFAppState().update(() {
      FFAppState().tagList = [];
      FFAppState().customText = '';
      FFAppState().cursorPosition = 0;
    });

    _isInternalUpdate = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Always ensure focus when tapping
        _focusNode.requestFocus();
      },
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Styled text display
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: _buildStyledText(_controller.text),
              ),
            ),
            // Invisible input field with improved focus handling
            RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace) {
                  _handleBackspace();
                }
              },
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                cursorColor: Colors.black,
                cursorWidth: 2.0,
                // IMPORTANT: Enable auto focus and prevent focus loss
                autofocus: false,
                enableInteractiveSelection: true,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.2,
                  color: Colors.transparent,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                // Prevent focus loss on text changes
                onTap: () {
                  _focusNode.requestFocus();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
