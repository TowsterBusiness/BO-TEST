import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class TweeningSprite extends FlxSprite {
    public var chosenPlace:String = '';

    public function new(X:Float = 0, Y:Float = 0) {
        super(X, Y);
        x = X;
        y = Y;
    }

    public function tweenFromString(tweenStr:String) {
        chosenPlace = tweenStr;
        scale.set(0.65, 0.65);

        centerOrigin();
        
        switch (chosenPlace)
        {
            case '00':
                x = FlxG.width * 0.05;
                y = FlxG.height * 0.62 + 500;
                FlxTween.tween(this, {y: y - 500}, 0.2, {ease: FlxEase.quadInOut});
            case '01':
                x = FlxG.width * 0.6;
                y = FlxG.height * 0.62 + 500;
                FlxTween.tween(this, {y: y - 500}, 0.2, {ease: FlxEase.quadInOut});
            case '10':
                x = FlxG.width * 0.77 + 500;
                y = FlxG.height * 0.22;
                FlxTween.tween(this, {x: x - 500}, 0.2, {ease: FlxEase.quadInOut});
                angle += -90;
            case '20':
                x = FlxG.width * 0.6;
                y = FlxG.height * -0.17 - 500;
                angle += -180;
                FlxTween.tween(this, {y: y + 500}, 0.2, {ease: FlxEase.quadInOut});
            case '21':
                x = FlxG.width * 0.05;
                y = FlxG.height * -0.17 - 500;
                angle += -180;
                FlxTween.tween(this, {y: y + 500}, 0.2, {ease: FlxEase.quadInOut});
            case '30':
                x = FlxG.width * -0.12 - 500;
                y = FlxG.height * 0.22;
                angle += -270;
                FlxTween.tween(this, {x: x + 500}, 0.2, {ease: FlxEase.quadInOut});
        }
    }

    public function tweenBack() {
        switch (chosenPlace)
        {
            case '00': FlxTween.tween(this, {y: y + 500}, 0.2, {ease: FlxEase.quadInOut});
            case '01': FlxTween.tween(this, {y: y + 500}, 0.2, {ease: FlxEase.quadInOut});
            case '10': FlxTween.tween(this, {x: x + 500}, 0.2, {ease: FlxEase.quadInOut});
            case '20': FlxTween.tween(this, {y: y - 500}, 0.2, {ease: FlxEase.quadInOut});
            case '21': FlxTween.tween(this, {y: y - 500}, 0.2, {ease: FlxEase.quadInOut});
            case '30': FlxTween.tween(this, {x: x - 500}, 0.2, {ease: FlxEase.quadInOut});
        }
    }
}