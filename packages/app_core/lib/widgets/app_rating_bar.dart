import 'package:flutter/material.dart';

class AppRatingBar extends StatefulWidget {
  const AppRatingBar({
    super.key,
    required this.itemBuilder,
    this.textDirection,
    this.unratedColor,
    this.itemCount = 5,
    this.itemSize = 40.0,
    this.rating = 0.0,
    this.itemSpacing = 0.0,
  });

  final IndexedWidgetBuilder itemBuilder;
  final TextDirection? textDirection;

  final Color? unratedColor;

  final int itemCount;

  final double itemSize;

  final double rating;

  final double itemSpacing;

  @override
  AppRatingBarState createState() => AppRatingBarState();
}

class AppRatingBarState extends State<AppRatingBar> {
  double _ratingFraction = 0;
  int _ratingNumber = 0;

  @override
  void initState() {
    super.initState();
    _ratingNumber = widget.rating.truncate() + 1;
    _ratingFraction = widget.rating - _ratingNumber + 1;
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = widget.textDirection ?? Directionality.of(context);
    _ratingNumber = widget.rating.truncate() + 1;
    _ratingFraction = widget.rating - _ratingNumber + 1;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: textDirection,
        children: _children,
      ),
    );
  }

  List<Widget> get _children {
    return List.generate(
      widget.itemCount,
      _buildItems,
    );
  }

  Widget _buildItems(int index) {
    return Padding(
      padding: EdgeInsets.only(
          right: index < (widget.itemCount - 1) ? widget.itemSpacing : 0),
      child: SizedBox(
        width: widget.itemSize,
        height: widget.itemSize,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              child: index + 1 < _ratingNumber
                  ? widget.itemBuilder(context, index)
                  : ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        widget.unratedColor ?? Theme.of(context).disabledColor,
                        BlendMode.srcIn,
                      ),
                      child: widget.itemBuilder(context, index),
                    ),
            ),
            if (index + 1 == _ratingNumber)
              FittedBox(
                child: ClipRect(
                  clipper: _IndicatorClipper(
                    ratingFraction: _ratingFraction,
                  ),
                  child: widget.itemBuilder(context, index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IndicatorClipper extends CustomClipper<Rect> {
  _IndicatorClipper({
    required this.ratingFraction,
  });
  final double ratingFraction;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      0,
      0,
      size.width * ratingFraction,
      size.height,
    );
  }

  @override
  bool shouldReclip(_IndicatorClipper oldClipper) {
    return ratingFraction != oldClipper.ratingFraction;
  }
}
