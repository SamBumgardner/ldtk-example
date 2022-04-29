package;

import openfl.utils.Assets;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import ldtk.Level;
import player.Player;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tile.FlxTilemap;
import flixel.group.FlxSpriteGroup;
import flixel.FlxState;

class PlayState extends FlxState
{
	private var project:LdtkProject;

	private var players:FlxTypedGroup<Player>;
	private var levelsCollision:Map<Int, FlxTilemap>;
	private var currentLevel:Level;
	private var currentLevelCollision:FlxTilemap;
	private var victoryMessage:FlxText;

	override public function create():Void {
		super.create();

		project = new LdtkProject();

		levelsCollision = new Map<Int, FlxTilemap>();

		for (level in project.levels) {
			loadBackground(level);
			loadCollision(project, level.uid);
			loadVisuals(project, level.uid);
			loadEntities(project, level.uid);
		}

		currentLevel = project.levels[0];
		currentLevelCollision = levelsCollision.get(currentLevel.uid);
	}

	///////////////////
	// LEVEL LOADING //
    ///////////////////
	private function loadBackground(level:Level) {
		// We have to add 0xFF000000 to any colors provided by LDtk because HaxeFlixel expects
		// alpha channel info in front of RGB values, not providing it makes the color transparent.
		bgColor = FlxColor.fromInt(0xFF000000 + level.bgColor_int);
	}

	private function loadCollision(project:LdtkProject, levelId:Int) {
		// Retrieve the level currently being loaded
		// Can't be passed in - retrieving if from the LdtkProject gives us the layer types.
		var level = project.getLevel(levelId);

		// Hard-coded list that should be interpreted as "collision happens here"
		var collisionValues = [1];

		// generate array from IntGrid layer, zeroes mean no collision
		var mapData:Array<Int> = [
			for (i in 0...Std.int(level.l_Environment_IntGrid.cWid * level.l_Environment_IntGrid.cHei))
			{
				if (level.l_Environment_IntGrid.intGrid.get(i) != null) {
				collisionValues.contains(level.l_Environment_IntGrid.intGrid.get(i)) ? 1 : 0;
				} 
				else {
					0;
				}
			}
		];

		// Use array of 1s and 0s to create an FlxTilemap for collision
		var collisionMap = new FlxTilemap();
		collisionMap.setPosition(level.worldX, level.worldY);
		collisionMap.loadMapFromArray(mapData, 
			level.l_Environment_IntGrid.cWid, 
			level.l_Environment_IntGrid.cHei, 
			AssetPaths.collision__png, 8, 8);

		// We don't care about making the map getting drawn or updated
		collisionMap.visible = false;
		collisionMap.active = false;

		// add the collisionMap to the state
		add(collisionMap);

		// store a reference keyed by level ID for when we want to use this later
		levelsCollision.set(level.uid, collisionMap);
	}

	private function loadVisuals(project:LdtkProject, levelId:Int) {
		// Retrieve the level currently being loaded
		// Can't be passed in - retrieving if from the LdtkProject gives us the layer types.
		var level = project.getLevel(levelId);

		// Create a FlxGroup for all level layers
		var container = new FlxSpriteGroup();

		// Place it using level world coordinates (in pixels)
		container.x = level.worldX;
		container.y = level.worldY;
		add(container);

		// Render layer "IntGrid"
		level.l_Environment_IntGrid.render( container );
	}

	private function loadEntities(project:LdtkProject, levelId:Int) {
		// Retrieve the level currently being loaded
		// Can't be passed in - retrieving if from the LdtkProject gives us the layer types.
		var level = project.getLevel(levelId);

		// Iterate through all 'Player' entities in the layer named 'Entities'
		// We offload the work of creating a new player instance to a instantiatePlayer - it's 
		// overkill in this case, but it's a bit cleaner than shoving everying in here.
		players = new FlxTypedGroup<Player>(level.l_Entities.all_Player.length);
		for (playerEntity in level.l_Entities.all_Player) {
			players.add(instantiatePlayer(playerEntity));
		}
		add(players);

		// Instantiate victory message - we build in the assumption here that there will only ever
		// be one to handle.
		victoryMessage = instantiateVictoryMessage(level.l_Entities.all_Victory_Message[0]);
		
		add(victoryMessage);
	}

	private function instantiatePlayer(playerEntity:LdtkProject.Entity_Player):Player {
		return new Player(
			playerEntity.pixelX, 
			playerEntity.pixelY, 
			// Colors need alpha channel info added, same as background loading.
			0xFF000000 + playerEntity.f_Color_int,
			playerEntity.f_Player_Id
			);
	}

	private function instantiateVictoryMessage(victoryMessageEntity:LdtkProject.Entity_Victory_Message):FlxText {
		var victoryMessage = new FlxText(
			victoryMessageEntity.pixelX,
			victoryMessageEntity.pixelY,
			victoryMessageEntity.width,
			victoryMessageEntity.f_Message,
			victoryMessageEntity.height
		);
		victoryMessage.visible = false;
		return victoryMessage;
	}

#if FLX_DEBUG
	/////////////////
	// DEBUG TOOLS //
	/////////////////
	private function reloadLevel() {
		FlxG.resetState();
	}

#end

	////////////////
	// "GAMEPLAY" //
    ////////////////
	private inline function doPlayersCompletelyOverlap() {
		return players.members[0].getPosition().equals(players.members[1].getPosition());
	}

	private inline function victory() {
		victoryMessage.visible = true;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		FlxG.collide(currentLevelCollision, players);

		if (doPlayersCompletelyOverlap()) {
			victory();
		}

#if FLX_DEBUG
		if (FlxG.keys.justPressed.R) {
			reloadLevel();
		}
#end
	}
}
