library scroll_snap_list;

import 'dart:math';

import 'package:flutter/material.dart';

///Anchor location for selected item in the list
enum SelectedItemAnchor { START, MIDDLE, END }

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

  ///Animation duration in milliseconds (ms)
  final int duration;

  ///Pixel tolerance to trigger onReachEnd.
  ///Default is itemSize/2
  final double? endOfListTolerance;

  ///Focus to an item when user tap on it. Inactive if the list-item have its own onTap detector (use state-key to help focusing instead).
  final bool focusOnItemTap;

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
  final double itemExtent;

  ///Global key that's used to call `focusToItem` method to manually trigger focus event.
  final Key? key;

  ///Global key that passed to child ListView. Can be used for PageStorageKey
  final Key? listViewKey;

  ///Callback function when list snaps/focuses to an item
  final void Function(int) onItemFocus;

  ///Callback function when user reach end of list.
  ///
  ///Can be used to load more data from database.
  final Function? onReachEnd;

  ///Container's padding
  final EdgeInsetsGeometry? padding;

  ///Reverse scrollDirection
  final bool reverse;

  ///Calls onItemFocus (if it exists) when ScrollUpdateNotification fires
  final bool updateOnScroll;

  ///An optional initial position which will not snap until after the first drag
  final double? initialIndex;

  ///ListView's scrollDirection
  final Axis scrollDirection;

  ///Allows external controller
  final SnapScrollListController listController;

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
  final SelectedItemAnchor selectedItemAnchor;

  /// {@macro flutter.widgets.scroll_view.shrinkWrap}
  final bool shrinkWrap;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? scrollPhysics;

  ScrollSnapList({
    this.background,
    required this.itemBuilder,
    SnapScrollListController? scrollController,
    this.curve = Curves.ease,
    this.duration = 500,
    this.endOfListTolerance,
    this.focusOnItemTap = true,
    this.focusToItem,
    this.itemCount,
    required this.itemExtent,
    this.key,
    this.listViewKey,
    this.margin,
    required this.onItemFocus,
    this.onReachEnd,
    this.padding,
    this.reverse = false,
    this.updateOnScroll = false,
    this.initialIndex,
    this.scrollDirection = Axis.horizontal,
    this.dynamicItemSize = false,
    this.dynamicSizeEquation,
    this.dynamicItemOpacity,
    this.selectedItemAnchor = SelectedItemAnchor.MIDDLE,
    this.shrinkWrap = false,
    this.scrollPhysics,
  })  : listController = scrollController ?? SnapScrollListController(itemExtent: itemExtent),
        super(key: key);

  @override
  ScrollSnapListState createState() => ScrollSnapListState();
}

class ScrollSnapListState extends State<ScrollSnapList> {
  //true if initialIndex exists and first drag hasn't occurred
  bool isInit = true;
  //to avoid multiple onItemFocus when using updateOnScroll
  int previousIndex = -1;
  //Current scroll-position in pixel
  double currentPixel = 0;

  // this flag is set by controller, so programmatically
  // controlled scroll won't be broken by listener
  bool _programmaticallyControlledScrollInProgress = false;

