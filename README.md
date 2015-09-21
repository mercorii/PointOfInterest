# Point Of Interest Mod for [TUG](http://www.nerdkingdom.com/)

**Version 0.2.5**

## Required TUG version

**This version of Point Of Interest is made for TUG version 0.8.6.**

## Warning - early build!

## What it is?

It is a mod that allows players to mark certain locations as Points of Interest, and allows them a way to find those locations easily again on a later point. *Note: This is very early version of the mod.*

It adds an invisible PointOfInterest.lua gameobject that player and other mods can spawn to the world (via this mod). The mod then keeps track of these objects and their location in relation to player.

## Features

* Full color GUI compass.
* Compass shows N, E, S and W markers.
* Compass also shows custom Point of Interest markers. (Five different marker icons available!)
* Marker names are shown when they are straight ahead, Gramma's recipes style.
* Possibility to add name, description and different icon for created Points of Interests in GUI.
* This will possibly be shown above compass when targeting PoI and when reaching it.
* Some of the mod options can be configured by editing config.txt.

## Known bugs

 * **This is dev build**, and because of that there might be game breaking bugs left.
 * There is no way to limit what PoI markers are shown on compass. Currently everything is shown, which gets messy after couple of markers.
 * Slash commands don't seem to work any longer.
 * Hiding compass by *P* or another specified key no longer works.

## Future improvements

#### Near future

 * Way to list and edit existing Points of Interest.
 * Limit visible markers by their distance. Show only nearest n markers, or markers inside radius of m.
 * Interface for showing and hiding specific markers.
 * Add more marker icons.

#### Later in future

 * Create simple map view based on Points of Interests. Nothing fancy. Possibly something like crude treasure map. Meaning the map has no ground information, only markers for PoIs.
 * Better looking option windows.

## How do you use it?

The mod adds a compass bar to the game. The compass bar shows directions and marked point of interest. You can add new markers by clicking the blue button on the right side of the compass.

~~You can hide the compass with key *P*.~~ (Doesn't work atm)

In addition to the graphical user interface, there's a simple command line UI that supports /slashcommands. This will be changing in the future.

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

## How can I create my own UI for the mod?

The UI part of the mod is intended to be separated from the rest of the mods functionality. This way it's very simple to create new UIs for the mod. As this is very early version the methods and object names are subject to change in the future.

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

CommonLib mod by JohnyCilohokla is no longer required.
