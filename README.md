# Point Of Interest Mod for [TUG](http://www.nerdkingdom.com/)

**Version 0.1.0**

## Required TUG version

**This version of Point Of Interest mod requires TUG InDev (Steam Beta Channel build) version 0.7.1.**

The mod doesn't work with the latest normal build of TUG (0.6.4), as some of the required functionality is only implemented in the latest InDev build. As soon as TUG InDev build is merged into the normal build, this mod will be available for the normal build as well.

## What it is?

It is a mod that allows players to mark certain locations as Points of Interest, and allows them a way to find those locations easily again on a later point. *Note: This is very early version of the mod.*

It adds an invisible PointOfInterest.lua gameobject that player and other mods can spawn to the world (via this mod). The mod then keeps track of these objects and their location in relation to player.

## How do you use it?

Currently it only has very simple command line UI, that supports /slashcommands. This will be changing in the future.

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

The command line UI is very simplistic and is designed to be replaced with a real graphical UI in the near future.

## What is coming later?

* Way to load and save Points of Interest. Currently all of the data is flushed away when new world is loaded/created.
* Graphical UI that will make it far easier to move between different Points of Interest.

## How can I create my own UI for the mod?

The UI part of the mod is separated from the rest of the mods functionality. This way it's very simple to create new UIs for the mod. The current console UI will become optional when the graphical UI will be implemented. As this is very early version the methods and object names are subject to change in the future.

## Installation

### Where to install

Copy all the files into a Mods file under your TUG installation. If you are using Steam, TUG is probably installed at C:\Program Files (x86)\Steam\Steamapps\common\TUG. Under this folder create a folder called 'Mods', if you already don't have one. Inside the Mods folder, create folder 'PointOfInterest' and copy all of this mods files under it.

Easiest way to do this is to download the mod as zip, by clicking the link on this page, and extract everything under <your TUG folder>\mods\. After this just rename the generated folder as 'PointOfInterest'.

In addition to this, you have to edit the file <your TUG folder>\config\mods.txt and add it the following row below other similar lines:

```
  "Mods/PointOfInterest"
```

So that it looks something like:

```
Mods
{
  "Game/Survival"
  "Game/Creative"
  "Game/Core"
  "Mods/PointOfInterest"
}
```
