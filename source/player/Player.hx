package player;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class Player extends FlxSprite {
    private static inline final SPEED:Float = 200;
    private static inline final GRAVITY:Float = 150;

    private var playerId:Int;

    public function new(X:Float = 0, Y:Float = 0, baseColor:Int = FlxColor.WHITE, playerId:Int = 0) {
        super(X, Y);

        makeGraphic(16, 16, baseColor);
        this.playerId = playerId;

        acceleration.y = GRAVITY;
    }

    private function movement() {
        var horizontalDirection:Int = 0;

        if (FlxG.keys.pressed.A) {
            horizontalDirection--;
        }

        if (FlxG.keys.pressed.D) {
            horizontalDirection++;
        }

        velocity.x = SPEED * horizontalDirection;
    }

    private function jump() {
        if (FlxG.keys.justPressed.SPACE) {
            velocity.y = -200;
        }
    }

    private function screenWrap() {
        if (x < -width) {
            x = FlxG.width;
        }

        if (x > FlxG.width) {
            x = -width;
        }

        if (y < -height) {
            y = FlxG.height;
        }

        if (y > FlxG.height) {
            y = -height;
        }
    }

    override function update(elapsed:Float) {
        movement();
        jump();
        screenWrap();

        super.update(elapsed);
    }
}