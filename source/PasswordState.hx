package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import Achievements;
import WeekData;
import LoadingState.LoadingsState;

class PasswordState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var cursorThing:FlxSprite;
	var moonCode:FlxSprite;
	var enterText:FlxText;
	var passwordText:FlxInputText;
	var htmlPasswordText:BadFlxUIInput;

	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	override function create()
	{
		super.create();

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		enterText = new FlxText(0, 0, 0, "Type a code", 25);
		enterText.setFormat('RetroVille NC', 25, FlxColor.GRAY, CENTER);
		enterText.screenCenter();
		enterText.y += 110;
		add(enterText);

		#if html5
		htmlPasswordText = new BadFlxUIInput(0, 0, 500, 60, "", 36);
        htmlPasswordText.screenCenter(XY);
		htmlPasswordText.setMaxLength(18);
		htmlPasswordText.y += 40;
        add(htmlPasswordText);
		#else
		passwordText = new FlxUIInputText(0, 300, 550, '', 36, FlxColor.BLACK, FlxColor.WHITE);
		passwordText.setFormat('RetroVille NC', 36, FlxColor.BLACK);
		passwordText.maxLength = 18;
		passwordText.screenCenter(X);
		passwordText.y += 75;
		add(passwordText);
		#end

		moonCode = new FlxSprite(570, 200);
		moonCode.frames = Paths.getSparrowAtlas('mainmenu/mooncode');
		moonCode.animation.addByPrefix('idle', 'Moon code basic', 24);
		moonCode.animation.play('idle');
		moonCode.setGraphicSize(Std.int(moonCode.width * 0.31));
		moonCode.updateHitbox();
		moonCode.antialiasing = ClientPrefs.globalAntialiasing;
		add(moonCode);

		cursorThing = new FlxSprite().loadGraphic(Paths.image('mainmenu/mouse/default'));
		cursorThing.antialiasing = ClientPrefs.globalAntialiasing;
		cursorThing.updateHitbox();
		add(cursorThing);
		
	}

	override function update(elapsed:Float)
	{
		var wrongPass:Bool = false;

		cursorThing.x = FlxG.mouse.x - 10;
		cursorThing.y = FlxG.mouse.y - 1;

	 	if (getPasswordText() != "" && FlxG.keys.justPressed.ENTER)
		{
			trace(getPasswordText());
			new FlxTimer().start(0.7, function(tmr:FlxTimer){
				switch (getPasswordText().toLowerCase())
				{	
					case 'backstory': CoolUtil.browserLoad('https://www.youtube.com/watch?v=dQw4w9WgXcQ');
					case 'treats and tricks': CoolUtil.browserLoad('https://sites.google.com/view/treats-and-tricks');
					case 'trailer': CoolUtil.browserLoad('https://www.youtube.com/watch?v=jzjuRyE6abg');
					case 'true self': CoolUtil.browserLoad('https://www.youtube.com/watch?v=nnD9yRQnJGA');
					case 'nightmares': CoolUtil.browserLoad('https://youtu.be/jMnW_xpRJzg');
					case 'boo': CoolUtil.browserLoad('https://sites.google.com/view/treats-and-tricks');
					case 'regret': CoolUtil.browserLoad('https://cdn.discordapp.com/attachments/936699212324814870/1011126671421734972/Regret.png ');
					case 'consequence': CoolUtil.browserLoad('https://sites.google.com/view/treats-and-tricks/val');
					case 'remorse': CoolUtil.browserLoad('https://youtu.be/8cBTJjhEWEQ');
					case 'clown' | 'clover' | 'caramel' | 'guitar' | 'stop' | '2151' /*| 'moondrink'*/:
						FlxTween.color(enterText, 0.3, enterText.color, FlxColor.ORANGE, {
							onComplete: function(twn:FlxTween) {
								FlxTween.color(enterText, 0.3, enterText.color, FlxColor.GRAY);
							}
						});

						var nameSong:String = '';
						switch (getPasswordText().toLowerCase())
						{
							case 'clown': nameSong = 'tricky-or-treat';
							case 'clover': nameSong = 'boo-sticky';
							case 'caramel': nameSong = 'caramel';
							case 'guitar': nameSong = 'deadly-colors';
							case 'stop': nameSong = 'stumble-station';
							case '2151': nameSong = 'satellite-picnic';
							//case 'moondrink': nameSong = '';
						}

						WeekData.reloadWeekFiles(false, true);
						var songLowercase:String = Paths.formatToSongPath(nameSong);

						PlayState.SONG = Song.loadFromJson(nameSong, songLowercase);
						PlayState.isStoryMode = false;
						PlayState.fromMenu = 1;
						PlayState.storyDifficulty = 0;
						PlayState.storyWeek = 0;

						CustomFadeTransition.nextCamera = CustomAnimatedTransition.nextCamera = camAchievement;
						var occurence:Int = ClientPrefs.freeplayUnlocked.indexOf(nameSong);
						if (occurence == -1) {
							ClientPrefs.freeplayUnlocked.push(nameSong);
							ClientPrefs.saveSettings();
							var unlockSong = new UnlockMooncodeObject(nameSong, camAchievement);
							FlxG.sound.play(Paths.sound('confirmMenu'));
							add(unlockSong);
							unlockSong.onFinish = moveOn;
						} else moveOn();

						FlxG.sound.music.volume = 0;
					default:
						FlxTween.color(enterText, 0.3, enterText.color, FlxColor.RED, {
							onComplete: function(twn:FlxTween) {
								FlxTween.color(enterText, 0.3, enterText.color, FlxColor.GRAY);
							}
						});
						wrongPass = true;
				}
			});
		}

		if (wrongPass)
		{
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, 'shared'));
			setPasswordText("");
			wrongPass = false;
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			CustomFadeTransition.nextCamera = CustomAnimatedTransition.nextCamera = camAchievement;
			MusicBeatState.switchAnimatedState(new MainMenuState());
		}
		
		super.update(elapsed);
	}

	function getPasswordText():String {
		#if html5
		return htmlPasswordText.text.text;
		#else
		return passwordText.text;
		#end
	}

	function setPasswordText(input:String):Void {
		#if html5
		htmlPasswordText.text.text = input;
		#else
		passwordText.text = input;
		#end
	}

	function moveOn() {
		MusicBeatState.switchState(LoadingState.getNextState(new LoadingsState(), false));
	}
}
