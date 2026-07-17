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

class MentionTextFieldWidget extends StatefulWidget {
  const MentionTextFieldWidget({
    Key? key,
    this.width,
    this.height,
    required this.apiKey,
    required this.token,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String apiKey;
  final String token;

  @override
  State<MentionTextFieldWidget> createState() => _MentionTextFieldWidgetState();
}

class _MentionTextFieldWidgetState extends State<MentionTextFieldWidget> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<dynamic> _suggestions = [];
  bool _showSuggestions = false;
  Map<String, String> _mentionMap = {}; // name -> userId mapping

  @override
  void initState() {
    super.initState();
    _initializeFromAppState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeFromAppState() {
    // Clear the text controller
    _textController.clear();

    // Clear all mention-related data
    _mentionMap.clear();
    _suggestions.clear();
    _showSuggestions = false;

    // Clear and reset all FFAppState values using update method
    FFAppState().update(() {
      FFAppState().customText = '';
      FFAppState().datapresent = false;
      FFAppState().richTextContent = null;
      FFAppState().taggedUserId = []; // Clear the tagged user IDs list
    });

    // Force a rebuild of the widget to reflect cleared state
    setState(() {});
  }

  void _onTextChanged() {
    final text = _textController.text;
    final cursorPosition = _textController.selection.baseOffset;

    // Update FFAppState using the update method to trigger UI refresh
    FFAppState().update(() {
      FFAppState().customText = text;
      // CONTINUOUSLY update datapresent as user types
      FFAppState().datapresent = text.trim().isNotEmpty;
    });

    setState(() {}); // Update local widget state

    _updateRichTextFormat(text);
    _detectMention(text, cursorPosition);
    _cleanupMentions(text);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
      // Removed datapresent update from here - only update on text change
    }
  }

  void _updateRichTextFormat(String text) {
    List<Map<String, dynamic>> mentions = [];

    _mentionMap.forEach((name, userId) {
      String mentionText = '@$name';
      int startIndex = text.indexOf(mentionText);

      if (startIndex != -1) {
        bool isValidMention = true;

        // Check character before @
        if (startIndex > 0) {
          String beforeChar = text[startIndex - 1];
          if (beforeChar != ' ' && beforeChar != '\n') {
            isValidMention = false;
          }
        }

        // Check character after mention
        int endIndex = startIndex + mentionText.length;
        if (endIndex < text.length) {
          String afterChar = text[endIndex];
          if (afterChar != ' ' &&
              afterChar != '\n' &&
              afterChar != '.' &&
              afterChar != ',' &&
              afterChar != '!' &&
              afterChar != '?') {
            isValidMention = false;
          }
        }

        if (isValidMention) {
          mentions.add({
            'start': startIndex,
            'end': endIndex,
            'userId': userId,
            'name': name,
            'text': mentionText,
          });
        }
      }
    });

    Map<String, dynamic> richTextData = {
      'text': text,
      'mentions': mentions,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Update FFAppState using the update method
    FFAppState().update(() {
      FFAppState().richTextContent = richTextData;
    });
  }

  void _detectMention(String text, int cursorPosition) {
    if (cursorPosition <= 0) {
      setState(() {
        _showSuggestions = false;
      });
      return;
    }

    int atIndex = -1;
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        atIndex = i;
        break;
      }
      if (text[i] == ' ' || text[i] == '\n') {
        break;
      }
    }

    if (atIndex == -1) {
      setState(() {
        _showSuggestions = false;
      });
      return;
    }

    bool validPosition =
        atIndex == 0 || text[atIndex - 1] == ' ' || text[atIndex - 1] == '\n';

    if (!validPosition) {
      setState(() {
        _showSuggestions = false;
      });
      return;
    }

    String query = text.substring(atIndex + 1, cursorPosition);

    if (query.contains(' ') || query.contains('\n')) {
      setState(() {
        _showSuggestions = false;
      });
      return;
    }

    if (query.isNotEmpty) {
      _searchProfiles(query);
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  Future<void> _searchProfiles(String query) async {
    const String apiUrl =
        'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/search_profiles';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'apikey': widget.apiKey,
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({'p_search': query}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> profiles = jsonDecode(response.body);
        setState(() {
          _suggestions = profiles;
          _showSuggestions = profiles.isNotEmpty;
        });
      } else {
        setState(() {
          _showSuggestions = false;
        });
      }
    } catch (e) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _cleanupMentions(String text) {
    Map<String, String> validMentions = {};
    List<String> validUserIds =
        []; // Changed from List<dynamic> to List<String>

    _mentionMap.forEach((name, userId) {
      if (text.contains('@$name')) {
        validMentions[name] = userId;
        validUserIds.add(userId); // Now adding String directly
      }
    });

    setState(() {
      _mentionMap = validMentions;
    });

    // Update FFAppState using the update method
    FFAppState().update(() {
      FFAppState().taggedUserId =
          validUserIds; // Changed from tagList to taggedUserId
    });
  }

  void _onSuggestionSelected(Map<String, dynamic> user) {
    final text = _textController.text;
    final cursorPosition = _textController.selection.baseOffset;

    int atIndex = -1;
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        atIndex = i;
        break;
      }
    }

    if (atIndex == -1) return;

    String name = user['name'] ?? '';
    String userId = user['id'] ?? '';

    if (name.isEmpty || userId.isEmpty) return;

    String beforeAt = text.substring(0, atIndex);
    String afterCursor = text.substring(cursorPosition);
    String newText = '$beforeAt@$name $afterCursor';
    int newCursorPosition = atIndex + name.length + 2;

    // Update the mention map FIRST before updating text
    setState(() {
      _mentionMap[name] = userId;
      _showSuggestions = false;
    });

    // Set the text controller - this will trigger _onTextChanged
    _textController.text = newText;
    _textController.selection =
        TextSelection.collapsed(offset: newCursorPosition);

    // Force update rich text format immediately with the new mention
    _updateRichTextFormat(newText);

    // Update FFAppState using the update method
    FFAppState().update(() {
      if (!FFAppState().taggedUserId.contains(userId)) {
        FFAppState()
            .taggedUserId
            .add(userId); // Changed from tagList to taggedUserId
      }
      FFAppState().customText = newText;
      FFAppState().datapresent = newText.trim().isNotEmpty;
    });
  }

