library scroll_snap_list;

import 'dart:math';

import 'package:flutter/material.dart';

///Anchor location for selected item in the list
enum SelectedItemAnchor { start, middle, end }

///A ListView widget that able to "snap" or focus to an item whenever user scrolls.
///
///Allows unrestricted scroll speed. Snap/focus event done on every `ScrollEndNotification`.
///
///Contains `ScrollNotification` widget, so might be incompatible with other scroll notification.
class ScrollSnapList extends StatefulWidget {
  ///List background
  final Color? background;

  ///Widget builder.
  final Widget Function(BuildContext, int) itemBuilder;

  ///Animation curve
  final Curve curve;

  ///Animation duration
  final Duration duration;

  ///Pixel tolerance to trigger onReachEnd.
  ///Default is itemSize/2
  final double? endOfListTolerance;

  ///Method to manually trigger focus to an item. Call with help of `GlobalKey<ScrollSnapListState>`.
  final void Function(int)? focusToItem;

  ///Container's margin
  final EdgeInsetsGeometry? margin;

  ///Number of item in this list
  final int? itemCount;

  ///Composed of the size of each item + its margin/padding.
  ///Size used is width if `scrollDirection` is `Axis.horizontal`, height if `Axis.vertical`.
  ///
  ///Example:
  ///- Horizontal list
  ///- Card with `width` 100
  ///- Margin is `EdgeInsets.symmetric(horizontal: 5)`
  ///- itemSize is `100+5+5 = 110`
  ///
  ///If [scrollController] is set, it's value will be used.
  final double? itemExtent;

  ///Global key that's used to call `focusToItem` method to manually trigger focus event.
  final Key? key;

  ///Global key that passed to child ListView. Can be used for PageStorageKey
  final Key? listViewKey;

  ///Callback function when list snaps/focuses to an item
  final void Function(int)? onItemFocus;

  ///Callback function when user reach end of list.
  ///
  ///Can be used to load more data from database.
  final Function? onReachEnd;

  ///Container's padding
  final EdgeInsetsGeometry? padding;

  ///Reverse scrollDirection
  final bool reverse;

  ///Calls onItemFocus (if it exists) when ScrollUpdateNotification fires
  final bool snapOnScroll;

  ///An optional initial position which will not snap until after the first drag
  final double? initialIndex;

  ///ListView's scrollDirection
  final Axis scrollDirection;

  ///Allows external controller
  final SnapScrollListController? scrollController;

  ///Scale item's size depending on distance to center
  final bool dynamicItemSize;

  ///Custom equation to determine dynamic item scaling calculation
  ///
  ///Input parameter is distance between item position and center of ScrollSnapList (Negative for left side, positive for right side)
  ///
  ///Output value is scale size (must be >=0, 1 is normal-size)
  ///
  ///Need to set `dynamicItemSize` to `true`
  final double Function(double distance)? dynamicSizeEquation;

  ///Custom Opacity of items off center
  final double? dynamicItemOpacity;

  ///Anchor location for selected item in the list
  final SelectedItemAnchor? selectedItemAnchor;

  ///
  final double? listPadding;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? scrollPhysics;

  ScrollSnapList({
    this.background,
    required this.itemBuilder,
    this.scrollController,
    this.curve = Curves.ease,
    this.duration = const Duration(milliseconds: 500),
    this.endOfListTolerance,
    this.focusToItem,
    this.itemCount,
    this.itemExtent,
    this.key,
    this.listViewKey,
    this.margin,
    required this.onItemFocus,
    this.onReachEnd,
    this.padding,
    this.reverse = false,
    this.snapOnScroll = false,
    this.initialIndex,
    this.scrollDirection = Axis.horizontal,
    this.dynamicItemSize = false,
    this.dynamicSizeEquation,
    this.dynamicItemOpacity,
    this.selectedItemAnchor,
    this.listPadding,
    this.scrollPhysics,
  })  : assert((listPadding == null) != (selectedItemAnchor == null)),
        assert((scrollController == null) != (itemExtent == null)),
        super(key: key);

  @override
  ScrollSnapListState createState() => ScrollSnapListState();
}

class ScrollSnapListState extends State<ScrollSnapList> {
  late final SnapScrollListController scrollController;
  late final double itemExtent;

  /// true if initialIndex exists and first drag hasn't occurred
  bool waitingForFirstDrag = true;
  //to avoid multiple onItemFocus when using updateOnScroll
  int previousIndex = -1;
  //Current scroll-position in pixel
  double currentPixel = 0;

  bool _programmaticallyControlledScrollInProgress = false;

