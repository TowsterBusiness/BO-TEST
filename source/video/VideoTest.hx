package video;

import flixel.FlxState;
import video.VideoSprite;

class VideoTest extends FlxState {
    var video:VideoSprite;
    override function create() {
        super.create();

        video = new VideoSprite(0, 0);
        add(video);

        video.playVideo('assets/videos/EndCredits3.mp4');
    }
}