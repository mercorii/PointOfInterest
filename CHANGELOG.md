# Changelog (PointOfInterest mod)

## 0.2.5

  * Fixed mod to work with TUG build 0.8.6.
  * Saving Point of Interest markers works again. Not sure if they actually worked in the previous version..
  * Added .editorconfig file. It should make all the IDEs supporting it use correct spacing.

## 0.2.4

 * Point of Interest markers are now saved (and restored) between sessions. Huge thanks go to JohnyCilohokla for helping out with this.
 * Restored markers are also now shown on gui.

## 0.2.3

 * Changed PointOfInterestMain:CalculateDistance to return values in range [-pi,pi). Prior to this the returned value was in a range [-2pi, 2pi].
 * Aforementioned change fixes the bug where PoI icons in compass were jumping/disappearing at certain positions.
 * Added CHANGELOG.md.

## 0.2.2

 * Converted to work with TUG build 0.8.4
 * Added [Praise](https://github.com/mercorii/Praise) styled CREDITS.txt

## 0.2.1

 * Converted to work with TUG build 0.8.3

..

_Changes prior to 0.2.1 are not recorded in this change log_
