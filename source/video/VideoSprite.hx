package video;

import video.VideoWeb;

#if desktop
import video.VideoDesktop;
import openfl.display.Sprite;
#end

import video.VideoWeb;

#if desktop
import video.VideoDesktop;
import openfl.display.Sprite;
#end

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.FlxG;

class VideoSprite extends FlxSprite {
    #if html5
    private var bitmap:VideoWeb;
    #else
    private var bitmap:VideoDesktop;
    #end


    public var openingCallback:Void->Void = null;
    public var finishCallback:Void->Void = null;
    public var pauseCallback:Void->Void = null;
    public var readyCallback:Void->Void = null;

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
        makeGraphic(1, 1, FlxColor.TRANSPARENT);

        #if html5
            trace("HTML5");
            bitmap = new VideoWeb();
            // bitmap.alpha = 0;
            bitmap.onStart = () -> {
                if (openingCallback != null)
                    openingCallback();
            }
            bitmap.onPause = () -> {
                if (bitmap.isPaused)
                    FlxTween.tween(this.colorTransform, {redMultiplier: 0.6, greenMultiplier: 0.6, blueMultiplier: 0.6}, 0.3);
                else
                    FlxTween.tween(this.colorTransform, {redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1}, 0.3);
            }
            bitmap.onComplete = () -> {
                if (finishCallback != null)
                    finishCallback();

                kill();
            }
        #else
            bitmap = new VideoDesktop();
            bitmap.canUseAutoResize = false;
            bitmap.alpha = 0;
            bitmap.openingCallback = function()
            {
                if (openingCallback != null)
                    openingCallback();
            }
            bitmap.pauseCallback = () ->
            {
                if (bitmap.isPlaying)
                    FlxTween.tween(this.colorTransform, {redMultiplier: 0.6, greenMultiplier: 0.6, blueMultiplier: 0.6}, 0.3);
                else
                    FlxTween.tween(this.colorTransform, {redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1}, 0.3);
                
                if (pauseCallback != null)
                    pauseCallback();
            }
            bitmap.finishCallback = function()
            {
                if (finishCallback != null)
                    finishCallback();

                kill();
            }
        #end

    }

    var _resizing:Bool = true;
    override function update(elapsed:Float) {
        super.update(elapsed);

        #if desktop
            if (bitmap.isPlaying && bitmap.isDisplaying && bitmap.bitmapData != null)
            {
                pixels = bitmap.bitmapData;
                if (_resizing) // dumb fix since hxCodec's VideoSprite broke
                {
                    _resizing = false;
                    setGraphicSize(FlxG.width, FlxG.height);
                    updateHitbox();
                }
            }
        #end

        if (FlxG.keys.justPressed.ENTER #if android || FlxG.android.justReleased.BACK #end)
            kill();

        if (FlxG.keys.justPressed.SPACE)
            checkPause();

        if (FlxG.keys.justPressed.LEFT)
            skip(-5000);
        else if (FlxG.keys.justPressed.RIGHT)
            skip(5000);
    }

    public function playVideo(path:String) {
        #if html5
            bitmap.playVideo(path);
        #else
            bitmap.playVideo(path);
        #end
        
    }

    private function skip(time:Int) {
        #if desktop
            if (time < 0) {
                time = -time;
                bitmap.time -= (bitmap.time > time) ? time : bitmap.time - 1;
            }
            else
            {
                if ((bitmap.length - bitmap.time) > time)
                    bitmap.time += time;
                else
                    kill();
            }
        #end
    }

    private function pause() {
        #if html5
            bitmap.pause();
        #else
            bitmap.pause();
        #end

        if (pauseCallback != null)
            pauseCallback();
    }

    private function resume() {
        #if html5
            bitmap.resume();
        #else
            bitmap.resume();
        #end
    }

    private function checkPause() {
        #if html5
            bitmap.togglePause();
        #else
            bitmap.checkPause();
        #end
    }

    override function kill() {
        #if html5
            bitmap.destroy();
        #else
            bitmap.kill();
        #end

        if (finishCallback != null)
            finishCallback();

        super.kill();
    }

}