  void initState() {
    super.initState();
    widget.listController._attach(this);

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.initialIndex != null) {
        //set list's initial position
        focusToInitialPosition();
      } else {
        isInit = false;
      }
    });

    ///After initial jump, set isInit to false
    Future.delayed(Duration(milliseconds: 10), () {
      if (this.mounted) {
        setState(() {
          isInit = false;
        });
      }
    });
  }

  ///Scroll list to an offset
  void _animateScroll(double location) {
    Future.delayed(Duration.zero, () {
      widget.listController.animateTo(
        location,
        duration: new Duration(milliseconds: widget.duration),
        curve: widget.curve,
      );
    });
  }

  ///Calculate scale transformation for dynamic item size
  double calculateScale(int index) {
    //scroll-pixel position for index to be at the center of ScrollSnapList
    double intendedPixel = index * widget.itemExtent;
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
    double intendedPixel = index * widget.itemExtent;
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

    if (widget.focusOnItemTap)
      return GestureDetector(
        onTap: () => focusToItem(index),
        child: child,
      );

    return child;
  }

  ///Calculates target pixel for scroll animation
  ///
  ///Then trigger `onItemFocus`
  double _calcCardLocation({double? pixel, required double itemSize, int? index}) {
    //current pixel: pixel
    //listPadding is not considered as moving pixel by scroll (0.0 is after padding)
    //substracted by itemSize/2 (to center the item)
    //divided by pixels taken by each item
    int cardIndex = index != null ? index : ((pixel! - itemSize / 2) / itemSize).ceil();

    //trigger onItemFocus
    if (cardIndex != previousIndex) {
      previousIndex = cardIndex;
      widget.onItemFocus(cardIndex);
    }

    //target position
    return (cardIndex * itemSize);
  }

  /// Trigger focus to an item inside the list
  /// Will trigger scroll animation to focused item
  void focusToItem(int index) {
    double targetLoc = _calcCardLocation(index: index, itemSize: widget.itemExtent);
    _animateScroll(targetLoc);
  }

  ///Determine location if initialIndex is set
  void focusToInitialPosition() {
    widget.listController.jumpTo((widget.initialIndex! * widget.itemExtent));
  }

  ///Trigger callback on reach end-of-list
  void _onReachEnd() {
    if (widget.onReachEnd != null) widget.onReachEnd!();
  }

  @override
  void dispose() {
    widget.listController.dispose();
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
            case SelectedItemAnchor.START:
              _listPadding = 0;
              break;
            case SelectedItemAnchor.MIDDLE:
              _listPadding =
                  (widget.scrollDirection == Axis.horizontal ? constraint.maxWidth : constraint.maxHeight) / 2 -
                      widget.itemExtent / 2;
              break;
            case SelectedItemAnchor.END:
              _listPadding = (widget.scrollDirection == Axis.horizontal ? constraint.maxWidth : constraint.maxHeight) -
                  widget.itemExtent;
              break;
          }

          return GestureDetector(
            //by catching onTapDown gesture, it's possible to keep animateTo from removing user's scroll listener
            onTapDown: (_) {},
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is ScrollEndNotification) {
                  // don't snap until after first drag
                  if (isInit) {
                    return true;
                  }

                  double tolerance = widget.endOfListTolerance ?? (widget.itemExtent / 2);
                  if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - tolerance) {
                    _onReachEnd();
                  }

                  //snap the selection
                  double offset = _calcCardLocation(
                    pixel: scrollInfo.metrics.pixels,
                    itemSize: widget.itemExtent,
                  );

                  //only animate if not yet snapped (tolerance 0.01 pixel)
                  if ((scrollInfo.metrics.pixels - offset).abs() > 0.01) {
                    _animateScroll(offset);
                  }
                } else if (scrollInfo is ScrollUpdateNotification) {
                  //save pixel position for scale-effect
                  if (widget.dynamicItemSize || widget.dynamicItemOpacity != null) {
                    setState(() {
                      currentPixel = scrollInfo.metrics.pixels;
                    });
                  }

                  if (widget.updateOnScroll && !_programmaticallyControlledScrollInProgress) {
                    // don't snap until after first drag
                    if (isInit) {
                      return true;
                    }

                    if (isInit == false) {
                      _calcCardLocation(
                        pixel: scrollInfo.metrics.pixels,
                        itemSize: widget.itemExtent,
                      );
                    }
                  }
                }
                return true;
              },
              child: ListView.builder(
                key: widget.listViewKey,
                controller: widget.listController,
                padding: widget.scrollDirection == Axis.horizontal
                    ? EdgeInsets.symmetric(horizontal: _listPadding)
                    : EdgeInsets.symmetric(
                        vertical: _listPadding,
                      ),
                reverse: widget.reverse,
                scrollDirection: widget.scrollDirection,
                itemBuilder: _buildListItem,
                itemCount: widget.itemCount,
                shrinkWrap: widget.shrinkWrap,
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
  Future<void> animateToIndex(int index, {required Duration duration, required Curve curve}) {
    final scrollTarget = itemExtent * index;

    return animateTo(scrollTarget, duration: duration, curve: curve);
  }

  void jumpToIndex(int index) {
    jumpTo(itemExtent * index);
  }

  @override
  Future<void> animateTo(double offset, {required Duration duration, required Curve curve}) {
    assert(isAttached, 'This controller should be attached to SnapScrollList to perform scroll animations.');
    _state!._programmaticallyControlledScrollInProgress = true;
    Future<void>.delayed(duration, () {
      // something happened, ignore this operation
      if (!isAttached) return;
      _state!._programmaticallyControlledScrollInProgress = false;
    });
    return super.animateTo(offset, duration: duration, curve: curve);
  }
}
