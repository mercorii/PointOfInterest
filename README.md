# Point Of Interest Mod for [TUG](http://www.nerdkingdom.com/)


## Installation

**This is very early version of the mod and is not intended for real use yet.** The mod requires you to edit certain core game files. This will change in the future, but for now, it's recommended that you only edit these files if you know what you are doing.

### Where to install

Copy all the files into a Mods file under your TUG installation. If you are using Steam, TUG is probably installed at C:\Program Files (x86)\Steam\Steamapps\common\TUG. Under this folder create a folder called 'Mods', if you already don't have one. Inside the Mods folder, create folder 'PointOfInterest' and copy all of this mods files under it.

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

In addition to this, you need to edit Survival.lua file at <Your TUG folder>\Core\Scripts\Modes\Survival\Survival.lua. **Don't do this unless you know what you are doing**, as it might break your game. If it does that, installing the game from a fresh will make your game work again, but you might lose any changes you have done.

Add the following lines to the end of Survival.lua or any other GameMode class you want to use the mod in:

```
---------------- PointOfInterest mods code starts here ----------------

include("Scripts/PointOfInterestMain.lua")
include("Scripts/UI/PointOfInterestConsoleUI.lua")

 -- Register /commands
Survival:RegisterSlashCommand("CreatePointOfInterest", "CreatePointOfInterest")
Survival:RegisterSlashCommand("ListPointsOfInterest", "ListPointsOfInterest")
Survival:RegisterSlashCommand("RemovePointOfInterest", "RemovePointOfInterest")
Survival:RegisterSlashCommand("DistanceToPointOfInterest", "DistanceToPointOfInterest")
Survival:RegisterSlashCommand("DirectionToPointOfInterest", "DirectionToPointOfInterest")

-- Create methods for /commands
function Survival:CreatePointOfInterest(args)
  NKPrint("\nCreatePointOfInterest custom slash command was called\n")
  if EternusEngine.PointOfInterestUI then
    EternusEngine.PointOfInterestUI:CreatePointOfInterest(args)
  end
end

function Survival:ListPointsOfInterest(args)
  NKPrint("\nListPointsOfInterest custom slash command was called\n")
  if EternusEngine.PointOfInterestUI then
    EternusEngine.PointOfInterestUI:ListPointsOfInterest(args)
  end
end

function Survival:RemovePointOfInterest(args)
  NKPrint("\nRemovePointOfInterest custom slash command was called\n")
  if EternusEngine.PointOfInterestUI then
    EternusEngine.PointOfInterestUI:RemovePointOfInterest(args)
  end
end

function Survival:DirectionToPointOfInterest(args)
  NKPrint("\nDirectionToPointOfInterest custom slash command was called\n")
  if EternusEngine.PointOfInterestUI then
    EternusEngine.PointOfInterestUI:DirectionToPointOfInterest(args[1])
  end
end

function Survival:DistanceToPointOfInterest(args)
  NKPrint("\nDistanceToPointOfInterest custom slash command was called\n")
  if EternusEngine.PointOfInterestUI then
    EternusEngine.PointOfInterestUI:DistanceToPointOfInterest(args[1])
  end
end

---------------- PointOfInterest mods code ends here ------------------
```
