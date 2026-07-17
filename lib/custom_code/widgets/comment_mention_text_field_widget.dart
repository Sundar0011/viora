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

import 'package:flutter/services.dart';

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class CommentMentionTextFieldWidget extends StatefulWidget {
  const CommentMentionTextFieldWidget({
    Key? key,
    this.width,
    this.height,
    required this.apiKey,
    required this.token,
    required this.postId,
    required this.communityId,
    required this.userId,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String apiKey;
  final String token;
  final String postId;
  final int communityId;
  final String userId;

  @override
  State<CommentMentionTextFieldWidget> createState() =>
      _CommentMentionTextFieldWidgetState();
}

class _CommentMentionTextFieldWidgetState
    extends State<CommentMentionTextFieldWidget> with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Animation Controllers
  late AnimationController _suggestionController;
  late AnimationController _submitController;
  late Animation<double> _suggestionAnimation;
  late Animation<double> _submitAnimation;

  // Component State - All local state management
  String _currentText = '';
  List<dynamic> _suggestions = [];
  bool _showSuggestions = false;
  Map<String, String> _mentionMap = {}; // name -> userId mapping
  List<String> _taggedUserIds = [];
  bool _isSubmitting = false;
  Timer? _debounceTimer;

  // Rich Text Content - Component managed
  Map<String, dynamic>? _richTextContent;

  // Constants
  static const Color _primaryColor = Color(0xFF264AFF);
  static const Color _backgroundColor = Color(0xFFF7F9FC);
  static const Color _textColor = Color(0xFF333333);
  static const Color _hintColor = Color(0xFF999999);
  static const Color _borderColor = Color(0xFFE8E8E8);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupListeners();
    _initializeFromAppState();
  }

  @override
  void dispose() {
    _suggestionController.dispose();
    _submitController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _setupAnimations() {
    _suggestionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _submitController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _suggestionAnimation = CurvedAnimation(
      parent: _suggestionController,
      curve: Curves.easeOutCubic,
    );

    _submitAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _submitController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupListeners() {
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _initializeFromAppState() {
    // Only initialize once from app state, then use component state
    final initialText = FFAppState().customText;
    if (initialText.isNotEmpty) {
      _textController.text = initialText;
      _currentText = initialText;
    }

    // Load existing mentions if any
    if (FFAppState().richTextContent != null) {
      try {
        final richTextData = FFAppState().richTextContent;
        if (richTextData['mentions'] != null) {
          for (var mention in richTextData['mentions']) {
            final name = mention['name'] as String?;
            final userId = mention['userId'] as String?;
            if (name != null && userId != null) {
              _mentionMap[name] = userId;
              if (!_taggedUserIds.contains(userId)) {
                _taggedUserIds.add(userId);
              }
            }
          }
        }
        _richTextContent = Map<String, dynamic>.from(richTextData);
      } catch (e) {
        debugPrint('Error loading initial mentions: $e');
      }
    }
  }

  void _onTextChanged() {
    final text = _textController.text;
    final cursorPosition = _textController.selection.baseOffset;

    // Update component state only
    setState(() {
      _currentText = text;
    });

    _updateRichTextContent(text);
    _detectMention(text, cursorPosition);
    _cleanupMentions(text);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _showSuggestions) {
      _hideSuggestions();
    }
  }

  void _updateRichTextContent(String text) {
    final mentions = <Map<String, dynamic>>[];

    for (final entry in _mentionMap.entries) {
      final name = entry.key;
      final userId = entry.value;
      final mentionText = '@$name';

      int startIndex = 0;
      while (true) {
        startIndex = text.indexOf(mentionText, startIndex);
        if (startIndex == -1) break;

        if (_isValidMentionPosition(text, startIndex, mentionText)) {
          mentions.add({
            'start': startIndex,
            'end': startIndex + mentionText.length,
            'userId': userId,
            'name': name,
            'text': mentionText,
          });
        }

        startIndex += mentionText.length;
      }
    }

    mentions.sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));

    _richTextContent = {
      'text': text,
      'mentions': mentions,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  bool _isValidMentionPosition(
      String text, int startIndex, String mentionText) {
    // Check character before @
    if (startIndex > 0) {
      final beforeChar = text[startIndex - 1];
      if (!RegExp(r'[\s\n]').hasMatch(beforeChar)) return false;
    }

    // Check character after mention
    final endIndex = startIndex + mentionText.length;
    if (endIndex < text.length) {
      final afterChar = text[endIndex];
      if (!RegExp(r'[\s\n.,:;!?]').hasMatch(afterChar)) return false;
    }

    return true;
  }

  void _detectMention(String text, int cursorPosition) {
    if (cursorPosition <= 0) {
      if (_showSuggestions) _hideSuggestions();
      return;
    }

    final mentionInfo = _findMentionContext(text, cursorPosition);

    if (mentionInfo == null) {
      if (_showSuggestions) _hideSuggestions();
      return;
    }

    final query = mentionInfo['query'] as String;

    if (query.isNotEmpty) {
      _debouncedSearch(query);
    } else {
      if (_showSuggestions) _hideSuggestions();
    }
  }

  Map<String, dynamic>? _findMentionContext(String text, int cursorPosition) {
    int atIndex = -1;
    String query = '';

    // Find @ symbol before cursor
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        atIndex = i;
        query = text.substring(i + 1, cursorPosition);
        break;
      }
      if (RegExp(r'[\s\n]').hasMatch(text[i])) break;
    }

    if (atIndex == -1) return null;

    // Validate @ position
    final isValidPosition =
        atIndex == 0 || RegExp(r'[\s\n]').hasMatch(text[atIndex - 1]);
    if (!isValidPosition || query.contains(RegExp(r'[\s\n]'))) return null;

    return {'atIndex': atIndex, 'query': query};
  }

  void _debouncedSearch(String query) {
    _debounceTimer?.cancel();
    _debounceTimer =
        Timer(const Duration(milliseconds: 300), () => _searchProfiles(query));
  }

  Future<void> _searchProfiles(String query) async {
    if (!mounted) return;

    try {
      final response = await http
          .post(
            Uri.parse(
                'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/search_profiles'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': widget.apiKey,
              'Authorization': 'Bearer ${widget.token}',
            },
            body: jsonEncode({'p_search': query}),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final profiles = jsonDecode(response.body) as List;
        final filteredProfiles = _filterProfiles(profiles);

        setState(() {
          _suggestions = filteredProfiles;
        });

        if (filteredProfiles.isNotEmpty && !_showSuggestions) {
          _showSuggestionsWithAnimation();
        } else if (filteredProfiles.isEmpty && _showSuggestions) {
          _hideSuggestions();
        }
      } else {
        if (_showSuggestions) _hideSuggestions();
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted && _showSuggestions) _hideSuggestions();
    }
  }

  List<dynamic> _filterProfiles(List<dynamic> profiles) {
    return profiles
        .where((profile) {
          final name = profile['name'] as String?;
          return name != null && !_mentionMap.containsKey(name);
        })
        .take(8)
        .toList();
  }

  void _showSuggestionsWithAnimation() {
    setState(() {
      _showSuggestions = true;
    });
    _suggestionController.forward();
  }

  void _hideSuggestions() {
    _suggestionController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showSuggestions = false;
          _suggestions.clear();
        });
      }
    });
  }

  void _cleanupMentions(String text) {
    final validMentions = <String, String>{};
    final validUserIds = <String>[];

    for (final entry in _mentionMap.entries) {
      if (text.contains('@${entry.key}')) {
        validMentions[entry.key] = entry.value;
        validUserIds.add(entry.value);
      }
    }

    if (validMentions.length != _mentionMap.length) {
      setState(() {
        _mentionMap = validMentions;
        _taggedUserIds = validUserIds;
      });
    }
  }

  void _onSuggestionSelected(Map<String, dynamic> user) {
    final text = _textController.text;
    final cursorPosition = _textController.selection.baseOffset;
    final mentionInfo = _findMentionContext(text, cursorPosition);

    if (mentionInfo == null) return;

    final name = user['name']?.toString() ?? '';
    final userId = user['id']?.toString() ?? '';

    if (name.isEmpty || userId.isEmpty) return;

    HapticFeedback.lightImpact();

    final atIndex = mentionInfo['atIndex'] as int;
    final beforeAt = text.substring(0, atIndex);
    final afterCursor = text.substring(cursorPosition);
    final newText = '$beforeAt@$name $afterCursor';
    final newCursorPosition = atIndex + name.length + 2;

    setState(() {
      _mentionMap[name] = userId;
      _currentText = newText;
      if (!_taggedUserIds.contains(userId)) {
        _taggedUserIds.add(userId);
      }
    });

    _hideSuggestions();

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );

    _updateRichTextContent(newText);
  }

  Future<void> _submitComment() async {
    if (_isSubmitting) return;

    final commentText = _currentText.trim();
    if (commentText.isEmpty) {
      _showMessage('Please enter a comment', isError: true);
      return;
    }

    if (widget.userId.isEmpty) {
      _showMessage('User authentication required', isError: true);
      return;
    }

    HapticFeedback.mediumImpact();
    _animateSubmitButton();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final commentData = _buildCommentData(commentText);
      final newCommentId = await _postComment(commentData);

      await _handlePostSubmissionTasks(newCommentId, commentText);

      _syncToAppStateAndClear();
      _showMessage('Comment posted successfully!', isError: false);
    } catch (e) {
      debugPrint('Submit error: $e');
      _showMessage(_getErrorMessage(e), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _animateSubmitButton() {
    _submitController.forward().then((_) {
      _submitController.reverse();
    });
  }

  Map<String, dynamic> _buildCommentData(String commentText) {
    final commentData = {
      'user_id': widget.userId,
      'post_id': widget.postId,
      'community_id': widget.communityId,
      'comment':
          jsonEncode(_richTextContent ?? {'text': commentText, 'mentions': []}),
      'likes_count': 0,
      'replies_count': 0,
    };

    if (FFAppState().showReply == true &&
        FFAppState().CommentId != null &&
        FFAppState().CommentId.isNotEmpty) {
      commentData['parent_comment_id'] = FFAppState().CommentId;
    }

    return commentData;
  }

  Future<String> _postComment(Map<String, dynamic> commentData) async {
    final response = await http
        .post(
          Uri.parse(
              'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/post_comment'),
          headers: {
            'Content-Type': 'application/json',
            'apikey': widget.apiKey,
            'Authorization': 'Bearer ${widget.token}',
            'Prefer': 'return=representation',
          },
          body: jsonEncode(commentData),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 201) {
      throw Exception('Server error: ${response.statusCode}');
    }

    final responseData = jsonDecode(response.body);
    return responseData[0]['id'] as String;
  }

  Future<void> _handlePostSubmissionTasks(
      String commentId, String commentText) async {
    await Future.wait([
      _insertTagRecords(commentId),
      _updateCommentCount(),
      _updateLikesCount(commentId),
      _generateTldr(commentId, commentText), // Added TLDR generation
    ]);
  }

  // New method to generate TLDR
  Future<void> _generateTldr(String commentId, String commentText) async {
    try {
      final response = await http
          .post(
            Uri.parse(
                'https://wgcqstmmkcdjnnpuvspr.supabase.co/functions/v1/generate-tldr'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${widget.token}',
            },
            body: jsonEncode({
              'comment_id': commentId,
              'text': commentText,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('TLDR generation failed: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      } else {
        debugPrint('TLDR generated successfully for comment: $commentId');
      }
    } catch (e) {
      debugPrint('TLDR generation error: $e');
      // Don't throw the error to prevent comment submission from failing
    }
  }

  Future<void> _insertTagRecords(String commentId) async {
    if (_taggedUserIds.isEmpty) return;

    try {
      final tagRecords = _taggedUserIds
          .map((userId) => {
                'post_id': widget.postId,
                'user_id': userId,
              })
          .toList();

      await http
          .post(
            Uri.parse('https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/tag'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': widget.apiKey,
              'Authorization': 'Bearer ${widget.token}',
              'Prefer': 'return=representation',
            },
            body: jsonEncode(tagRecords),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Tag insertion error: $e');
    }
  }

  Future<void> _updateCommentCount() async {
    try {
      await http
          .post(
            Uri.parse(
                'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/count_comment'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': widget.apiKey,
              'Authorization': 'Bearer ${widget.token}',
            },
            body: jsonEncode({'p_postid': widget.postId}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Count comment error: $e');
    }
  }

  Future<void> _updateLikesCount(String commentId) async {
    try {
      await http
          .post(
            Uri.parse(
                'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/count_likes'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': widget.apiKey,
              'Authorization': 'Bearer ${widget.token}',
            },
            body: jsonEncode({
              'p_type': 'comment',
              'p_post_id': widget.postId,
              'p_commentid': commentId,
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Count likes error: $e');
    }
  }

  void _syncToAppStateAndClear() {
    // Only sync to app state when submitting successfully
    FFAppState().update(() {
      FFAppState().customText = '';
      FFAppState().datapresent = false;
      FFAppState().richTextContent = null;
      FFAppState().taggedUserId = [];
      FFAppState().showReply = false;
    });

    // Clear component state
    setState(() {
      _currentText = '';
      _mentionMap.clear();
      _taggedUserIds.clear();
      _richTextContent = null;
    });

    _textController.clear();
    if (_showSuggestions) _hideSuggestions();
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();
    if (errorString.contains('timeout')) {
      return 'Connection timeout. Please try again.';
    }
    return 'Failed to post comment. Please try again.';
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  TextSpan _buildRichTextSpan(String text) {
    if (_mentionMap.isEmpty) {
      return TextSpan(text: text, style: _getBaseTextStyle());
    }

    final children = <TextSpan>[];
    int currentIndex = 0;
    final baseStyle = _getBaseTextStyle();
    final mentionStyle = _getMentionTextStyle();

    while (currentIndex < text.length) {
      final nextAtIndex = text.indexOf('@', currentIndex);

      if (nextAtIndex == -1) {
        if (currentIndex < text.length) {
          children.add(TextSpan(
            text: text.substring(currentIndex),
            style: baseStyle,
          ));
        }
        break;
      }

      if (nextAtIndex > currentIndex) {
        children.add(TextSpan(
          text: text.substring(currentIndex, nextAtIndex),
          style: baseStyle,
        ));
      }

      bool foundMention = false;
      for (final mentionName in _mentionMap.keys) {
        final mentionText = '@$mentionName';
        final endIndex = nextAtIndex + mentionText.length;

        if (endIndex <= text.length &&
            text.substring(nextAtIndex, endIndex) == mentionText) {
          children.add(TextSpan(text: mentionText, style: mentionStyle));
          currentIndex = endIndex;
          foundMention = true;
          break;
        }
      }

      if (!foundMention) {
        children.add(TextSpan(text: '@', style: baseStyle));
        currentIndex = nextAtIndex + 1;
      }
    }

    return TextSpan(children: children);
  }

  TextStyle _getBaseTextStyle() {
    return const TextStyle(
      color: _textColor,
      fontFamily: 'Manrope',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.2,
      letterSpacing: 0.0,
    );
  }

  TextStyle _getMentionTextStyle() {
    return const TextStyle(
      color: _primaryColor,
      fontFamily: 'Manrope',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.0,
    );
  }

  Widget _buildSuggestionItem(Map<String, dynamic> user) {
    final name = user['name']?.toString() ?? 'Unknown User';
    final profilePicture = user['profile_picture']?.toString();
    final hasImage = profilePicture != null && profilePicture.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSuggestionSelected(user),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasImage ? null : Colors.grey.shade300,
                  image: hasImage
                      ? DecorationImage(
                          image: NetworkImage(profilePicture),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasImage
                    ? Icon(
                        Icons.person,
                        color: Colors.grey.shade600,
                        size: 18,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: _textColor,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
  }

  Widget _buildLoadingIndicator() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.3),
            ),
          ),
        ),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Suggestions List
          if (_showSuggestions && _suggestions.isNotEmpty)
            AnimatedBuilder(
              animation: _suggestionAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.95 + (0.05 * _suggestionAnimation.value),
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: _suggestionAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 240),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: _suggestions.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.grey.shade200,
                              indent: 12,
                              endIndent: 12,
                            ),
                            itemBuilder: (context, index) {
                              return _buildSuggestionItem(_suggestions[index]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

          // Main Text Input Field
          Container(
            constraints: const BoxConstraints(
              minHeight: 50,
              maxHeight: 150,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor, width: 1),
              color: _backgroundColor,
            ),
            child: Stack(
              children: [
                // Text Field
                TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  onSubmitted: (_) => _submitComment(),
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: FFAppState().showReply == true
                        ? "Write a reply..."
                        : "Write a comment...",
                    hintStyle: const TextStyle(
                      color: _hintColor,
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      letterSpacing: 0.0,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(
                        left: 16, right: 56, top: 16, bottom: 16),
                  ),
                  maxLines: null,
                  minLines: 1,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(
                    color:
                        _mentionMap.isEmpty ? _textColor : Colors.transparent,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    letterSpacing: 0.0,
                  ),
                  cursorColor: _primaryColor,
                  cursorWidth: 2,
                ),

                // Rich Text Overlay for Mentions
                if (_mentionMap.isNotEmpty && _currentText.isNotEmpty)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16, right: 56, top: 16, bottom: 16),
                        alignment: Alignment.topLeft,
                        child: RichText(
                          text: _buildRichTextSpan(_currentText),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),

                // Submit Button
                Positioned(
                  right: 8,
                  top: 8,
                  child: AnimatedBuilder(
                    animation: _submitAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _submitAnimation.value,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(17),
                            onTap: _isSubmitting ? null : _submitComment,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: (_currentText.trim().isNotEmpty &&
                                        !_isSubmitting)
                                    ? _primaryColor
                                    : Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: _isSubmitting
                                  ? _buildLoadingIndicator()
                                  : const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