  // Create TextSpan with IDENTICAL metrics for perfect cursor alignment
  TextSpan _buildRichTextSpan(String text) {
    List<TextSpan> children = [];
    int currentIndex = 0;

    // IDENTICAL text style for both normal and mention text (same size, same weight)
    TextStyle baseStyle = TextStyle(
      color: Color(0xFF0C0C0C), // Normal text color
      fontFamily: 'Manrope',
      fontSize: 14, // Same size for both
      fontWeight: FontWeight
          .w600, // Same weight for both (slightly bolder for mentions)
      height: 1.3,
      letterSpacing: 0.07,
    );

    // Mention style - ONLY color is different, everything else identical
    TextStyle mentionStyle = TextStyle(
      color: Color(0xFF264AFF), // Blue color for mentions
      fontFamily: 'Manrope',
      fontSize: 14, // SAME size as normal text
      fontWeight: FontWeight.w600, // SAME weight as normal text
      height: 1.3,
      letterSpacing: 0.07,
    );

    while (currentIndex < text.length) {
      int nextAtIndex = text.indexOf('@', currentIndex);

      if (nextAtIndex == -1) {
        children.add(TextSpan(
          text: text.substring(currentIndex),
          style: baseStyle,
        ));
        break;
      }

      if (nextAtIndex > currentIndex) {
        children.add(TextSpan(
          text: text.substring(currentIndex, nextAtIndex),
          style: baseStyle,
        ));
      }

      bool foundMention = false;
      for (String mentionName in _mentionMap.keys) {
        String mentionText = '@$mentionName';
        if (text.substring(nextAtIndex).startsWith(mentionText)) {
          children.add(TextSpan(
            text: mentionText,
            style: mentionStyle, // Only color different
          ));
          currentIndex = nextAtIndex + mentionText.length;
          foundMention = true;
          break;
        }
      }

      if (!foundMention) {
        children.add(TextSpan(
          text: '@',
          style: baseStyle,
        ));
        currentIndex = nextAtIndex + 1;
      }
    }

    return TextSpan(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text Field with Perfect Cursor Alignment
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 120,
              maxHeight: 300,
            ),
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Main TextField
                TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: "What's happening in your neighborhood?..",
                    hintStyle: TextStyle(
                      color: Color(0xFF999999),
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      letterSpacing: 0.07,
                    ),
                    filled: true,
                    fillColor: Color(0xFFFFFFFF),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: null,
                  minLines: 4,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(
                    // Same style as overlay for perfect alignment
                    color: _mentionMap.isEmpty
                        ? Color(0xFF0C0C0C)
                        : Colors.transparent,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600, // Match the overlay
                    height: 1.3,
                    letterSpacing: 0.07,
                  ),
                  cursorColor: Color(0xFF264AFF),
                ),

                // Rich text overlay - only when mentions exist
                if (_mentionMap.isNotEmpty && _textController.text.isNotEmpty)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: RichText(
                          text: _buildRichTextSpan(_textController.text),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Tagged Users Display
          if (_mentionMap.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 4),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF264AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tagged: ${_mentionMap.keys.map((name) => '@$name').join(', ')}',
                style: TextStyle(
                  color: Color(0xFF264AFF),
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Suggestions List
          if (_showSuggestions && _suggestions.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 240),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: _suggestions.length,
                    separatorBuilder: (context, index) => Container(
                      height: 1,
                      color: Color(0xFFF0F0F0),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    itemBuilder: (context, index) {
                      final user = _suggestions[index];

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onSuggestionSelected(user),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: user['profile_picture'] != null &&
                                            user['profile_picture']
                                                .toString()
                                                .isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                user['profile_picture']),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: user['profile_picture'] == null ||
                                            user['profile_picture']
                                                .toString()
                                                .isEmpty
                                        ? Color(0xFFE0E0E0)
                                        : null,
                                  ),
                                  child: user['profile_picture'] == null ||
                                          user['profile_picture']
                                              .toString()
                                              .isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: Color(0xFF666666),
                                          size: 20,
                                        )
                                      : null,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    user['name'] ?? '',
                                    style: TextStyle(
                                      color: Color(0xFF0C0C0C),
                                      fontFamily: 'Manrope',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
