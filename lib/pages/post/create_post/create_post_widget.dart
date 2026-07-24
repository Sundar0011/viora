import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/app_icon_button.dart';
import '/components/app_network_image.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/post/comp_view_access/comp_view_access_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'create_post_model.dart';
export 'create_post_model.dart';

class CreatePostWidget extends StatefulWidget {
  const CreatePostWidget({
    super.key,
    this.groupId,
  });

  final String? groupId;

  static String routeName = 'CreatePost';
  static String routePath = 'createPost';

  @override
  State<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  late CreatePostModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreatePostModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      FFAppState().customText = '';
      safeSetState(() {});
      FFAppState().richTextContent = null;
      FFAppState().datapresent = false;
      FFAppState().tagList = null;
      FFAppState().customText = '';
      FFAppState().taggedUserId = [];
      FFAppState().contentText = '';
      safeSetState(() {});
    });

    _model.inputTextFieldTextController ??= TextEditingController();
    _model.inputTextFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).white,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).pageBack,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 62.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                10.0, 12.0, 20.0, 12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    FlutterFlowIconButton(
                                      borderRadius: 100.0,
                                      icon: Icon(
                                        Icons.close,
                                        color:
                                            FlutterFlowTheme.of(context).greyD1,
                                      ),
                                      onPressed: () async {
                                        context.safePop();
                                        FFAppState().customText = '';
                                        safeSetState(() {});
                                      },
                                    ),
                                    AppNetworkImage(
                                      url: FFAppState().AsProfilePicture,
                                      width: 40.0,
                                      height: 40.0,
                                      fit: BoxFit.cover,
                                      isAvatar: true,
                                      semanticLabel: 'Your profile photo',
                                    ),
                                    if (widget!.groupId == null ||
                                        widget!.groupId == '')
                                      InkWell(
                                        splashColor:
                                            FlutterFlowTheme.of(context)
                                                .primary
                                                .withAlpha(0x14),
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child: CompViewAccessWidget(
                                                    pageType: '',
                                                    postid: '',
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 6.0, 0.0, 6.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text(
                                                  () {
                                                    if (FFAppState()
                                                            .postControl ==
                                                        3) {
                                                      return 'Nearby';
                                                    } else if (FFAppState()
                                                            .postControl ==
                                                        2) {
                                                      return 'Neighbourhood';
                                                    } else {
                                                      return 'Anyone';
                                                    }
                                                  }(),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .extraBlack,
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.4,
                                                      ),
                                                ),
                                                Icon(
                                                  Icons.arrow_drop_down,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .extraBlack,
                                                  size: 22.0,
                                                ),
                                              ].divide(SizedBox(width: 3.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ].divide(SizedBox(width: 10.0)),
                                ),
                                FFButtonWidget(
                                  onPressed: (FFAppState().datapresent == false)
                                      ? null
                                      : () async {
                                          HapticFeedback.lightImpact();
                                          _model.postRow =
                                              await PostTable().insert({
                                            'user_id': currentUserUid,
                                            'content': getJsonField(
                                              FFAppState().richTextContent,
                                              r'''$''',
                                            ).toString(),
                                            'likes_count': 0,
                                            'comment_count': 0,
                                            'share_count': 0,
                                            'is_edited': false,
                                            'is_deleted': false,
                                            'see_post_access_id':
                                                FFAppState().postControl,
                                            'comment_post_access_id':
                                                FFAppState().commentControl,
                                            'community_id':
                                                FFAppState().communityId,
                                            'tagged_people':
                                                FFAppState().tagList,
                                          });
                                          await actions.insertTagRows(
                                            _model.postRow!.id,
                                            FFAppState().taggedUserId.toList(),
                                          );
                                          {
                                            safeSetState(() => _model
                                                    .isDataUploading_uploadDataValue2 =
                                                true);
                                            var selectedUploadedFiles =
                                                <FFUploadedFile>[];
                                            var selectedMedia =
                                                <SelectedFile>[];
                                            var downloadUrls = <String>[];
                                            try {
                                              selectedUploadedFiles =
                                                  _model.uploadedImage;
                                              selectedMedia =
                                                  selectedFilesFromUploadedFiles(
                                                selectedUploadedFiles,
                                                storageFolderPath:
                                                    _model.postRow?.id,
                                                isMultiData: true,
                                              );
                                              downloadUrls =
                                                  await uploadSupabaseStorageFiles(
                                                bucketName: 'post-images',
                                                selectedFiles: selectedMedia,
                                              );
                                            } finally {
                                              _model.isDataUploading_uploadDataValue2 =
                                                  false;
                                            }
                                            if (selectedUploadedFiles.length ==
                                                    selectedMedia.length &&
                                                downloadUrls.length ==
                                                    selectedMedia.length) {
                                              safeSetState(() {
                                                _model.uploadedLocalFiles_uploadDataValue2 =
                                                    selectedUploadedFiles;
                                                _model.uploadedFileUrls_uploadDataValue2 =
                                                    downloadUrls;
                                              });
                                            } else {
                                              safeSetState(() {});
                                              return;
                                            }
                                          }

                                          _model.kkjk =
                                              await InsertImageUrlsCall.call(
                                            token: currentJwtToken,
                                            pUserid: currentUserUid,
                                            pCommunityid:
                                                FFAppState().communityId,
                                            pPostid: _model.postRow?.id,
                                            imageUrlsList: _model
                                                .uploadedFileUrls_uploadDataValue2,
                                            pMediaType: 'image',
                                          );

                                          await UpdateUserProfileCountsCall
                                              .call(
                                            apiKey: FFDevEnvironmentValues()
                                                .AnonKey,
                                            token: currentJwtToken,
                                            option: 'post',
                                          );

                                          await GenerateTLDRCall.call(
                                            postId: _model.postRow?.id,
                                            text: FFAppState().customText,
                                            token: currentJwtToken,
                                          );

                                          if (widget!.groupId != null &&
                                              widget!.groupId != '') {
                                            await PostTable().update(
                                              data: {
                                                'group_id': widget!.groupId,
                                                'is_group_post': true,
                                              },
                                              matchingRows: (rows) =>
                                                  rows.eqOrNull(
                                                'id',
                                                _model.postRow?.id,
                                              ),
                                            );
                                          }
                                          _model.post11 =
                                              await GetPostCall.call(
                                            anonKey: FFDevEnvironmentValues()
                                                .AnonKey,
                                            token: currentJwtToken,
                                          );

                                          FFAppState().AsPost = getJsonField(
                                            (_model.post11?.jsonBody ?? ''),
                                            r'''$''',
                                          );
                                          safeSetState(() {});
                                          context.safePop();

                                          safeSetState(() {});
                                        },
                                  text: 'Post',
                                  options: FFButtonOptions(
                                    width: 63.0,
                                    height: 32.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.manrope(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(24.0),
                                    disabledColor:
                                        FlutterFlowTheme.of(context).greyL2,
                                    disabledTextColor:
                                        FlutterFlowTheme.of(context).greyL3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (false)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 0.0),
                            child: Container(
                              width: double.infinity,
                              child: TextFormField(
                                controller: _model.inputTextFieldTextController,
                                focusNode: _model.inputTextFieldFocusNode,
                                onChanged: (_) => EasyDebounce.debounce(
                                  '_model.inputTextFieldTextController',
                                  Duration(milliseconds: 2000),
                                  () async {
                                    if (getJsonField(
                                          FFAppState().richTextContent,
                                          r'''$''',
                                        ).toString()?.trim().isNotEmpty ==
                                        false) {
                                      _model.datapresent = false;
                                      safeSetState(() {});
                                    } else {
                                      _model.datapresent = true;
                                      safeSetState(() {});
                                    }
                                  },
                                ),
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .extraBlack,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                  hintText:
                                      'What’s happening in your neighborhood?..',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        color:
                                            FlutterFlowTheme.of(context).greyL4,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context).white,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .extraBlack,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                      lineHeight: 1.4,
                                    ),
                                maxLines: 10,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                validator: _model
                                    .inputTextFieldTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                        if (FFAppState().showMentionList)
                          Container(
                            width: double.infinity,
                            height: 200.0,
                            decoration: BoxDecoration(),
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                final suggestions =
                                    FFAppState().tagSuggestions.toList();

                                return ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    0,
                                    10.0,
                                    0,
                                    10.0,
                                  ),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: suggestions.length,
                                  itemBuilder: (context, suggestionsIndex) {
                                    final suggestionsItem =
                                        suggestions[suggestionsIndex];
                                    return InkWell(
                                      splashColor: FlutterFlowTheme.of(context)
                                          .primary
                                          .withAlpha(0x14),
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        FFAppState().tagList =
                                            functions.appendTagList(
                                                suggestionsItem,
                                                FFAppState().tagList);
                                        FFAppState().customText =
                                            functions.appendCustomText(
                                                suggestionsItem,
                                                FFAppState().customText);
                                        FFAppState().update(() {});
                                        FFAppState().showMentionList = false;
                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20.0, 10.0, 20.0, 10.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              AppNetworkImage(
                                                url: getJsonField(
                                                  suggestionsItem,
                                                  r'''$.profile''',
                                                ).toString(),
                                                width: 32.0,
                                                height: 32.0,
                                                fit: BoxFit.cover,
                                                isAvatar: true,
                                                semanticLabel:
                                                    'Profile photo of ' +
                                                        getJsonField(
                                                                suggestionsItem,
                                                                r'''$.name''')
                                                            .toString(),
                                              ),
                                              Text(
                                                getJsonField(
                                                  suggestionsItem,
                                                  r'''$.name''',
                                                ).toString(),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .extraBlack,
                                                      fontSize: 16.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                            ].divide(SizedBox(width: 20.0)),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        if ((_model.uploadedLocalFiles_uploadDataValue
                                .isNotEmpty) ==
                            true)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 0.0, 20.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                // Removes the attached photo(s) before posting.
                                // Enabled 2026-07-21 (if-false quick win #1) —
                                // without it a user who picks the wrong photo
                                // has no way to drop it.
                                Align(
                                  alignment: AlignmentDirectional(1.0, -1.0),
                                  child: AppIconButton(
                                    icon: Icons.close,
                                    iconSize: 24.0,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    semanticLabel: 'Remove attached photo',
                                    tooltip: 'Remove photo',
                                    onTap: () async {
                                      safeSetState(() {
                                        _model.isDataUploading_uploadDataValue =
                                            false;
                                        _model.uploadedLocalFiles_uploadDataValue =
                                            [];
                                      });

                                      if ((String var1) {
                                        return var1.length != 0;
                                      }(_model
                                          .inputTextFieldTextController.text)) {
                                        _model.datapresent = true;
                                        safeSetState(() {});
                                      } else {
                                        _model.datapresent = false;
                                        safeSetState(() {});
                                      }
                                    },
                                  ),
                                ),
                                if (_model.uploadedImage.length > 1)
                                  Stack(
                                    alignment: AlignmentDirectional(-1.0, 1.0),
                                    children: [
                                      Builder(
                                        builder: (context) {
                                          final uploadedImages =
                                              _model.uploadedImage.toList();

                                          return Container(
                                            width: double.infinity,
                                            height: 300.0,
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 0.0, 0.0, 40.0),
                                                  child: PageView.builder(
                                                    controller: _model
                                                            .pageViewController ??=
                                                        PageController(
                                                            initialPage: max(
                                                                0,
                                                                min(
                                                                    0,
                                                                    uploadedImages
                                                                            .length -
                                                                        1))),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        uploadedImages.length,
                                                    itemBuilder: (context,
                                                        uploadedImagesIndex) {
                                                      final uploadedImagesItem =
                                                          uploadedImages[
                                                              uploadedImagesIndex];
                                                      return Container(
                                                        width: 200.0,
                                                        height: 200.0,
                                                        child: Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child:
                                                                  Image.memory(
                                                                uploadedImagesItem
                                                                        .bytes ??
                                                                    Uint8List
                                                                        .fromList(
                                                                            []),
                                                                width: double
                                                                    .infinity,
                                                                height: double
                                                                    .infinity,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      -1.0,
                                                                      1.0),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        15.0,
                                                                        0.0,
                                                                        0.0,
                                                                        15.0),
                                                                child:
                                                                    AppIconButton(
                                                                  semanticLabel:
                                                                      'Remove this photo',
                                                                  minTapTarget:
                                                                      44.0,
                                                                  enableHaptic:
                                                                      false,
                                                                  onTap:
                                                                      () async {
                                                                    _model.removeAtIndexFromUploadedImage(
                                                                        uploadedImagesIndex);
                                                                    safeSetState(
                                                                        () {});
                                                                    if ((String
                                                                        var1) {
                                                                      return var1
                                                                              .length !=
                                                                          0;
                                                                    }(_model
                                                                        .inputTextFieldTextController
                                                                        .text)) {
                                                                      _model.datapresent =
                                                                          true;
                                                                      safeSetState(
                                                                          () {});
                                                                    } else {
                                                                      _model.datapresent =
                                                                          false;
                                                                      safeSetState(
                                                                          () {});
                                                                    }
                                                                  },
                                                                  iconWidget:
                                                                      ExcludeSemantics(
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100.0),
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/images/Icon.webp',
                                                                        width:
                                                                            24.0,
                                                                        height:
                                                                            24.0,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 1.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 16.0),
                                                    child: smooth_page_indicator
                                                        .SmoothPageIndicator(
                                                      controller: _model
                                                              .pageViewController ??=
                                                          PageController(
                                                              initialPage: max(
                                                                  0,
                                                                  min(
                                                                      0,
                                                                      uploadedImages
                                                                              .length -
                                                                          1))),
                                                      count:
                                                          uploadedImages.length,
                                                      axisDirection:
                                                          Axis.horizontal,
                                                      onDotClicked: (i) async {
                                                        await _model
                                                            .pageViewController!
                                                            .animateToPage(
                                                          i,
                                                          duration: Duration(
                                                              milliseconds:
                                                                  500),
                                                          curve: Curves.ease,
                                                        );
                                                        safeSetState(() {});
                                                      },
                                                      effect:
                                                          smooth_page_indicator
                                                              .SlideEffect(
                                                        spacing: 8.0,
                                                        radius: 8.0,
                                                        dotWidth: 8.0,
                                                        dotHeight: 8.0,
                                                        dotColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .accent1,
                                                        activeDotColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        paintStyle:
                                                            PaintingStyle.fill,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                if (_model.uploadedImage.length == 1)
                                  Stack(
                                    alignment: AlignmentDirectional(-1.0, 1.0),
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.memory(
                                          _model.uploadedImage.firstOrNull
                                                  ?.bytes ??
                                              Uint8List.fromList([]),
                                          width: double.infinity,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 1.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  15.0, 0.0, 0.0, 15.0),
                                          child: AppIconButton(
                                            semanticLabel: 'Remove this photo',
                                            minTapTarget: 44.0,
                                            enableHaptic: false,
                                            onTap: () async {
                                              _model.uploadedImage = [];
                                              safeSetState(() {});
                                              if ((String var1) {
                                                return var1.length != 0;
                                              }(_model
                                                  .inputTextFieldTextController
                                                  .text)) {
                                                _model.datapresent = true;
                                                safeSetState(() {});
                                              } else {
                                                _model.datapresent = false;
                                                safeSetState(() {});
                                              }
                                            },
                                            iconWidget: ExcludeSemantics(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                child: Image.asset(
                                                  'assets/images/Icon.webp',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ].divide(SizedBox(height: 10.0)),
                            ),
                          ),
                        Container(
                          width: double.infinity,
                          height: 500.0,
                          child: custom_widgets.MentionTextFieldWidget(
                            width: double.infinity,
                            height: 500.0,
                            token: currentJwtToken!,
                            apiKey: FFDevEnvironmentValues().AnonKey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if ((_model.uploadedImage.isNotEmpty) == false)
                        AppIconButton(
                          semanticLabel: 'Add photos',
                          minTapTarget: 44.0,
                          enableHaptic: false,
                          onTap: () async {
                            final selectedMedia = await selectMedia(
                              mediaSource: MediaSource.photoGallery,
                              multiImage: true,
                            );
                            if (selectedMedia != null &&
                                selectedMedia.every((m) => validateFileFormat(
                                    m.storagePath, context))) {
                              safeSetState(() => _model
                                  .isDataUploading_uploadDataValue = true);
                              var selectedUploadedFiles = <FFUploadedFile>[];

                              try {
                                selectedUploadedFiles = selectedMedia
                                    .map((m) => FFUploadedFile(
                                          name: m.storagePath.split('/').last,
                                          bytes: m.bytes,
                                          height: m.dimensions?.height,
                                          width: m.dimensions?.width,
                                          blurHash: m.blurHash,
                                          originalFilename: m.originalFilename,
                                        ))
                                    .toList();
                              } finally {
                                _model.isDataUploading_uploadDataValue = false;
                              }
                              if (selectedUploadedFiles.length ==
                                  selectedMedia.length) {
                                safeSetState(() {
                                  _model.uploadedLocalFiles_uploadDataValue =
                                      selectedUploadedFiles;
                                });
                              } else {
                                safeSetState(() {});
                                return;
                              }
                            }

                            if ((_model.uploadedLocalFiles_uploadDataValue
                                    .isNotEmpty) ==
                                true) {
                              _model.uploadedImage = _model
                                  .uploadedLocalFiles_uploadDataValue
                                  .toList()
                                  .cast<FFUploadedFile>();
                              safeSetState(() {});
                            }
                          },
                          iconWidget: ExcludeSemantics(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/add_photo_alternate_(1).png',
                                width: 32.0,
                                height: 32.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      if (false)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/add_2.png',
                            width: 32.0,
                            height: 32.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
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
