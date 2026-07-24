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

import 'package:flutter/gestures.dart';
import 'dart:convert';

class ShowContent extends StatefulWidget {
  const ShowContent({
    Key? key,
    this.width,
    this.height,
    required this.richTextContent,
    required this.currentUserId,
    this.tldrContent,
  }) : super(key: key);

  final double? width;
  final double? height;
  final dynamic richTextContent;
  final String currentUserId;
  final String? tldrContent;

  @override
  State<ShowContent> createState() => _ShowContentState();
}

class _ShowContentState extends State<ShowContent> {
  bool _isExpanded = false;
  String _displayText = '';
  List<Map<String, dynamic>> _mentions = [];

  @override
  void initState() {
    super.initState();
    _parseContent();
  }

  // ADD THIS METHOD - This is the key fix for your issue
  @override
  void didUpdateWidget(ShowContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the content has changed and re-parse if necessary
    if (oldWidget.richTextContent != widget.richTextContent ||
        oldWidget.tldrContent != widget.tldrContent) {
      _parseContent();
    }
  }

  void _parseContent() {
    try {
      if (widget.richTextContent == null) return;

      String content = widget.richTextContent.toString();
      _displayText = _extractText(content);
      _mentions = _extractMentions(content);
    } catch (e) {
      _displayText = '';
      _mentions = [];
    }

    setState(() {});
  }

  String _extractText(String content) {
    int textStart = content.indexOf('text: ');
    if (textStart == -1) return '';

    textStart += 6;
    int textEnd = content.indexOf(', mentions:');
    if (textEnd == -1) textEnd = content.length;

    return content.substring(textStart, textEnd).trim();
  }

  List<Map<String, dynamic>> _extractMentions(String content) {
    List<Map<String, dynamic>> mentions = [];

    int startIndex = content.indexOf('mentions: [');
    if (startIndex == -1) return mentions;

    startIndex += 11;
    int endIndex = content.lastIndexOf(']');
    if (endIndex == -1 || endIndex <= startIndex) return mentions;

    String mentionsContent = content.substring(startIndex, endIndex);
    if (mentionsContent.trim().isEmpty) return mentions;

    List<String> mentionStrings = [];
    int braceLevel = 0;
    int currentStart = 0;

    for (int i = 0; i < mentionsContent.length; i++) {
      if (mentionsContent[i] == '{') {
        if (braceLevel == 0) currentStart = i;
        braceLevel++;
      } else if (mentionsContent[i] == '}') {
        braceLevel--;
        if (braceLevel == 0) {
          mentionStrings.add(mentionsContent.substring(currentStart, i + 1));
        }
      }
    }

    for (String mentionStr in mentionStrings) {
      Map<String, dynamic> mention = _parseSingleMention(mentionStr);
      if (mention.isNotEmpty) {
        mentions.add(mention);
      }
    }

    return mentions;
  }

  Map<String, dynamic> _parseSingleMention(String mentionStr) {
    Map<String, dynamic> mention = {};

    try {
      String clean = mentionStr.replaceAll('{', '').replaceAll('}', '');

      RegExp startRegex = RegExp(r'start:\s*(\d+)');
      Match? startMatch = startRegex.firstMatch(clean);
      if (startMatch != null) {
        mention['start'] = int.parse(startMatch.group(1)!);
      }

      RegExp endRegex = RegExp(r'end:\s*(\d+)');
      Match? endMatch = endRegex.firstMatch(clean);
      if (endMatch != null) {
        mention['end'] = int.parse(endMatch.group(1)!);
      }

      int userIdStart = clean.indexOf('userId: ');
      if (userIdStart != -1) {
        userIdStart += 8;
        int userIdEnd = clean.indexOf(',', userIdStart);
        if (userIdEnd == -1) userIdEnd = clean.length;
        mention['userId'] = clean.substring(userIdStart, userIdEnd).trim();
      }

      int nameStart = clean.indexOf('name: ');
      if (nameStart != -1) {
        nameStart += 6;
        int nameEnd = clean.indexOf(', text:');
        if (nameEnd == -1) nameEnd = clean.length;
        mention['name'] = clean.substring(nameStart, nameEnd).trim();
      }

      int textStart = clean.indexOf('text: ');
      if (textStart != -1) {
        textStart += 6;
        mention['text'] = clean.substring(textStart).trim();
      }
    } catch (e) {
      // Handle error silently
    }

    return mention;
  }

