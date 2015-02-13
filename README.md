# Point Of Interest Mod for [TUG](http://www.nerdkingdom.com/)

**Version 0.2.0**

## Required TUG version

**This version of Point Of Interest is made for TUG version 0.8.2.**

## Warning - early build!

*Currently the mod doesn't save any of the custom placed markers between sessions.*

**Don't wander off your base unless you have written down your (x,y,z) coordinates from F2 debug window.**

## What it is?

It is a mod that allows players to mark certain locations as Points of Interest, and allows them a way to find those locations easily again on a later point. *Note: This is very early version of the mod.*

It adds an invisible PointOfInterest.lua gameobject that player and other mods can spawn to the world (via this mod). The mod then keeps track of these objects and their location in relation to player.

## Known bugs

* **This is dev build**, and because of that there might be game breaking bugs left.
* Point of Interest markers **are currently not saved between play sessions**. Markers only exist during the current play session.
* Items on the compass jump and disappear from time to time.
* In order to get the mod working, CommonLib_mods mod by Johnycilohokla needs to be installed.

## How do you use it?

The mod adds a compass bar to the game. The compass bar shows directions and marked point of interest.

In addition to this, there's a simple command line UI, that supports /slashcommands. This will be changing in the future.

The /commands are:

```
/CreatePointOfInterest <name> <description> <category>
```
Creates an invisible Point of Interest object at the player's current position. Currently name, description and category can only contain a single word each. This is only a limitation of the current console UI and will change soon.
```
/ListPointsOfInterest
```
Lists all created Point of Interest objects. It shows the objects id and name.
```
/DistanceToPointOfInterest <id>
```
Shows the distance between player's current location and Point of Interest identified by its ID.
```
/DirectionToPointOfInterest <id>
```
Shows the direction of Point of Interest identified by its ID.
```
/RemovePointOfInterest <id>
```
Removes the Point of Interest object matching the ID given as parameter for the command.

## What is coming later?

* Way to load and save Points of Interest. Currently all of the data is flushed away when new world is loaded/created.
* Different icons for different types of PoIs
* Better graphics
* Possibility to name locations

## How can I create my own UI for the mod?

The UI part of the mod is intended to be separated from the rest of the mods functionality. This way it's very simple to create new UIs for the mod. The current console UI will become optional when the graphical UI will be implemented. As this is very early version the methods and object names are subject to change in the future.

## Installation

### Where to install

Copy all the files into a Mods file under your TUG installation. If you are using Steam, TUG is probably installed at C:\Program Files (x86)\Steam\Steamapps\common\TUG. Under this folder create a folder called 'Mods', if you already don't have one. Inside the Mods folder, create folder 'PointOfInterest' and copy all of the files under it.

Easiest way to do this is to download the mod as zip, by clicking the link on this page, and extract everything under <your TUG folder>\mods\. After this just rename the generated folder as 'PointOfInterest'.

In addition to this, you have to edit the file <your TUG folder>\config\mods.txt and add the following row above other similar lines:

```
  "Mods/PointOfInterest"
```

So that it looks something like:

```
Mods
{
  "Mods/PointOfInterest"
  "Game/Survival"
  "Game/Creative"
  "Game/Core"
}
```

### Requirements

If you are using latest version of TUG (v0.8.2), you also need to install *CommonLib_mods* mod by Johnycilohokla. CommonLib_mods adds a functionality missing from TUG (v0.8.2) back to TUG. Without it, PointOfInterest mod will not work.

Installation instructions for CommonLib_mods: http://forum.nerdkingdom.com/viewtopic.php?f=39&t=1937
