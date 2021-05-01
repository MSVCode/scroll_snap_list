## [0.8.0]
- Added shrinkWrap and scrollPhysics param for internal ListView (thanks @Svet-00)
- Added clipBehavior and keyboardDismissBehavior param for internal ListView

## [0.7.0]
- Updated for Flutter 2
- Added null-safety

## [0.6.0]
- Added way to anchor selected item at the start & end of the list
- Bugfix dynamic item opacity not working if dynamicItemSize is false

## [0.5.1]
- Updated readme

## [0.5.0]
- Added dynamic item opacity (thanks @granoeste)

## [0.4.1]
- Added way to pass key to child ListView of ScrollSnapList
- Added demo on how to use `PageStorageKey` with ScrollSnapList to preserve scroll location

## [0.4.0]
- Added dynamic item size feature

## [0.3.1]
- Fixed `animateTo` incorrectly removes user-scroll event

## [0.3.0]
- Added updateOnScroll and initial value (value before first snap) (thanks @hawkinsjb1)
- Added checking to avoid multiple onItemFocus call for the same index
- Updated method to handle isInit (delayed instead of one trigger)

## [0.2.1]
- Updated horizontal_list sample to include simulated data loading
- Added `endOfListTolerance` to determine end-of-list position (which trigger `onReachEnd`)

## [0.2.0]
- Fix bug sometimes scrolling stuck at the end of listview
- Breaking: Changed `buildItemList` parameter to `itemBuilder`

## [0.1.3]
- Updated readme

## [0.1.2]
- Added Horizontal Jumbotron List demo

## [0.1.1]
- Minor update description

## [0.1.0] - First release
- First release