  void initState() {
    super.initState();
    scrollController = widget.scrollController ?? SnapScrollListController(itemExtent: widget.itemExtent!);
    itemExtent = widget.itemExtent ?? scrollController.itemExtent;
    scrollController._attach(this);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.initialIndex != null) {
        //set list's initial position
        focusToInitialPosition();
      } else {
        waitingForFirstDrag = false;
      }
    });

    ///After initial jump, set isInit to false
    Future.delayed(Duration(milliseconds: 10), () {
      if (this.mounted) {
        setState(() {
          waitingForFirstDrag = false;
        });
      }
    });
  }

  ///Calculate scale transformation for dynamic item size
  double calculateScale(int index) {
    //scroll-pixel position for index to be at the center of ScrollSnapList
    double intendedPixel = index * itemExtent;
    double difference = intendedPixel - currentPixel;

    if (widget.dynamicSizeEquation != null) {
      //force to be >= 0
      double scale = widget.dynamicSizeEquation!(difference);
      return scale < 0 ? 0 : scale;
    }

    //default equation
    return 1 - min(difference.abs() / 500, 0.4);
  }

  ///Calculate opacity transformation for dynamic item opacity
  double calculateOpacity(int index) {
    //scroll-pixel position for index to be at the center of ScrollSnapList
    double intendedPixel = index * itemExtent;
    double difference = intendedPixel - currentPixel;

    return (difference == 0) ? 1.0 : widget.dynamicItemOpacity ?? 1.0;
  }

  Widget _buildListItem(BuildContext context, int index) {
    Widget child;
    if (widget.dynamicItemSize) {
      child = Transform.scale(
        scale: calculateScale(index),
        child: widget.itemBuilder(context, index),
      );
    } else {
      child = widget.itemBuilder(context, index);
    }

    if (widget.dynamicItemOpacity != null) {
      child = Opacity(child: child, opacity: calculateOpacity(index));
    }

    return child;
  }

  int _calcCardIndex(double pixel, double itemExtent) => ((pixel - itemExtent / 2) / itemExtent).ceil();

  ///Determine location if initialIndex is set
  void focusToInitialPosition() {
    scrollController.jumpTo((widget.initialIndex! * itemExtent));
  }

  ///Trigger callback on reach end-of-list
  void _onReachEnd() {
    if (widget.onReachEnd != null) widget.onReachEnd!();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      child: LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraint) {
          double _listPadding = 0;

          //determine anchor
          switch (widget.selectedItemAnchor) {
            case null:
              _listPadding = widget.listPadding!;
              break;
            case SelectedItemAnchor.start:
              _listPadding = 0;
              break;
            case SelectedItemAnchor.middle:
              _listPadding =
                  (widget.scrollDirection == Axis.horizontal ? constraint.maxWidth : constraint.maxHeight) / 2 -
                      itemExtent / 2;
              break;
            case SelectedItemAnchor.end:
              _listPadding =
                  (widget.scrollDirection == Axis.horizontal ? constraint.maxWidth : constraint.maxHeight) - itemExtent;
              break;
          }

          return GestureDetector(
            //by catching onTapDown gesture, it's possible to keep animateTo from removing user's scroll listener
            onTapDown: (_) {},
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is ScrollEndNotification) {
                  // don't snap until first drag
                  if (waitingForFirstDrag || _programmaticallyControlledScrollInProgress) {
                    return true;
                  }

                  double tolerance = widget.endOfListTolerance ?? (itemExtent / 2);
                  if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - tolerance) {
                    _onReachEnd();
                  }

                  final index = _calcCardIndex(scrollInfo.metrics.pixels, itemExtent);
                  if (index != previousIndex) {
                    previousIndex = index;

                    if (widget.onItemFocus != null) widget.onItemFocus!(index);

                    if (waitingForFirstDrag || _programmaticallyControlledScrollInProgress) {
                      return true;
                    }

                    if (waitingForFirstDrag == false) {
                      Future.delayed(Duration.zero, () => scrollController.animateToIndex(index));
                    }
                  }
                } else if (scrollInfo is ScrollUpdateNotification) {
                  //save pixel position for scale-effect
                  if (widget.dynamicItemSize || widget.dynamicItemOpacity != null) {
                    setState(() {
                      currentPixel = scrollInfo.metrics.pixels;
                    });
                  }

                  final index = _calcCardIndex(scrollInfo.metrics.pixels, itemExtent);
                  if (index != previousIndex) {
                    previousIndex = index;

                    if (widget.onItemFocus != null) widget.onItemFocus!(index);

                    if (widget.snapOnScroll) {
                      if (waitingForFirstDrag || _programmaticallyControlledScrollInProgress) {
                        return true;
                      }

                      if (waitingForFirstDrag == false) {
                        Future.delayed(Duration.zero, () => scrollController.animateToIndex(index));
                      }
                    }
                  }
                }
                return true;
              },
              child: ListView.builder(
                key: widget.listViewKey,
                controller: widget.scrollController,
                padding: widget.scrollDirection == Axis.horizontal
                    ? EdgeInsets.symmetric(horizontal: _listPadding)
                    : EdgeInsets.symmetric(
                        vertical: _listPadding,
                      ),
                reverse: widget.reverse,
                scrollDirection: widget.scrollDirection,
                itemBuilder: _buildListItem,
                itemCount: widget.itemCount,
                physics: widget.scrollPhysics,
              ),
            ),
          );
        },
      ),
    );
  }
}

class SnapScrollListController extends ScrollController {
  SnapScrollListController({required this.itemExtent});

  ScrollSnapListState? _state;
  bool get isAttached => _state != null;

  void _attach(ScrollSnapListState state) {
    _state = state;
  }

  final double itemExtent;
  Future<void> animateToIndex(int index, {Duration? duration, Curve? curve}) {
    final scrollTarget = itemExtent * index;

    return animateTo(scrollTarget, duration: duration, curve: curve);
  }

  void jumpToIndex(int index) {
    jumpTo(itemExtent * index);
  }

  @override
  Future<void> animateTo(double offset, {Duration? duration, Curve? curve}) async {
    assert(isAttached, 'This controller should be attached to SnapScrollList to perform scroll animations.');

    final d = duration ?? _state!.widget.duration;
    final c = curve ?? _state!.widget.curve;

    _state!._programmaticallyControlledScrollInProgress = true;

    await super.animateTo(offset, duration: d, curve: c);

    _state?._programmaticallyControlledScrollInProgress = false;
  }
}