  void _onMentionTapped(String userId, String userName) {
    if (userId == widget.currentUserId) {
      context.pushNamed('UserProfile');
    } else {
      context.pushNamed(
        'otherProfile',
        queryParameters: {'userid': userId},
      );
    }
  }

  bool _shouldShowReadMore() {
    return _displayText.length > 150;
  }

  bool _hasKeyTakeaways() {
    return widget.tldrContent != null &&
        widget.tldrContent!.trim().isNotEmpty &&
        widget.tldrContent!.trim().toLowerCase() != 'null';
  }

  List<TextSpan> _buildTextSpans() {
    if (_displayText.isEmpty) return [];

    List<TextSpan> spans = [];
    Set<String> mentionedNames = {};
    Map<String, Map<String, dynamic>> nameToMentionData = {};

    for (var mention in _mentions) {
      String name = mention['name'] ?? '';
      if (name.isNotEmpty) {
        mentionedNames.add(name);
        nameToMentionData[name] = mention;
      }
    }

    TextStyle normalStyle = TextStyle(
      color: FlutterFlowTheme.of(context).primaryText,
      fontFamily: 'Manrope',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.07,
    );

    TextStyle mentionStyle = TextStyle(
      color: FlutterFlowTheme.of(context).primary,
      fontFamily: 'Manrope',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.07,
    );

    int currentIndex = 0;
    String textToProcess = _displayText;

    while (currentIndex < textToProcess.length) {
      bool foundMention = false;

      if (textToProcess[currentIndex] == '@') {
        for (String mentionName in mentionedNames) {
          String fullMention = '@$mentionName';

          if (currentIndex + fullMention.length <= textToProcess.length &&
              textToProcess.substring(
                      currentIndex, currentIndex + fullMention.length) ==
                  fullMention) {
            bool isCompleteMention = true;
            int afterIndex = currentIndex + fullMention.length;
            if (afterIndex < textToProcess.length) {
              String afterChar = textToProcess[afterIndex];
              if (afterChar != ' ' &&
                  afterChar != ',' &&
                  afterChar != '.' &&
                  afterChar != '!' &&
                  afterChar != '?' &&
                  afterChar != '\n') {
                isCompleteMention = false;
              }
            }

            if (isCompleteMention) {
              Map<String, dynamic> mentionData =
                  nameToMentionData[mentionName]!;
              spans.add(TextSpan(
                text: fullMention,
                style: mentionStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _onMentionTapped(
                        mentionData['userId'] ?? '',
                        mentionData['name'] ?? '',
                      ),
              ));
              currentIndex += fullMention.length;
              foundMention = true;
              break;
            }
          }
        }
      }

      if (!foundMention) {
        int nextAtIndex = textToProcess.indexOf('@', currentIndex + 1);
        if (nextAtIndex == -1) nextAtIndex = textToProcess.length;

        String normalText = textToProcess.substring(currentIndex, nextAtIndex);
        if (normalText.isNotEmpty) {
          spans.add(TextSpan(text: normalText, style: normalStyle));
        }
        currentIndex = nextAtIndex;
      }
    }

    return spans;
  }

  Widget _buildKeyTakeawaysSection() {
    if (!_hasKeyTakeaways()) return Container();

    return Container(
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FlutterFlowTheme.of(context).secondaryBackground,
            FlutterFlowTheme.of(context).alternate,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: FlutterFlowTheme.of(context).secondary.withOpacity(0.04),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        FlutterFlowTheme.of(context).secondary,
                        FlutterFlowTheme.of(context).primaryD3,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: FlutterFlowTheme.of(context)
                            .secondary
                            .withOpacity(0.25),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'KEY TAKEAWAYS',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          FlutterFlowTheme.of(context)
                              .secondary
                              .withOpacity(0.4),
                          FlutterFlowTheme.of(context)
                              .secondary
                              .withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Container(
              child: Text(
                widget.tldrContent!,
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: 0.02,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_displayText.isEmpty) {
      return Container();
    }

    bool showReadMore = _shouldShowReadMore();

    return Container(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isExpanded || !showReadMore)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: _buildTextSpans()),
                ),
                if (_isExpanded && showReadMore)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = false;
                            });
                          },
                          child: Text(
                            'Read less',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 16 / 12,
                              letterSpacing: 0.06,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildKeyTakeawaysSection(),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: _buildTextSpans()),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = true;
                          });
                        },
                        child: Text(
                          'Read More',
                          style: TextStyle(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                            letterSpacing: 0.06,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
