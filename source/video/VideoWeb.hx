package video;

import openfl.media.SoundTransform;
import openfl.events.Event;
import openfl.display.Sprite;
import flixel.FlxG;
import openfl.events.AsyncErrorEvent;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;

private typedef PlayStatusData = { code:String, duration:Float, position:Float, speed:Float }
private typedef MetaData = { width:Int, height:Int, duration:Float }

class VideoWeb extends Sprite
{ 
    public var requestedExit = false;
    public var onComplete:()->Void;
    public var onPause:()->Void;
    public var onStart:()->Void;

    public var isPaused = false;

    var netStream:NetStream;
    var video:Video;
    var moveTimer = 2.0;
    
    public function new()
    {
        super();
        
        addChild(video = new Video());
        
        var netConnection = new NetConnection();
        netConnection.connect(null);
        
        netStream = new NetStream(netConnection);
        netStream.client =
            { onMetaData  : onMetaData
            , onPlayStatus: onPlayStatus
            };
        netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, (e)->trace("error loading video"));
        netConnection.addEventListener(NetStatusEvent.NET_STATUS,
            function onNedtStatus(event)
            {
                trace("net status:" + haxe.Json.stringify(event.info));
                if (event.info.code == "NetStream.Play.Complete")
                    onVideoComplete();
            }
        );

        FlxG.addChildBelowMouse(this);
        FlxG.stage.addEventListener(Event.ENTER_FRAME, update);
    }

    private function update(?E:Event):Void
    {
        netStream.soundTransform = new SoundTransform(#if FLX_SOUND_SYSTEM ((FlxG.sound.muted) ? 0 : 1) * FlxG.sound.volume #else FlxG.sound.volume #end, 0);
    }

    public function playVideo(path:String) {
        netStream.play(path);
        isPaused = false;
    }
    
    var isFirst = true;
    function onMetaData(data:MetaData)
    {
        if (isFirst) {
            if (onStart != null)
                onStart();
            isFirst = false;
        }

        final stage = FlxG.stage;
        video.attachNetStream(netStream);
        video.width = video.videoWidth;
        video.height = video.videoHeight;
        
        if (video.videoWidth / stage.stageWidth > video.videoHeight / stage.stageHeight)
        {
            video.width = stage.stageWidth;
            video.height = stage.stageWidth * video.videoHeight / video.videoWidth;
        }
        else
        {
            video.height = stage.stageHeight;
            video.width = stage.stageHeight * video.videoWidth / video.videoHeight;
        }
        
        if (video.width < stage.stageWidth)
            video.x = (stage.stageWidth - video.width) / 2;
        
        if (video.height < stage.stageHeight)
            video.y = (stage.stageHeight - video.height) / 2;
    }
    
    function onPlayStatus(data:PlayStatusData)
    {
    }
    
    function onVideoComplete()
    {
        destroy();
        
        if (onComplete != null)
            onComplete();
    }
    
    public function pause()
    {
        netStream.pause();
        isPaused = true;

        if (onPause != null) 
            onPause();
    }
    
    public function resume()
    {
        netStream.resume();
        isPaused = false;

        if (onPause != null)
            onPause();
    }

    public function togglePause()
    {
        isPaused ? resume() : pause();
    }
    
    public function destroy()
    {
        if (FlxG.stage.hasEventListener(Event.ENTER_FRAME))
			FlxG.stage.removeEventListener(Event.ENTER_FRAME, update);

        FlxG.removeChild(this);

        netStream.dispose();
    }
}