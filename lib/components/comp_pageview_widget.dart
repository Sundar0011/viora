import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_pageview_model.dart';
export 'comp_pageview_model.dart';

class CompPageviewWidget extends StatefulWidget {
  const CompPageviewWidget({
    super.key,
    this.images,
  });

  final dynamic images;

  @override
  State<CompPageviewWidget> createState() => _CompPageviewWidgetState();
}

class _CompPageviewWidgetState extends State<CompPageviewWidget> {
  late CompPageviewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompPageviewModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500.0,
      decoration: BoxDecoration(),
      child: Builder(
        builder: (context) {
          final postImages = widget!.images?.toList() ?? [];

          return Container(
            width: double.infinity,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _model.pageViewController ??= PageController(
                      initialPage: max(0, min(0, postImages.length - 1))),
                  scrollDirection: Axis.horizontal,
                  itemCount: postImages.length,
                  itemBuilder: (context, postImagesIndex) {
                    final postImagesItem = postImages[postImagesIndex];
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
                        child: Image.network(
                          postImagesItem.toString(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                    child: smooth_page_indicator.SmoothPageIndicator(
                      controller: _model.pageViewController ??= PageController(
                          initialPage: max(0, min(0, postImages.length - 1))),
                      count: postImages.length,
                      axisDirection: Axis.horizontal,
                      onDotClicked: (i) async {
                        await _model.pageViewController!.animateToPage(
                          i,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                        safeSetState(() {});
                      },
                      effect: smooth_page_indicator.ExpandingDotsEffect(
                        expansionFactor: 4.0,
                        spacing: 4.0,
                        radius: 8.0,
                        dotWidth: 8.0,
                        dotHeight: 4.0,
                        dotColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        activeDotColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        paintStyle: PaintingStyle.fill,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
