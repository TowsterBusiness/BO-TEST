package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;
typedef TitleData =
{

	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var biggsSmol:FlxSprite;
	var booSmol:FlxSprite;
	var buggsSmol:FlxSprite;
	var daisySmol:FlxSprite;
	var introBoo:FlxSprite;
	var introArson:FlxSprite;
	var lunaSmol:FlxSprite;
	var tulipSmol:FlxSprite;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var logoSpr:FlxSprite;
	var booty:FlxSprite;
	var bg:FlxSprite;
	var logoBl:FlxSprite;
	var titleText:FlxSprite;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var titleJSON:TitleData;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();

		Highscore.load();

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchAnimatedState(new FreeplayState());
		#elseif CHARTING && debug
		MusicBeatState.switchAnimatedState(new ChartingState());
		#else
		/*
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchAnimatedState(new FlashingState());
		} else {*/
			#if desktop
			if (!DiscordClient.isInitialized)
			{
				DiscordClient.initialize();
				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				});
			}
			#end

			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		//}
		#end
	}

	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('HungryMenuMusic'), 0);
			}
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		bg = new FlxSprite(-150, -150);
		bg.frames = Paths.getSparrowAtlas('titlestate/BGTitle');
		bg.animation.addByPrefix('yee', 'BGTitle', 24, false);
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		booty = new FlxSprite(235, 1500);
		booty.frames = Paths.getSparrowAtlas('titlestate/BooTitleScreen');
		booty.animation.addByPrefix('boo', 'Boozette', 24, false);
		booty.updateHitbox();
		booty.antialiasing = true;
		booty.flipX = true;
		booty.scale.set(0.4, 0.4);
		add(booty);

		logoBl = new FlxSprite(300, 70);
		logoBl.frames = Paths.getSparrowAtlas('titlestate/logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin0', 24, false);
		logoBl.updateHitbox();
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titlestate/titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin0", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED0", 24);
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;
		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		introBoo = new FlxSprite();
		introBoo.frames = Paths.getSparrowAtlas('titlestate/introBoo');
		introBoo.animation.addByPrefix('idle', "introBoo0", 24, false);
		introBoo.antialiasing = ClientPrefs.globalAntialiasing;
		introBoo.scale.set(1.725,1.725);
		introBoo.animation.play('idle');
		introBoo.updateHitbox();
		introBoo.screenCenter();
		introBoo.y += 110;
		add(introBoo);

		introArson = new FlxSprite();
		introArson.frames = Paths.getSparrowAtlas('titlestate/introArson');
		introArson.animation.addByPrefix('idle', "introArson0", 24);
		introArson.antialiasing = ClientPrefs.globalAntialiasing;
		introArson.scale.set(1.35,1.35);
		introArson.visible = false;
		introArson.updateHitbox();
		introArson.screenCenter();
		introArson.x += -140;
		introArson.y += -175;
		add(introArson);

		biggsSmol= new FlxSprite(FlxG.width * -(0.03) - 500, FlxG.height * 0.68 + 500).loadGraphic(Paths.image('titlestate/BiggsSmol'));
		biggsSmol.angle = 45;
		biggsSmol.antialiasing = ClientPrefs.globalAntialiasing;
		add(biggsSmol);

		booSmol = new FlxSprite(FlxG.width * 0.34, FlxG.height * 0.72 + 500).loadGraphic(Paths.image('titlestate/BooSmol'));
		booSmol.antialiasing = ClientPrefs.globalAntialiasing;
		add(booSmol);

		buggsSmol = new FlxSprite(FlxG.width * 0.76 + 500, FlxG.height * -(0.04) - 500).loadGraphic(Paths.image('titlestate/BuggsSmol'));
		buggsSmol.angle = 225;
		buggsSmol.antialiasing = ClientPrefs.globalAntialiasing;
		add(buggsSmol);

		daisySmol = new FlxSprite(FlxG.width * -(0.06) - 500, FlxG.height * -(0.04) - 500).loadGraphic(Paths.image('titlestate/DaisySmol'));
		daisySmol.angle = 130;
		daisySmol.antialiasing = ClientPrefs.globalAntialiasing;
		add(daisySmol);

		lunaSmol = new FlxSprite(FlxG.width * 0.34, FlxG.height * -(0.14) - 500).loadGraphic(Paths.image('titlestate/LunaSmol'));
		lunaSmol.angle = 180;
		lunaSmol.antialiasing = ClientPrefs.globalAntialiasing;
		add(lunaSmol);

		tulipSmol = new FlxSprite(FlxG.width * 0.78 + 500, FlxG.height * 0.62 + 500).loadGraphic(Paths.image('titlestate/TulipSmol'));
		tulipSmol.angle = -45;
		tulipSmol.antialiasing = ClientPrefs.globalAntialiasing;
		add(tulipSmol);

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
			}
			
			if(pressedEnter)
			{
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchAnimatedState(new MainMenuState());
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?xoffset:Float = 0, ?yoffset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.x += xoffset;
			money.y += (i * 60) + 200 + yoffset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?xoffset:Float = 0, ?yoffset:Float = 0, ?nextLine:Bool = false)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.x += xoffset;
			if (nextLine) coolText.y += (textGroup.length * 60) + 200 + yoffset; 
			else coolText.y += 200 + yoffset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null) logoBl.animation.play('bump');
		if(booty != null) booty.animation.play('boo', true);

		if(!closedState) {
			sickBeats++;
			//trace(sickBeats);
			switch (sickBeats)
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('HungryMenuMusic'), 0.7);
				case 8:
					introBoo.visible = false;
				case 9:
					createCoolText([curWacky[0]], 0, 50);
				case 11:
					addMoreText(curWacky[1],0, 130, true);
				case 12:
					deleteCoolText();
					introArson.visible = true;
					introArson.animation.play('idle');
				case 13:
					introArson.visible = false;
					addMoreText('Boo!',0, 100, false);
					FlxTween.tween(booSmol, {y: FlxG.height * 0.60}, 0.2, {ease: FlxEase.circOut});
				case 14:
					FlxTween.tween(biggsSmol, {x: FlxG.width * -(0.06), y: FlxG.height * 0.59}, 0.2, {ease: FlxEase.circOut});
					FlxTween.tween(buggsSmol, {x: FlxG.width * 0.73, y:FlxG.height * -(0.1)}, 0.2, {ease: FlxEase.circOut});
					addMoreText("Don't",-210, 180, false);
				case 15:
					FlxTween.tween(daisySmol, {x: FlxG.width * -(0.09), y:FlxG.height * -(0.07)}, 0.2, {ease: FlxEase.circOut});
					FlxTween.tween(tulipSmol, {x: FlxG.width * 0.75, y: FlxG.height * 0.59}, 0.2, {ease: FlxEase.circOut});
					addMoreText('Get', -0, 180, false);
				case 16:
					FlxTween.tween(lunaSmol, {y: FlxG.height * -(0.17)}, 0.2, {ease: FlxEase.circOut});
					addMoreText('Spooked',270, 180, false);
				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
			{
				FlxG.sound.music.time = 9150;

				remove(logoSpr);

				remove(introBoo);
				remove(introArson);
				remove(booSmol);
				remove(daisySmol);
				remove(biggsSmol);
				remove(buggsSmol);
				remove(tulipSmol);
				remove(lunaSmol);
	
				FlxG.camera.flash(FlxColor.WHITE, 4);
				remove(credGroup);
				skippedIntro = true;
	
				function stinky(stupid:FlxTimer):Void 
				{
					FlxTween.tween(booty,{y: -340}, 1.4, {ease: FlxEase.expoInOut});
					FlxTween.tween(logoBl,{x: -5}, 1.4, {ease: FlxEase.expoInOut});
				}
				new FlxTimer().start(0.1, stinky);

				logoBl.angle = -4;
	
				new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
					if(logoBl.angle == -4) 
						FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
					if (logoBl.angle == 4) 
						FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
				}, 0);
			}
	}
}
