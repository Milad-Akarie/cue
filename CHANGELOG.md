## 0.4.0
- *CHORE* Migrate to using UI libs

## 0.3.1
- *FEAT* Added `Position.fromSTWH` constructor for start/top/width/height positioning
- *FIX* `Position._lerpNullable` now properly handles null interpolation (switches at t=0.5 instead of treating null as 0)
- *FIX* `CardAct` border stroke detection now correctly checks `OutlinedBorder.side.style` instead of `preferPaintInterior`
- *FIX* `CueController.driveByFling` now self-cleans stale listeners when animation is driven by other means
- *FIX* Added `super == other` and `super.hashCode` to `CardAct` equality checks
- *FIX* `DelayedSimulation` now properly handles edge cases: delay >= duration, `x()` returns start value during delay, and `isDone` boundary condition corrected

## 0.3.0
- *BREAKING* `CueDragScrubber.axisDirection` replaced with required `scrubForwardDirection` (`CueScrubAxis` enum) for explicit directional control
- *FEAT* `CueScrubAxis.start`/`.end` resolve based on text direction (LTR/RTL); `.left`/`.right`/`.up`/`.down` for absolute physical directions

## 0.2.2
- *FEAT* Added `TweenActor.value` constructor for simpler value-based animation with child widget support
## 0.2.1
- *CHORE* Update readme file
## 0.2.0+1
- *FIX* Path motion auto-rotate angle direction corrected

## 0.2.0
- *BREAKING* `CueDragScrubber.axis` replaced with required `axisDirection` (`AxisDirection` enum) for explicit directional control
- *BREAKING* `CueDragScrubber.distance` now asserts positive values; use `AxisDirection` to change drag direction instead of negative distances

## 0.1.5
- *FEAT* Add `CueFlexibleSpaceBar` - animated FlexibleSpaceBar wrapper with Cue motions
## 0.1.4
- *FIX* debug slider needle jumps on first touch
- *FIX* lerping Matrix with infinit values throws an error in Scretch act 
## 0.1.3
- *CHORE* code clean up + more tests
## 0.1.2+1
- *CHORE* add more visual demos
## 0.1.2
- *FIX* un-aligned CueModalTranstion now follows trigger
- *FEAT* Stretch now takes in a uniform alignment. 
## 0.1.1
- *FIX* Fix in issue with Cue.onScroll
- Meta Updates
## 0.1.0+1
- Meta Updates
## 0.1.0
- Initial release
