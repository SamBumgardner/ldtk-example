package;

import ldtk.Level;
import player.Player;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tile.FlxTilemap;
import flixel.group.FlxSpriteGroup;
import flixel.FlxState;

class PlayState extends FlxState
{
	public var player:Player;
	private var levelsCollision:Map<Int, FlxTilemap>;
	private var currentLevel:Level;
	private var currentLevelCollision:FlxTilemap;

	override public function create():Void
	{
		super.create();

		var project = new LdtkProject();
		levelsCollision = new Map<Int, FlxTilemap>();

		for (level in project.levels) {
			loadBackground(level);
			loadCollision(project, level.uid);
			loadVisuals(project, level.uid);
		}

		currentLevel = project.levels[0];
		currentLevelCollision = levelsCollision.get(currentLevel.uid);

		player = new Player();
		add(player);
	}

	private function loadBackground(level:Level) {
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

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		FlxG.collide(currentLevelCollision, player);
	}
}
