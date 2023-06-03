package;

//import js.html.AbortController;
//import flixel.addons.editors.spine.FlxSpine;
import flixel.math.FlxRandom;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import LoadingState.LoadingsState;
import flixel.util.FlxGradient;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import animateatlas.AtlasFrameMaker;
import openfl.filters.GlowFilter;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import WeekData;


import video.VideoSprite;

#if sys
import sys.FileSystem;
#end

#if VIDEOS_ALLOWED
//import vlc.MP4Handler;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	var rating:TweeningText;
	var scoreGain:TweeningText;
	var sumScoreTxt:TweeningText;
	var comboRatingGroup:FlxTypedGroup<TweeningText>;
	var comboRatingTimer:FlxTimer;
	var sumScoreTemporary:Int;
	var transGradient:FlxSprite;
	var filterFrames:FlxFilterFrames;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();

	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var extraGhostSONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var fromMenu:Int = 0;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 0;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var extraGhostNotes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var songname:String;
	var ofs = 5;
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var gameOverCameraKeepZoom = true;
	var gameOverZoom:Float = -10000;
	var stageData:StageFile;

	// house stage elements
	var silence1:BGSprite;
	var silence2:BGSprite;
	var silence3:BGSprite;
	var silence4:BGSprite;
	var door:BGSprite;
	var counter:FlxSprite;
	var bgCameo:FlxTypedGroup<TeintedCameo>;
	var scaredCameos:FlxTypedGroup<ScaredCameo>;
	var cameoNumber:Int;
	var cameoPassingNumber:Int = 0;

	// holiday stage elements
	var bg:BGSprite;
	var mid:SpookyPublic;
	var fore:SpookyPublic;
	var ghostExtras:Character;
	var spotlight:BGSprite;
	var heyGhosts:BGSprite;
	var CameraTween:FlxTween;
	var bgTween:FlxTween;

	// golden days stage elemnts
	var daisySit:Character;
	var lunaSit:Character;
	var shootingStar:FlxSprite;
	var sparkles:FlxSprite;
	var initialCamX:Float;
	var initialCamY:Float;
	var bg1:BGSprite;
	var bg2:BGSprite;
	var bg3:BGSprite;
	var bg4:BGSprite;
	var lyricalText:FlxText;
	var secondlyricalText:FlxText;
	var coverScreen:FlxSprite;
	var lowBlackBar:FlxSprite;
	var highBlackBar:FlxSprite;

	// mooncode stuff
	var cuts:FlxSpriteGroup;
	var blueLayer:FlxSprite;

	//name song showing up
	var bookmark:FlxSprite;
	var nowPlaying:FlxText;
	var nameOfSong:FlxText;

	// BG layering, format: first [0] - in front of GF, second [1] - in front of opponent, third [2] - in front of boyfriend(and technically also opponent since Haxe layering moment)
	public var layInFront:Array<Array<FlxSprite>> = [[], [], []];
	public var noCameraFollow:Bool = false;

	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	var precacheList:Map<String, String> = new Map<String, String>();

	override public function create()
	{
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = CustomAnimatedTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			switch (songName)
			{
				case 'boo' | 'boo-sticky':
					curStage = 'house';
				case 'ghost-picnic' | 'heart-of-gold' | 'skeleton-passion':
					curStage = 'holidayStage';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);

				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}

            case 'house': //boo song
				var bg:BGSprite = new BGSprite('house/NightSky', -20, -20, 1, 1, null, false, 'spweeked');
                add(bg);

				door = new BGSprite('house/DoorAnim', 60, 90, 1, 1, ['DoorCloseFast', 'DoorOpenSlow', 'DoorOpenFast', 'DoorClosed'], false, 'spweeked');
				door.setGraphicSize(Std.int(door.width * 1.2));
                door.animation.play('DoorClosed');
				add(door);

				silence1 = new BGSprite('house/Font1', 0, 0, 1, 1, ['Font1'], false, 'spweeked');
				silence1.setGraphicSize(Std.int(silence1.width * 0.8));
				silence1.alpha = 0;

				silence2 = new BGSprite('house/Font2', 0, 500, 1, 1, ['Font2'], false, 'spweeked');
				silence2.setGraphicSize(Std.int(silence2.width * 0.8));
				silence2.alpha = 0;

				silence3 = new BGSprite('house/Font3', 0, 100, 1, 1, ['Font3'], false, 'spweeked');
				silence3.setGraphicSize(Std.int(silence3.width * 0.8));
				silence3.alpha = 0;

				silence4 = new BGSprite('house/Font4', -200, 50, ['Font4'], false, 'spweeked');
				silence4.setGraphicSize(Std.int(silence4.width * 0.8));
				silence4.alpha = 0;
			case 'world-travel-beginning':
			case 'street':
				bg1 = new BGSprite('street/BG_Neighborhood', 100, 400, 1, 1, null, false, 'spweeked');
				bg1.updateHitbox();
				add(bg1);

				bg2 = new BGSprite('street/BG_Wire', 100, 400, 1, 1, null, false, 'spweeked');
				bg2.updateHitbox();
				add(bg2);

				tricksCameo();

				bg3 = new BGSprite('street/Bush', 610, 690, 1, 1, null, false, 'spweeked');
				bg3.updateHitbox();
				add(bg3);
			case 'jazz-bar':
				bg1 = new BGSprite('Bar/JazzBar', 100, 400, 1, 1, null, false, 'spweeked');
				bg1.updateHitbox();
				//bg1.scale.set(1.3,1.3);
				add(bg1);

				var animArray:Array<String> = ["CrowdFront0"];

				bg2 = new BGSprite('Bar/Crowd', 100, 800, 1, 1, animArray, false, 'spweeked');
				bg2.updateHitbox();
				layInFront[2].push(bg2);

				
				if (songName == 'treats') {
					lunaSit = new Character(880, 635, 't-bone');
					add(lunaSit);
				}
			case 'holidayStage': // holiday week
				bg = new BGSprite('holidayStage/StageAlone', -960, -640, 0.9, 0.9, null, false, 'winterweek');
				bg.updateHitbox();
				add(bg);

				mid = new SpookyPublic(bg.x + 100, (bg.y + bg.height) - 400, "mid", "something_else");
				mid.scrollFactor.set(0.9, 0.9);
				layInFront[2].push(mid);

				fore = new SpookyPublic((mid.x + mid.width) - 200, bg.y + 150, "fore", "something_else");
				fore.scrollFactor.set(0.7, 0.7);
				layInFront[2].push(fore);

				var animArray:Array<String> = ["SpotlightStillClosed0", "SpotlightStillOpened0","SpotlightStillAnim0"];

				spotlight = new BGSprite('holidayStage/Spotlight', -900, -600, 0.9, 0.9, animArray, false, 'winterweek');
				spotlight.scale.x = 1.3;
				spotlight.scale.y = 1.3;
				spotlight.updateHitbox();
				layInFront[2].push(spotlight);

				if (songName == 'skeleton-passion') {
					var animArray:Array<String> = ["SkeletonPassionIntroAnim0"];

					heyGhosts = new BGSprite('holidayStage/Hey_Skele', -625, -210, 0.9, 0.9, animArray, false, 'winterweek');
					heyGhosts.scale.set(0.61, 0.61);
					//heyGhosts.screenCenter();
					heyGhosts.updateHitbox();
					camHUD.alpha = 0;
					layInFront[2].push(heyGhosts);
				}

			case 'beach':
				bg1 = new BGSprite('beach/BeachSky', 100, 400, 1, 1, null, false, 'goldendays');
				bg1.updateHitbox();
				add(bg1);

				bg2= new BGSprite('beach/BeachMid', 100, 400, 1, 1, null, false, 'goldendays');
				bg2.updateHitbox();
				add(bg2);

				bg3 = new BGSprite('beach/PalmTree', 100, 400, 1, 1, null, false, 'goldendays');
				bg3.updateHitbox();
				add(bg3);

				var animArray:Array<String> = ["Fire0"];

				var campFire:BGSprite = new BGSprite('beach/CampFire', 443, 680, 1, 1, animArray, true, 'goldendays');
				campFire.scale.x = 0.64;
				campFire.scale.y = 0.64;
				campFire.animation.play('Fire0', true);
				campFire.updateHitbox();
				layInFront[2].push(campFire);
			case 'city':
				bg1 = new BGSprite('city/CitySky', -815, 425, 1, 1, null, false, 'goldendays');
				bg1.updateHitbox();
				add(bg1);

				bg2 = new BGSprite('city/city', -815, 425, 1, 1, null, false, 'goldendays');
				bg2.updateHitbox();
				add(bg2);

				bg3 = new BGSprite('city/lights', -2615, 525, 1, 1, null, false, 'goldendays');
				bg3.scale.set(2,2);
				bg3.updateHitbox();
				layInFront[2].push(bg3);

				highBlackBar = new FlxSprite();
				highBlackBar.makeGraphic(FlxG.width, 100, FlxColor.BLACK);
				highBlackBar.cameras = [camHUD];
				highBlackBar.setPosition(0,0);
				add(highBlackBar);

				lowBlackBar = new FlxSprite();
				lowBlackBar.makeGraphic(FlxG.width, 100,FlxColor.BLACK);
				lowBlackBar.cameras = [camHUD];
				lowBlackBar.setPosition(0,FlxG.height - 100);
				add(lowBlackBar);
			case 'picnic-sunset':
				bg1 = new BGSprite('picnic-sunset/BackgroundSky', 100, 400, 1, 1, null, false, 'goldendays');
				bg1.updateHitbox();
				add(bg1);

				bg2 = new BGSprite('picnic-sunset/CityMidground', 100, 400, 1, 1, null, false, 'goldendays');
				bg2.updateHitbox();
				add(bg2);

				bg3 = new BGSprite('picnic-sunset/TreesFront', 100, 400, 1, 1, null, false, 'goldendays');
				bg3.updateHitbox();
				add(bg3);
			case 'nevada':
				bg = new BGSprite('nevada/BG', -850, -435, 0.9, 0.9, null, false, 'mooncode');
				bg.scale.set(3.5,3.5);
				bg.updateHitbox();
				add(bg);

				highBlackBar = new FlxSprite();
				highBlackBar.makeGraphic(FlxG.width, 100, FlxColor.BLACK);
				highBlackBar.cameras = [camHUD];
				highBlackBar.setPosition(0,0);
				add(highBlackBar);

				lowBlackBar = new FlxSprite();
				lowBlackBar.makeGraphic(FlxG.width, 100,FlxColor.BLACK);
				lowBlackBar.cameras = [camHUD];
				lowBlackBar.setPosition(0,FlxG.height - 100);
				add(lowBlackBar);
			case 'basement':
				bg1 = new BGSprite('basement/Basement', 100, 400, 1, 1, null, false, 'mooncode');
				//bg1.scale.set(1.5,1.5);
				bg1.updateHitbox();
				add(bg1);

				bg2 = new BGSprite('basement/Shelves', 100, 450, 1, 1, null, false, 'mooncode');
				bg2.scale.set(1.5,1.5);
				//bg2.updateHitbox();
				add(bg2);

				blueLayer = new FlxSprite(-FlxG.width, -FlxG.width);
				blueLayer.makeGraphic(FlxG.width * 4, FlxG.height * 4, 0x88000066);
				add(blueLayer);
			case 'city-mall':
				bg1 = new BGSprite('city-mall/Citymall', 100, 100, 1, 1, null, false, 'mooncode');
				bg1.updateHitbox();
				bg1.scale.set(2,2);
				add(bg1);

				var animArray:Array<String> = ["Crowd Back0"];

				bg2 = new BGSprite('city-mall/backCameos', 100, 400, 1, 1, animArray, false, 'mooncode');
				bg2.updateHitbox();
				add(bg2);

				animArray = ["Crowd Front0"];

				bg3 = new BGSprite('city-mall/frontCameos', 100, 550, 1, 1, animArray, false, 'mooncode');
				bg3.updateHitbox();
				layInFront[2].push(bg3);

				highBlackBar = new FlxSprite();
				highBlackBar.makeGraphic(FlxG.width, 100, FlxColor.BLACK);
				highBlackBar.cameras = [camHUD];
				highBlackBar.setPosition(0,0);
				add(highBlackBar);

				lowBlackBar = new FlxSprite();
				lowBlackBar.makeGraphic(FlxG.width, 100,FlxColor.BLACK);
				lowBlackBar.cameras = [camHUD];
				lowBlackBar.setPosition(0,FlxG.height - 100);
				add(lowBlackBar);
			case 'rainy':
				var animArray:Array<String> = ["RainSizzle instance"];

				bg1 = new BGSprite('rainy/RainSizzle', 100, 650, 1, 1, animArray, true, 'mooncode');
				bg1.updateHitbox();
				bg1.scale.set(2.5,2.5);
				add(bg1);
				
				animArray = ["RainLoop instance"];

				bg2 = new BGSprite('rainy/Rain', -260, 400, 1, 1, animArray, true, 'mooncode');
				bg2.updateHitbox();
				
				highBlackBar = new FlxSprite();
				highBlackBar.makeGraphic(FlxG.width, 100, FlxColor.BLACK);
				highBlackBar.cameras = [camHUD];
				highBlackBar.setPosition(0,0);
				add(highBlackBar);

				lowBlackBar = new FlxSprite();
				lowBlackBar.makeGraphic(FlxG.width, 100,FlxColor.BLACK);
				lowBlackBar.cameras = [camHUD];
				lowBlackBar.setPosition(0,FlxG.height - 100);
				add(lowBlackBar);
			case 'picnic':
				bg1 = new BGSprite('picnic/Nikku-1', 100, 400, 1, 1, null, false, 'mooncode');
				bg1.flipX = true;
				bg1.updateHitbox();
				add(bg1);

				bg2 = new BGSprite('picnic/Nikku-2', 100, 400, 1, 1, null, false, 'mooncode');
				bg2.flipX = true;
				bg2.updateHitbox();
				add(bg2);

				bg3 = new BGSprite('picnic/Nikku-3', 100, 400, 1, 1, null, false, 'mooncode');
				bg3.flipX = true;
				bg3.updateHitbox();
				add(bg3);

				bg4 = new BGSprite('picnic/Nikku-4', 100, 400, 1, 1, null, false, 'mooncode');
				bg4.flipX = true;
				bg4.updateHitbox();
				add(bg4);
		}

		if (isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		for (index => array in layInFront)
		{
			switch (index)
			{
				case 0:
					add(gfGroup);
					gfGroup.scrollFactor.set(0.95, 0.95);
					for (bg in array)
						add(bg);
				case 1:
					add(dadGroup);
					dadGroup.scrollFactor.set(0.95, 0.95);
					for (bg in array)
						add(bg);
				case 2:
					add(boyfriendGroup);
					boyfriendGroup.scrollFactor.set(0.95, 0.95);
					for (bg in array)
						add(bg);
			}
		}

		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dadGroup);
		add(boyfriendGroup);

		switch(curStage)
		{
			case 'spooky':
				add(halloweenWhite);
			case 'tank':
				add(foregroundSprites);
			case 'rainy':
				add(bg2);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end


		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
		}

		switch (songName) 
		{
			case 'boo':
				GameOverSubstate.characterName = 'bf-dead';
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
				GameOverSubstate.loopSoundName = 'Gameover';
				GameOverSubstate.endSoundName = 'gameOverEnd';
				gameOverZoom = 1.5;

				noCameraFollow = true;
				skipCountdown = true;

				remove(gfGroup);
				dad.alpha = 0;
				boyfriend.alpha = 0;    
				add(silence1);
				add(silence2);
				add(silence3);
				add(silence4);
			case 'boo-sticky':
				GameOverSubstate.characterName = 'sticky-death';
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
				GameOverSubstate.loopSoundName = 'Gameover';
				GameOverSubstate.endSoundName = 'gameOverEnd';
				gameOverZoom = 1.5;

				noCameraFollow = true;
				skipCountdown = true;

				remove(gfGroup);
				dad.alpha = 0;
				boyfriend.alpha = 0;    
				add(silence1);
				add(silence2);
				add(silence3);
				add(silence4);
			case 'tricks':
				GameOverSubstate.characterName = 'biggs-death';
				GameOverSubstate.deathSoundName = 'biggs_gameover_sfx';
				GameOverSubstate.loopSoundName = 'BiggsBuggs Gameover';
				GameOverSubstate.endSoundName = 'biggs-retry';
				gameOverZoom = 1.5;

				noCameraFollow = true;
				dad.visible = false;
				skipArrowStartTween = true;

				counter = new FlxSprite(390, 365);
				counter.frames = Paths.getSparrowAtlas('street/Text_Spweeked2', 'spweeked');
				counter.animation.addByPrefix('1', '1', 24, false);
				counter.animation.addByPrefix('2', '2', 24, false);
				counter.animation.addByPrefix('3', '3', 24, false);
				counter.animation.addByPrefix('4', '4', 24, false);
				counter.animation.addByPrefix('5', '5', 24, false);
				counter.animation.addByPrefix('6', '6', 24, false);
				counter.animation.addByPrefix('now', 'Now', 24, false);
				counter.scrollFactor.set();
				counter.updateHitbox();
				counter.alpha = 0;
				counter.animation.play('now');

				add(counter);
			case 'treats':
				GameOverSubstate.characterName = 'daisy-death';
				GameOverSubstate.deathSoundName = 'daisy_gameover';
				GameOverSubstate.loopSoundName = 'GhostJazz';
				GameOverSubstate.endSoundName = 'daisy-retry';
				gameOverZoom = 1.5;

				noCameraFollow = true;
				skipCountdown = true;
				//skipArrowStartTween = true;

				boyfriend.alpha = 0;
			case 'ghost-picnic':
				GameOverSubstate.characterName = 'boo-stage-death';
				GameOverSubstate.deathSoundName = 'boo_gameover_sfx';
				GameOverSubstate.loopSoundName = 'Gameover';
				GameOverSubstate.endSoundName = 'boo-retry';
				gameOverZoom = 1.5;

				noCameraFollow = true;
				skipCountdown = true;
				skipArrowStartTween = true;

				remove(gfGroup);
				remove(dadGroup);
				addCharacterToList("boo-stage", 0);

				spotlight.x += -190;
				dad.alpha = 0;
				mid.setColorTransform(0.5, 0.5, 0.5);
				fore.setColorTransform(0.5, 0.5, 0.5);
				boyfriendGroup.x += -112;
			case 'heart-of-gold':
				GameOverSubstate.characterName = 'boo-stage-death';
				GameOverSubstate.deathSoundName = 'boo_gameover_sfx';
				GameOverSubstate.loopSoundName = 'Gameover';
				GameOverSubstate.endSoundName = 'boo-retry';
				gameOverZoom = 1.5;

				noCameraFollow = true;
				skipCountdown = true;
				skipArrowStartTween = true;

				lyricalText = new FlxText(0, 0, FlxG.width, "You", 48);
				lyricalText.setFormat(Paths.font("times new roman bold.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFF00A1);
				lyricalText.borderSize = 2;
				lyricalText.cameras = [camHUD];
				lyricalText.screenCenter();
				if (ClientPrefs.downScroll) lyricalText.y += FlxG.height * 0.25;
				else lyricalText.y += FlxG.height * 0.3;
				lyricalText.alpha = 0;

				add(lyricalText);
				remove(gfGroup);

				ghostExtras = new Character(-640, -240, 'ghost-extras');
				ghostExtras.debugMode = true;
				mid.color = 0xFF7F7F7F;
				fore.color = 0xFF7F7F7F;
				ghostExtras.alpha = 0;
				add(ghostExtras);
				dadGroup.alpha = 0;
				spotlight.x += -90;
			case 'skeleton-passion':
				GameOverSubstate.characterName = 'boo-stage-death';
				GameOverSubstate.deathSoundName = 'boo_gameover_sfx';
				GameOverSubstate.loopSoundName = 'Gameover';
				GameOverSubstate.endSoundName = 'boo-retry'; 
				gameOverZoom = 1.5;

				noCameraFollow = true;
				skipCountdown = true;
				skipArrowStartTween = true;

				lyricalText = new FlxText(0, 0, FlxG.width, "Even though I'm gone I have a lot to live.", 48);
				lyricalText.setFormat(Paths.font("times new roman bold.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFF00A1);
				lyricalText.borderSize = 2;
				lyricalText.cameras = [camHUD];
				lyricalText.screenCenter();
				if (ClientPrefs.downScroll) lyricalText.y += FlxG.height * 0.25;
				else lyricalText.y += FlxG.height * 0.3;
				lyricalText.alpha = 0;

				add(lyricalText);
				remove(gfGroup);

				ghostExtras = new Character(-640, -240, 'ghost-extras');
				ghostExtras.debugMode = true;
				mid.color = 0xFF3D3D3D;
				fore.color = 0xFF3D3D3D;
				bg.color = 0xFF3D3D3D;
				dad.color = 0xFFFFC1FF;
				boyfriend.color = 0xFFB290BF;
				ghostExtras.color = 0xFFB290BF;
				defaultCamZoom = 1.6;
				add(ghostExtras);
				spotlight.alpha = 0;
			case 'meteorite-waltz':
				GameOverSubstate.characterName = 'boo-stage-death';
				GameOverSubstate.deathSoundName = 'boo_gameover_sfx';
				GameOverSubstate.loopSoundName = 'ComeOnSpookyRemix';
				GameOverSubstate.endSoundName = 'boo-retry';
				gameOverZoom = 1.5;

				noCameraFollow = true;
				skipCountdown = true;
				skipArrowStartTween = true;
				
				ofs = 10;

				daisySit = new Character(530, 640, 'daisy-sit');
				lunaSit = new Character(283, 652, 'luna-sit');

				shootingStar = new FlxSprite(405, 185);
				shootingStar.frames = Paths.getSparrowAtlas('beach/ShootingStar', 'goldendays');
				shootingStar.animation.addByPrefix('idle', 'ShootingStar0', 24, false);
				shootingStar.scale.set(0.5,0.5);
				shootingStar.scrollFactor.set();
				shootingStar.updateHitbox();
				shootingStar.alpha = 0;
				shootingStar.animation.play('idle');

				sparkles = new FlxSprite(405, 182);
				sparkles.frames = Paths.getSparrowAtlas('beach/Sparkles', 'goldendays');
				sparkles.animation.addByPrefix('idle', 'Sparkley0', 24, false);
				sparkles.scale.set(0.5,0.5);
				sparkles.scrollFactor.set();
				sparkles.updateHitbox();
				sparkles.animation.play('idle');
				sparkles.alpha = 0;

				add(daisySit);
				add(lunaSit);
				add(shootingStar);
				add(sparkles);
			case 'earth-s-sister':
				GameOverSubstate.characterName = 'boo-stage-death';
				GameOverSubstate.deathSoundName = 'boo_gameover_sfx';
				GameOverSubstate.loopSoundName = 'ComeOnSpookyRemix';
				GameOverSubstate.endSoundName = 'boo-retry';
				gameOverZoom = 1.5;

				skipCountdown = true;
				noCameraFollow = true;
				skipArrowStartTween = true;
				ofs = 10;

				coverScreen = new FlxSprite();
				coverScreen.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				coverScreen.cameras = [camHUD];
				coverScreen.screenCenter();

				lyricalText = new FlxText(0, 0, FlxG.width, "", 72);
				lyricalText.setFormat(Paths.font("times new roman bold.ttf"), 72, FlxColor.WHITE, CENTER);
				lyricalText.cameras = [camHUD];
				lyricalText.screenCenter();

				add(coverScreen);
				add(lyricalText);
			case 'it-s-okay':
				GameOverSubstate.characterName = 'boo-stage-death';
				GameOverSubstate.deathSoundName = 'boo_gameover_sfx';
				GameOverSubstate.loopSoundName = 'ComeOnSpookyRemix';
				GameOverSubstate.endSoundName = 'boo-retry';
				gameOverZoom = 1.5;

				skipCountdown = true;
				noCameraFollow = true;
				skipArrowStartTween = true;
				ofs = 10;

				dad.visible = false;
				boyfriend.alpha = 0;
				boyfriend.color = 0xFF000000;
				camHUD.alpha = 0;
			case 'tricky-or-treat':
				GameOverSubstate.characterName = 'boo-stage-death';
				GameOverSubstate.deathSoundName = 'boo_gameover_sfx';
				GameOverSubstate.loopSoundName = 'Gameover';
				GameOverSubstate.endSoundName = 'boo-retry'; 
				gameOverZoom = 1.5;
			case 'deadly-colors':
				GameOverSubstate.characterName = 'tossler-death';
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
				GameOverSubstate.loopSoundName = 'BiggsBuggs Gameover'; 
				GameOverSubstate.endSoundName = 'biggs-retry';
				gameOverZoom = 1.5;
			case 'caramel':
				GameOverSubstate.characterName = 'ava-death';
				GameOverSubstate.deathSoundName = 'ava_death_sfx';
				GameOverSubstate.loopSoundName = 'SSN_Gameover';
				GameOverSubstate.endSoundName = 'ava-retry';
				gameOverZoom = 1.5;

				skipCountdown = true;
				noCameraFollow = true;

				highBlackBar = new FlxSprite();
				highBlackBar.makeGraphic(FlxG.width, 100, FlxColor.BLACK);
				highBlackBar.cameras = [camHUD];
				highBlackBar.setPosition(0,-100);

				lowBlackBar = new FlxSprite();
				lowBlackBar.makeGraphic(FlxG.width, 100,FlxColor.BLACK);
				lowBlackBar.cameras = [camHUD];
				lowBlackBar.setPosition(0,FlxG.height);

				coverScreen = new FlxSprite();
				coverScreen.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				coverScreen.cameras = [camHUD];
				coverScreen.screenCenter();

				lyricalText = new FlxText(0, 0, FlxG.width, "AVA and HUNTER", 72);
				lyricalText.setFormat(Paths.font("times new roman bold.ttf"), 72, FlxColor.YELLOW, CENTER);
				lyricalText.cameras = [camHUD];
				lyricalText.y = FlxG.height * 0.88;

				add(blueLayer);
				add(highBlackBar);
				add(lowBlackBar);
				add(lyricalText);
				add(coverScreen);

				var cut1:FlxSprite = new FlxSprite();
				cut1.frames = Paths.getSparrowAtlas('basement/Cut 1', 'mooncode');
				cut1.animation.addByPrefix('idle', 'Cut 10', 24, false);
				cut1.scale.set(0.6,0.6);
				cut1.scrollFactor.set();
				cut1.updateHitbox();
				cut1.screenCenter();
				//cut1.animation.play('idle');

				var cut2:FlxSprite = new FlxSprite();
				cut2.frames = Paths.getSparrowAtlas('basement/Cut 2', 'mooncode');
				cut2.animation.addByPrefix('idle', 'Cut 20', 24, false);
				cut2.scale.set(0.6,0.6);
				cut2.scrollFactor.set();
				cut2.updateHitbox();
				cut2.screenCenter();

				var cut3:FlxSprite = new FlxSprite().loadGraphic(Paths.image('basement/Cut 3', 'mooncode'));
				cut3.scale.set(0.8,0.8);
				cut3.updateHitbox();
				cut3.screenCenter();

				var cut4:FlxSprite = new FlxSprite();
				cut4.frames = Paths.getSparrowAtlas('basement/Cut_4', 'mooncode');
				cut4.animation.addByPrefix('idle', 'Cut 40', 24, false, true);
				cut4.scale.set(0.8,0.8);
				cut4.scrollFactor.set();
				cut4.updateHitbox();
				cut4.screenCenter();
				cut4.x += -(FlxG.width * 0.25);

				var cut5:FlxSprite = new FlxSprite();
				cut5.frames = Paths.getSparrowAtlas('basement/Cut_4', 'mooncode');
				cut5.animation.addByPrefix('idle', 'Cut 40', 24, false);
				cut5.scale.set(0.8,0.8);
				cut5.scrollFactor.set();
				cut5.updateHitbox();
				cut5.screenCenter();
				cut5.x += FlxG.width * 0.25;

				var cut6:FlxSprite = new FlxSprite();
				cut6.frames = Paths.getSparrowAtlas('basement/Cut 5', 'mooncode');
				cut6.animation.addByPrefix('idle', 'Cut 50', 24, false);
				cut6.scale.set(0.6,0.6);
				cut6.scrollFactor.set();
				cut6.updateHitbox();
				cut6.screenCenter();

				cuts = new FlxSpriteGroup();

				cuts.add(cut1);
				cuts.add(cut2);
				cuts.add(cut3);
				cuts.add(cut4);
				cuts.add(cut5);
				cuts.add(cut6);

				cuts.forEach(function(cut:FlxSprite) {
					cut.alpha = 0;
					add(cut);
					cut.cameras = [camHUD];
				});

				cut1.alpha = 1;

				boyfriend.flipX = !boyfriend.flipX;
				boyfriend.x += -950;
				boyfriend.y += 820;
				dad.x += 800;
				dad.y += 60;
				gf.x += -330;
				gf.y += 350;
			case 'stumble-station':
				GameOverSubstate.characterName = 'boo-stage-death';
				GameOverSubstate.deathSoundName = 'boo_gameover_sfx';
				GameOverSubstate.loopSoundName = 'Gameover';
				GameOverSubstate.endSoundName = 'boo-retry';
				gameOverZoom = 1.5;

				skipCountdown = true;
			case 'satellite-picnic':
				GameOverSubstate.characterName = 'boo-stage-death';
				GameOverSubstate.deathSoundName = 'boo_gameover_sfx';
				GameOverSubstate.loopSoundName = 'Gameover';
				GameOverSubstate.endSoundName = 'boo-retry'; 
				gameOverZoom = 1.5;

				skipCountdown = true;
				ofs = 10;
			case 'poignant-comfort':
				GameOverSubstate.characterName = 'boo-stage-death';
				GameOverSubstate.deathSoundName = 'boo_gameover_sfx';
				GameOverSubstate.loopSoundName = 'Gameover';
				GameOverSubstate.endSoundName = 'boo-retry'; 
				gameOverZoom = 1.5;

				skipCountdown = true;
				noCameraFollow = true;
				skipArrowStartTween = true;

				dadGroup.alpha = 0;
				boyfriendGroup.alpha = 0;
				dad.alpha = 0;
				boyfriend.alpha = 0;
				boyfriend.setPosition(0, -180);

				coverScreen = new FlxSprite();
				coverScreen.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				coverScreen.cameras = [camHUD];
				coverScreen.screenCenter();
				coverScreen.alpha = 0;

				lyricalText = new FlxText(0, 0, FlxG.width, "Even though I'm gone I have a lot to live.", 48);
				lyricalText.setFormat(Paths.font("times new roman bold.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				lyricalText.borderSize = 2;
				lyricalText.cameras = [camHUD];
				lyricalText.setPosition(0, 0);
				lyricalText.alpha = 0;

				secondlyricalText = new FlxText(0, 0, FlxG.width, "", 80);
				secondlyricalText.setFormat(Paths.font("times new roman bold.ttf"), 80, FlxColor.GRAY, CENTER);
				secondlyricalText.cameras = [camHUD];
				secondlyricalText.screenCenter();
				secondlyricalText.alpha = 0;

				var cut:FlxSprite;
				cut = new FlxSprite(-1000, -1000);
				cut.makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
				cut.screenCenter();

				var cut1:BGSprite;
				cut1 = new BGSprite('world_travel/backgrounds/Intro_house', -800, -200, 1, 1, null, false, 'spweeked');
				cut1.updateHitbox();

				var cut2:BGSprite;
				cut2 = new BGSprite('world_travel/characters/booLook', 50, -180, 1, 1, ['booLook1 0', 'booLook5 0', 'boolook2 0', 'boolook3 0'], false, 'spweeked');
				cut2.scale.set(0.6,0.6);
				cut2.updateHitbox();

				FlxTween.tween(cut2.scale, { x: 1, y: 1 }, 0.5);

				var cut3:BGSprite;
				cut3 = new BGSprite('world_travel/backgrounds/skyDay', -700, -420, 1, 1, null, false, 'spweeked');
				cut3.scale.set(1.3,1.3);
				cut3.updateHitbox();

				var cut4:BGSprite;
				cut4 = new BGSprite('world_travel/backgrounds/trees', -1100, -350, 1, 1, null, false, 'spweeked');
				//cut4.scale.set(2,2);
				cut4.updateHitbox();

				var cut5:BGSprite;
				cut5 = new BGSprite('world_travel/backgrounds/Floor1', -800, -20, 1, 1, null, false, 'spweeked');
				cut5.scale.set(2.5,2.5);
				cut5.updateHitbox();

				var cut6:BGSprite;
				cut6 = new BGSprite('world_travel/characters/preBoo', -350, -100, 1, 1, ['booRegSprite0', 'booRegSprite2 0', 'booRegSprite4 0', 'booRegSprite5 0', 'booRegSprite6 0'], false, 'spweeked');
				cut6.scale.set(0.8,0.8);
				cut6.updateHitbox();

				var cut7:FlxSprite;
				cut7 = new FlxSprite(-1000, -1000);
				cut7.makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
				cut7.screenCenter();

				var cut8:BGSprite;
				cut8 = new BGSprite('world_travel/drop', -375, -350, 1, 1, ['DropEffect0'], false, 'spweeked');
				cut8.scale.set(1.4,1.4);
				cut8.updateHitbox();

				var cut9:BGSprite;
				cut9 = new BGSprite('world_travel/cinematic_scenes/Scene 1/Scene1_1', -650, -290, 1, 1, ['Scene1_10'], true, 'spweeked');
				cut9.scale.set(1.4,1.4);
				cut9.updateHitbox();

				var cut10:BGSprite;
				cut10 = new BGSprite('world_travel/cinematic_scenes/Scene 1/Scene1_2', -260, -310, 1, 1, ['Scene1_20'], false, 'spweeked');
				cut10.scale.set(1.67,1.67);
				cut10.updateHitbox();

				var cut11:BGSprite;
				cut11 = new BGSprite('world_travel/cinematic_scenes/Scene 1/Scene1_3', -575, -375, 1, 1, ['Scene1_30'], true, 'spweeked');
				cut11.scale.set(1.4,1.4);
				cut11.updateHitbox();

				var cut12:BGSprite;
				cut12 = new BGSprite('world_travel/cinematic_scenes/Scene 1/Scene1_4', -530, -375, 1, 1, ['Scene1_40'], true, 'spweeked');
				cut12.scale.set(1.4,1.4);
				cut12.updateHitbox();

				var cut13:BGSprite;
				cut13 = new BGSprite('world_travel/cinematic_scenes/Scene 1/Scene1_5', -525, -325, 1, 1, ['Scene1_50'], true, 'spweeked');
				cut13.scale.set(1.4,1.4);
				cut13.updateHitbox();

				var cut14:BGSprite;
				cut14 = new BGSprite('world_travel/cinematic_scenes/Scene 1/Scene1_6', -370, -270, 1, 1, ['Scene1_60'], true, 'spweeked');
				cut14.scale.set(1.83,1.83);
				cut14.updateHitbox();

				var cut15:BGSprite;
				cut15 = new BGSprite('world_travel/cinematic_scenes/Scene 1/Scene1_7', -368, -270, 1, 1, ['Scene1_70'], true, 'spweeked');
				cut15.scale.set(1.83,1.83);
				cut15.updateHitbox();

				var cut16:BGSprite;
				cut16 = new BGSprite('world_travel/cinematic_scenes/Scene 1/Scene1_8', -700, -380, 1, 1, ['Scene1_80'], false, 'spweeked');
				cut16.scale.set(1.8,1.8);
				cut16.updateHitbox();

				var cut17:BGSprite;
				cut17 = new BGSprite('world_travel/cinematic_scenes/Scene 2/Scene2_3', -700, -400, 1, 1, ['Scene2_30'], true, 'spweeked');
				cut17.scale.set(1.8,1.8);
				cut17.updateHitbox();

				var cut18:BGSprite;
				cut18 = new BGSprite('world_travel/cinematic_scenes/Scene 2/Scene2_1', -700, -400, 1, 1, ['Scene2_10'], true, 'spweeked');
				cut18.scale.set(1.8,1.8);
				cut18.updateHitbox();

				var cut19:BGSprite;
				cut19 = new BGSprite('world_travel/cinematic_scenes/Scene 2/Scene2_2', -700, -400, 1, 1, ['Scene2_20'], true, 'spweeked');
				cut19.scale.set(1.8,1.8);
				cut19.updateHitbox();

				var cut20:BGSprite;
				cut20 = new BGSprite('world_travel/cinematic_scenes/Scene 2/Scene2_4', -700, -400, 1, 1, ['Scene2_40'], true, 'spweeked');
				cut20.scale.set(1.8,1.8);
				cut20.updateHitbox();

				var cut21:BGSprite;
				cut21 = new BGSprite('world_travel/cinematic_scenes/Scene 2/Scene2_5', -700, -400, 1, 1, ['Scene2_50'], true, 'spweeked');
				cut21.scale.set(1.8,1.8);
				cut21.updateHitbox();

				var cut22:BGSprite;
				cut22 = new BGSprite('world_travel/cinematic_scenes/Scene 2/Scene2_6', -699, -402, 1, 1, ['Scene2_60'], true, 'spweeked');
				cut22.scale.set(1.8,1.8);
				cut22.updateHitbox();

				var cut23:BGSprite;
				cut23 = new BGSprite('world_travel/cinematic_scenes/Scene 2/Scene2_8', -600, -270, 1, 1, ['Scene2_80'], true, 'spweeked');
				cut23.scale.set(1.8,1.8);
				cut23.updateHitbox();

				var cut24:BGSprite;
				cut24 = new BGSprite('world_travel/cinematic_scenes/Scene 2/Scene2_9', -150, -325, 1, 1, ['Scene2_90'], true, 'spweeked');
				cut24.scale.set(1.6,1.6);
				cut24.updateHitbox();

				var cut25:BGSprite;
				cut25 = new BGSprite('world_travel/cinematic_scenes/Scene 2/Scene2_10', -316, -325, 1, 1, ['Scene2_100'], true, 'spweeked');
				cut25.scale.set(1.6,1.6);
				cut25.updateHitbox();

				var cut26:BGSprite;
				cut26 = new BGSprite('world_travel/cinematic_scenes/Scene 2/Scene2_12', -620, -250, 1, 1, ['Scene2_12_idle_0', 'Scene2_120'], true, 'spweeked');
				cut26.scale.set(1.7,1.7);
				cut26.updateHitbox();

				var cut27:BGSprite;
				cut27 = new BGSprite('world_travel/backgrounds/skySunSet', -700, -450, 1, 1, null, false, 'spweeked');
				cut27.scale.set(1.3,1.3);
				cut27.updateHitbox();
				cut27.color = 0xFFFEE8C6;

				var cut28:BGSprite;
				cut28 = new BGSprite('world_travel/backgrounds/trees', -1100, -330, 1, 1, null, false, 'spweeked');
				cut28.updateHitbox();
				cut28.color = 0xFFFEE8C6;

				var cut29:BGSprite;
				cut29 = new BGSprite('world_travel/backgrounds/town', -1350, -630, 1, 1, null, false, 'spweeked');
				cut29.updateHitbox();
				cut29.color = 0xFFFEE8C6;

				var cut30:BGSprite;
				cut30 = new BGSprite('world_travel/backgrounds/Floor2', -800, 0, 1, 1, null, false, 'spweeked');
				cut30.scale.set(2.5,2.5);
				cut30.updateHitbox();
				cut30.color = 0xFF7D656E;

				var cut31:BGSprite;
				cut31 = new BGSprite('world_travel/backgrounds/skyNight', -700, -380, 1, 1, ['skyNight0'], false, 'spweeked');
				//cut31.scale.set(1.5,1.5);
				cut31.updateHitbox();
				cut31.animation.play('skyNight0');

				var cut32:BGSprite;
				cut32 = new BGSprite('world_travel/cinematic_scenes/Con1', -300, -250, 1, 1, ['Con10'], true, 'spweeked');
				//cut32.scale.set(1.5,1.5);
				cut32.updateHitbox();

				var cut33:BGSprite;
				cut33 = new BGSprite('world_travel/cinematic_scenes/Con2', -300, -250, 1, 1, ['Con20'], true, 'spweeked');
				//cut33.scale.set(1.5,1.5);
				cut33.updateHitbox();

				var cut34:BGSprite;
				cut34 = new BGSprite('world_travel/cinematic_scenes/Con3', -300, -250, 1, 1, ['Con30'], true, 'spweeked');
				//cut34.scale.set(1.5,1.5);
				cut34.updateHitbox();

				var cut35:BGSprite;
				cut35 = new BGSprite('world_travel/backgrounds/neighborhood2', -1150, -400, 1, 1, null, false, 'spweeked');
				//cut35.scale.set(2,2);
				cut35.updateHitbox();

				var cut36:BGSprite;
				cut36 = new BGSprite('world_travel/backgrounds/neighborhood', -1150, -400, 1, 1, null, false, 'spweeked');
				cut36.angle += -30;
				//cut36.scale.set(2,2);
				cut36.updateHitbox();

				var cut37:BGSprite;
				cut37 = new BGSprite('world_travel/backgrounds/Floor3', -750, 0, 1, 1, null, false, 'spweeked');
				cut37.scale.set(2.5,2.5);
				cut37.updateHitbox();

				var cut38:BGSprite;
				cut38 = new BGSprite('world_travel/backgrounds/HauntedHouse', -700, -350, 1, 1, null, false, 'spweeked');
				cut38.scale.set(1.05,1.05);
				cut38.updateHitbox();

				var cut39:BGSprite;
				cut39 = new BGSprite('world_travel/cinematic_scenes/Scene 3/Scene3_1', -200, -280, 1, 1, ['Scene3_1_idle_0','Scene3_10'], true, 'spweeked');
				cut39.scale.set(1.8,1.8);
				cut39.updateHitbox();

				var cut40:BGSprite;
				cut40 = new BGSprite('world_travel/cinematic_scenes/Scene 3/Scene3_2', -350, -250, 1, 1, ['Scene3_20'], true, 'spweeked');
				cut40.scale.set(1.8,1.8);
				cut40.updateHitbox();

				var cut41:BGSprite;
				cut41 = new BGSprite('world_travel/cinematic_scenes/Scene 3/Scene3_3', -740, -400, 1, 1, ['Scene3_30'], true, 'spweeked');
				cut41.scale.set(1.8,1.8);
				cut41.updateHitbox();

				var cut42:BGSprite;
				cut42 = new BGSprite('world_travel/cinematic_scenes/Scene 3/Scene3_4', -600, -300, 1, 1, ['Scene3_40'], true, 'spweeked');
				cut42.scale.set(1.75,1.75);
				cut42.updateHitbox();

				var cut43:BGSprite;
				cut43 = new BGSprite('world_travel/cinematic_scenes/Scene 3/Scene3_5', -500, -250, 1, 1, ['Scene3_50'], true, 'spweeked');
				cut43.scale.set(1.75,1.75);
				cut43.updateHitbox();

				var cut44:BGSprite;
				cut44 = new BGSprite('world_travel/cinematic_scenes/Scene 3/Scene3_6', -850, -550, 1, 1, ['Scene3_60'], true, 'spweeked');
				cut44.scale.set(2.3,2.3);
				cut44.updateHitbox();

				var cut45:BGSprite;
				cut45 = new BGSprite('world_travel/cinematic_scenes/Scene 3/Scene3_7', -300, -225, 1, 1, ['Scene3_70'], true, 'spweeked');
				cut45.scale.set(1.7,1.7);
				cut45.updateHitbox();

				var cut46:BGSprite;
				cut46 = new BGSprite('world_travel/cinematic_scenes/Scene 3/Scene3_8', -300, -225, 1, 1, ['Scene3_80'], true, 'spweeked');
				cut46.scale.set(1.7,1.7);
				cut46.updateHitbox();

				var cut47:BGSprite;
				cut47 = new BGSprite('world_travel/cinematic_scenes/Scene 3/Scene3_9', -300, -240, 1, 1, ['Scene3_90'], true, 'spweeked');
				//cut47.scale.set(0.9,1.0);
				cut47.updateHitbox();

				var cut48:BGSprite;
				cut48 = new BGSprite('world_travel/cinematic_scenes/Scene 3/Scene3_10', -300, -225, 1, 1, ['Scene3_100'], true, 'spweeked');
				cut48.scale.set(1.8,1.8);
				cut48.updateHitbox();

				var cut49:BGSprite;
				cut49 = new BGSprite('world_travel/cinematic_scenes/Scene 3/Scene3_Last', -350, -275, 1, 1, ['Scene3_Last0'], false, 'spweeked');
				cut49.scale.set(1.3,1.3);
				cut49.updateHitbox();

				var cut50:BGSprite;
				cut50 = new BGSprite('world_travel/backgrounds/trees', -1100, -350, 1, 1, null, false, 'spweeked');
				//cut50.scale.set(2,2);
				cut50.updateHitbox();

				var cut51:BGSprite;
				cut51 = new BGSprite('world_travel/backgrounds/Floor1', -800, -20, 1, 1, null, false, 'spweeked');
				cut51.scale.set(2.5,2.5);
				cut51.updateHitbox();

				var cut52:BGSprite;
				cut52 = new BGSprite('world_travel/characters/preBoo', -350, -100, 1, 1, ['booRegSprite0', 'booRegSprite2 0', 'booRegSprite4 0', 'booRegSprite5 0', 'booRegSprite6 0'], false, 'spweeked');
				cut52.scale.set(0.8,0.8);
				cut52.updateHitbox();
				cut52.color = 0xFFFEE8C6;

				var cut53:FlxText;
				cut53 = new FlxText(0, 0, FlxG.width * 0.2, "La", 80);
				cut53.setFormat(Paths.font("times new roman bold.ttf"), 80, FlxColor.GRAY, CENTER);
				cut53.cameras = [camHUD];
				cut53.setPosition(FlxG.width * -0.47, FlxG.height * -0.3);
				cut53.alpha = 0;

				var cut54:FlxText;
				cut54 = new FlxText(0, 0, FlxG.width * 0.2, "La", 80);
				cut54.setFormat(Paths.font("times new roman bold.ttf"), 80, FlxColor.GRAY, CENTER);
				cut54.cameras = [camHUD];
				cut54.setPosition(FlxG.width * -0.26, FlxG.height * -0.09);
				cut54.alpha = 0;

				var cut55:FlxText;
				cut55 = new FlxText(0, 0, FlxG.width * 0.2, "La", 80);
				cut55.setFormat(Paths.font("times new roman bold.ttf"), 80, FlxColor.GRAY, CENTER);
				cut55.cameras = [camHUD];
				cut55.setPosition(FlxG.width * -0.05, FlxG.height * 0.12);
				cut55.alpha = 0;

				var cut56:FlxText;
				cut56 = new FlxText(0, 0, FlxG.width * 0.2, "La", 80);
				cut56.setFormat(Paths.font("times new roman bold.ttf"), 80, FlxColor.GRAY, CENTER);
				cut56.cameras = [camHUD];
				cut56.setPosition(FlxG.width * 0.18, FlxG.height * 0.33);
				cut56.alpha = 0;

				cuts = new FlxSpriteGroup();

				cuts.add(cut);
				cuts.add(cut1);
				cuts.add(cut2);
				cuts.add(cut3);
				cuts.add(cut4);
				cuts.add(cut5);
				cuts.add(cut6);
				cuts.add(cut7);
				cuts.add(cut8);
				cuts.add(cut9);
				cuts.add(cut10);
				cuts.add(cut11);
				cuts.add(cut12);
				cuts.add(cut13);
				cuts.add(cut14);
				cuts.add(cut15);
				cuts.add(cut16);
				cuts.add(cut17);
				cuts.add(cut18);
				cuts.add(cut19);
				cuts.add(cut20);
				cuts.add(cut21);
				cuts.add(cut22);
				cuts.add(cut23);
				cuts.add(cut24);
				cuts.add(cut25);
				cuts.add(cut26);
				cuts.add(cut27);
				cuts.add(cut28);
				cuts.add(cut29);
				cuts.add(cut30);
				cuts.add(cut31);
				cuts.add(cut32);
				cuts.add(cut33);
				cuts.add(cut34);
				cuts.add(cut35);
				cuts.add(cut36);
				cuts.add(cut37);
				cuts.add(cut38);
				cuts.add(cut39);
				cuts.add(cut40);
				cuts.add(cut41);
				cuts.add(cut42);
				cuts.add(cut43);
				cuts.add(cut44);
				cuts.add(cut45);
				cuts.add(cut46);
				cuts.add(cut47);
				cuts.add(cut48);
				cuts.add(cut49);
				cuts.add(cut50);
				cuts.add(cut51);
				cuts.add(cut52);

				cuts.forEach(function(cut:FlxSprite) {
					cut.alpha = 0;
					add(cut);
				});

				add(lyricalText);
				add(coverScreen);
				add(secondlyricalText);

				add(cut53);
				add(cut54);
				add(cut55);
				add(cut56);
				cuts.add(cut53);
				cuts.add(cut54);
				cuts.add(cut55);
				cuts.add(cut56);

				cuts.members[0].alpha = 1;
				cuts.members[1].alpha = 1;
				cuts.members[2].alpha = 1;
		}

		var songName:String = Paths.formatToSongPath(SONG.song);
		switch (songName) {
			case 'boo': songname = 'BOO';
			case 'boo-sticky': songname = 'BOO Sticky';
			case 'caramel': songname = 'Caramel';
			case 'deadly-colors': songname = 'Deadly Colors';
			case 'earth-s-sister': songname = "Earth's Sister";
			case 'ghost-picnic': songname = 'Ghost Picnic';
			case 'heart-of-gold': songname = 'Heart Of Gold';
			case 'it-s-okay': songname = "It's Okay";
			case 'meteorite-waltz': songname = 'Meteorite Waltz';
			case 'satellite-picnic': songname = 'Satellite Picnic';
			case 'skeleton-passion': songname = 'Skeleton Passion';
			case 'stumble-station': songname = 'Stumble Station';
			case 'treats': songname = 'Treats';
			case 'tricks': songname = 'Tricks';
			case 'tricky-or-treat': songname = 'Tricky Or Treat';
			case 'poignant-comfort': songname = 'Poignant Comfort';
		}
		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = songname;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();

		bookmark = new FlxSprite(-300, 100).loadGraphic(Paths.image('Bookmark', 'shared'));
		bookmark.cameras = [camOther];

		nowPlaying = new FlxText(-290, 105, 280, "Now Playing:", 32);
		nowPlaying.setFormat(Paths.font("times new roman.ttf"), 32, FlxColor.WHITE, LEFT);
		nowPlaying.cameras = [camOther];

		nameOfSong = new FlxText(-290, 145, 280, songname, 32);
		nameOfSong.setFormat(Paths.font("times new roman.ttf"), 32, FlxColor.WHITE, LEFT);
		nameOfSong.cameras = [camOther];

		var hasAColor:Bool = false;
		var weekInfo:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[storyWeek]);
		for (i in 0...weekInfo.songs.length)
		{
			if (weekInfo.songs[i][0].toLowerCase() == SONG.song.toLowerCase())
			{
				hasAColor = true;
				trace(hasAColor);
				var fontColors:Array<Int> = weekInfo.songs[i][2];
				if(fontColors == null || fontColors.length < 3)
				{
					fontColors = [0, 0, 0];
				}
				
				var fillColor:FlxColor = FlxColor.fromRGB(fontColors[0], fontColors[1], fontColors[2]);

				timeBar.createFilledBar(FlxColor.GRAY, fillColor);
				nameOfSong.setFormat(Paths.font("times new roman.ttf"), 32, fillColor, LEFT);

				//timeBarBG.color = borderColor;
				//return;
			}
		}
		
		if (!hasAColor) {
			var fileToCheck:String = 'assets/weeks/Extras.json';
			var week:WeekFile = WeekData.getWeekFile(fileToCheck);
			trace(week);
			var weekFile:WeekData = new WeekData(week, 'Extras');
			for (song in weekFile.songs)
			{
				if (SONG.song.toLowerCase() == song[0]) {
					trace('passed2');
					var fontColors:Array<Int> = song[2];
					if(fontColors == null || fontColors.length < 3)
					{
						fontColors = [0, 0, 0];
					}
					
					var fillColor:FlxColor = FlxColor.fromRGB(fontColors[0], fontColors[1], fontColors[2]);

					timeBar.createFilledBar(FlxColor.GRAY, fillColor);
					nameOfSong.setFormat(Paths.font("times new roman.ttf"), 32, fillColor, LEFT);
				}
			}
		}
		
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		rating = new TweeningText(0, FlxG.height * 0.1, FlxG.width, "fff", 20);
		rating.setFormat(Paths.font("PressStart2P.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rating.scrollFactor.set();
		rating.alpha = 0;
		rating.borderSize = 2;
		//add(rating);

		scoreGain = new TweeningText(0, FlxG.height * 0.1 + 20, FlxG.width, "", 15);
		scoreGain.setFormat(Paths.font("PressStart2P.ttf"), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreGain.scrollFactor.set();
		scoreGain.alpha = 0;
		scoreGain.borderSize = 2;

		sumScoreTxt = new TweeningText(0, FlxG.height * 0.1 + 40, FlxG.width, "", 20);
		sumScoreTxt.setFormat(Paths.font("PressStart2P.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		sumScoreTxt.scrollFactor.set();
		sumScoreTxt.alpha = 0;
		sumScoreTxt.borderSize = 2;

		/*
		var black:FlxText = new TweeningText(0, 500, FlxG.width, "SaltedSpork", 20);
		black.setFormat(Paths.font("PressStart2P.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		black.scrollFactor.set();
		black.text = "blabla";
		black.screenCenter();
		add(black);
		*/


		if(ClientPrefs.downScroll) 
		{
			rating.y = FlxG.height * 0.82;
			scoreGain.y = FlxG.height * 0.82 + 20;
			sumScoreTxt.y = FlxG.height * 0.82 + 40;
		}

		if(ClientPrefs.middleScroll) 
		{
			if(ClientPrefs.downScroll) 
			{
				rating.y = FlxG.height * 0.88;
				scoreGain.y = FlxG.height * 0.88 + 20;
				sumScoreTxt.y = FlxG.height * 0.88 + 40;
			} else {
				rating.y = FlxG.height * 0.05;
				scoreGain.y = FlxG.height * 0.05 + 20;
				sumScoreTxt.y = FlxG.height * 0.05 + 40;
			}
			rating.x = FlxG.width * 0.42;
			scoreGain.x = FlxG.width * 0.42;
			sumScoreTxt.x = FlxG.width * 0.42;
		}

		comboRatingGroup = new FlxTypedGroup<TweeningText>();
		comboRatingGroup.add(rating);
		comboRatingGroup.add(scoreGain);
		comboRatingGroup.add(sumScoreTxt);
		add(comboRatingGroup);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		if (songName == 'heart-of-gold' || songName == 'skeleton-passion') {
			extraGhostSONG = Song.loadFromJson('ghostExtra-' + SONG.song, SONG.song);
			('extra voices unlocked');
		}

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 14);
		scoreTxt.setFormat(Paths.font("PressStart2P.ttf"), 14, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		//transGradient.cameras = [camHUD];
		comboRatingGroup.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		if ((fromMenu == 1 || isStoryMode) && !seenCutscene)
		{
			switch (daSong)
			{
				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'ugh' | 'guns' | 'stress':
					tankIntro();
				case 'ghost-picnic':
					startVideo('WinterCut1.mp4');
				case 'heart-of-gold':
					startVideo('WinterCut2.mp4');
				case 'tricks':
					startVideo('Spweeked2_Cut.mp4');
				//case 'tricky-or-treat':
				//	startVideo('TrickyCut.mp4');
				case 'satellite-picnic':
					picnicIntro();
				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		trace(ClientPrefs.pauseMusic);
		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, songname + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);

		super.create();

		Paths.clearUnusedMemory();
		
		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		CustomFadeTransition.nextCamera = CustomAnimatedTransition.nextCamera = camOther;
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	var pauseGrp:FlxTypedGroup<FlxSprite>;

	public function startVideo(name:String, ?weekEnd:Bool = false, ?passwordEnd:Bool = false):Void
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;
	
		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		camGame.visible = false;
	
		var video:VideoSprite = new VideoSprite();
		video.cameras = [camOther];
		video.antialiasing = ClientPrefs.globalAntialiasing;
		add(video);

		initializePauseGrp();
		

		video.playVideo(filepath);
		video.openingCallback = () ->
		{
			video.setGraphicSize(FlxG.width, FlxG.height);
			video.updateHitbox();

			camGame.visible = true;

			canPause = false;
		}

		video.pauseCallback = () ->
		{
			if (pauseGrp != null)
				pauseGrp.visible = !pauseGrp.visible;
		}

		if (passwordEnd) {
			video.finishCallback = () ->
			{
				if (pauseGrp != null) remove(pauseGrp);
				MusicBeatState.switchAnimatedState(new PasswordState());
				FlxG.sound.playMusic(Paths.music('HungryMenuMusic'));
				FlxG.sound.music.time = 9150;
				return;
			}
		} else if (weekEnd){
			video.finishCallback = () ->
			{
				if (pauseGrp != null) remove(pauseGrp);
				FlxG.switchState(new SpookEndingState());
				return;
			}
		} else {
			video.finishCallback = () ->
			{
				if (pauseGrp != null) remove(pauseGrp);
				startAndEnd();

				var pauseBuffer = new FlxTimer();
				pauseBuffer.start(1, (x) -> {
					canPause = true;
					x.destroy();
				});
				return;
			}
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		initializePauseGrp();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	function initializePauseGrp():Void
	{
		pauseGrp = new FlxTypedGroup<FlxSprite>();
		pauseGrp.cameras = [camOther];
		pauseGrp.visible = false;
		add(pauseGrp);

		for (i in 1...5)
		{
			var pauseSprite:FlxSprite = new FlxSprite();
			if (i < 3)
			{
				pauseSprite.makeGraphic(24, 74, FlxColor.BLACK);
				pauseSprite.setPosition(FlxG.width - (i * 42) - 12, 48);
			}
			else
			{
				pauseSprite.makeGraphic(20, 70);
				pauseSprite.setPosition(FlxG.width - (Std.int(i/2) * 42) - 10, 50);
			}
			pauseGrp.add(pauseSprite);
		}
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function tankIntro()
	{
		var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = ClientPrefs.globalAntialiasing;
		addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		var tankman2:FlxSprite = new FlxSprite(16, 312);
		tankman2.antialiasing = ClientPrefs.globalAntialiasing;
		tankman2.alpha = 0.000001;
		cutsceneHandler.push(tankman2);
		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfDance);
		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
		gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfCutscene);
		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
		picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(picoCutscene);
		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(boyfriendCutscene);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		switch(songName)
		{
			case 'ugh':
				cutsceneHandler.endTime = 12;
				cutsceneHandler.music = 'DISTORTO';
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');

				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;

				// Well well well, what do we got here?
				cutsceneHandler.timer(0.1, function()
				{
					wellWellWell.play(true);
				});

				// Move camera to BF
				cutsceneHandler.timer(3, function()
				{
					camFollow.x += 750;
					camFollow.y += 100;
				});

				// Beep!
				cutsceneHandler.timer(4.5, function()
				{
					boyfriend.playAnim('singUP', true);
					boyfriend.specialAnim = true;
					FlxG.sound.play(Paths.sound('bfBeep'));
				});

				// Move camera to Tankman
				cutsceneHandler.timer(6, function()
				{
					camFollow.x -= 750;
					camFollow.y -= 100;

					// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
					tankman.animation.play('killYou', true);
					FlxG.sound.play(Paths.sound('killYou'));
				});

			case 'guns':
				cutsceneHandler.endTime = 11.5;
				cutsceneHandler.music = 'DISTORTO';
				tankman.x += 40;
				tankman.y += 10;
				precacheList.set('tankSong2', 'sound');

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				cutsceneHandler.onStart = function()
				{
					tightBars.play(true);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
				};

				cutsceneHandler.timer(4, function()
				{
					gf.playAnim('sad', true);
					gf.animation.finishCallback = function(name:String)
					{
						gf.playAnim('sad', true);
					};
				});

			case 'stress':
				cutsceneHandler.endTime = 35.5;
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.y += 100;
				});
				precacheList.set('stressCutscene', 'sound');

				tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');
				addBehindDad(tankman2);

				if (!ClientPrefs.lowQuality)
				{
					gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
					gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
					gfDance.animation.play('dance', true);
					addBehindGF(gfDance);
				}

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				gfCutscene.animation.play('dieBitch', true);
				gfCutscene.animation.pause();
				addBehindGF(gfCutscene);
				if (!ClientPrefs.lowQuality)
				{
					gfCutscene.alpha = 0.00001;
				}

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				addBehindGF(picoCutscene);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();
				addBehindBF(boyfriendCutscene);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;
				var zoomBack:Void->Void = function()
				{
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;
					if (calledTimes > 1)
					{
						foregroundSprites.forEach(function(spr:BGSprite)
						{
							spr.y -= 100;
						});
					}
				}

				cutsceneHandler.onStart = function()
				{
					cutsceneSnd.play(true);
				};

				cutsceneHandler.timer(15.2, function()
				{
					FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if(name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);

							boyfriendGroup.alpha = 1;
							boyfriendCutscene.visible = false;
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if(name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
								}
							};

							picoCutscene.animation.finishCallback = function(name:String)
							{
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};
							gfCutscene.animation.finishCallback = null;
						}
					};
				});

				cutsceneHandler.timer(17.5, function()
				{
					zoomBack();
				});

				cutsceneHandler.timer(19.5, function()
				{
					tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman2.animation.play('lookWhoItIs', true);
					tankman2.alpha = 1;
					tankman.visible = false;
				});

				cutsceneHandler.timer(20, function()
				{
					camFollow.set(dad.x + 500, dad.y + 170);
				});

				cutsceneHandler.timer(31.2, function()
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
				});

				cutsceneHandler.timer(32.2, function()
				{
					zoomBack();
				});
		}
	}

	function picnicIntro() {
		initializeArrowAndCam();
		inCutscene = true;
		FlxG.sound.play(Paths.sound('panicPhone', 'mooncode'), 1.0);
		camHUD.alpha = 0;
		boyfriend.alpha = 0;
		boyfriend.playAnim('INTRO1',true);
		dad.playAnim('SIT', true);

		dad.animation.finishCallback = function(name:String)
		{
			switch (name)
			{
				case 'SHOCK1':
					dad.playAnim('SHOCK2', true);
				case 'SHOCK2':
					dad.playAnim('SHOCK3', true);
				case 'SHOCK3':
					dad.playAnim('idle', true);
					FlxTween.tween(camHUD, { alpha: 1 }, 1.6);
					startCountdown();
			}
		}

		boyfriend.animation.finishCallback = function(name:String)
		{
			switch (name)
			{
				case 'INTRO1':
					boyfriend.playAnim('INTRO2',true);
				case 'INTRO2':
					boyfriend.playAnim('INTRO3',true);
					dad.playAnim('SHOCK1', true);
				case 'INTRO3':
					boyfriend.playAnim('idle',true);
			}
		}

		new FlxTimer().start(1.2, function(tmr:FlxTimer) {
			boyfriend.playAnim('INTRO1',true);
			FlxTween.tween(boyfriend, { alpha: 1 }, 0.8);
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			initializeArrowAndCam();

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;


			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.cameras = [camHUD];
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						insert(members.indexOf(notes), countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.cameras = [camHUD];
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						insert(members.indexOf(notes), countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.cameras = [camHUD];
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						insert(members.indexOf(notes), countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.middleScroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	function initializeArrowAndCam():Void {
		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		var songName:String = Paths.formatToSongPath(SONG.song);
		switch(songName)
		{
			case 'poignant-comfort':
				iconP1.visible = false;
				iconP2.visible = false;
				healthBarBG.visible = false;
				healthBar.visible = false;
				scoreTxt.visible = false;

				timeBar.visible = false;
				timeBarBG.visible = false;
				timeTxt.visible = false;

				rating.visible = false;
				scoreGain.visible = false;
				sumScoreTxt.visible = false;

				for (i in 0...opponentStrums.length) {
					opponentStrums.members[i].x += -3000;
				}
			case 'ghost-picnic':
				for (i in 0...opponentStrums.length) {
					opponentStrums.members[i].x += -3000;
				}

				iconP2.alpha = 0;

				camPos.x = -160;
				camPos.y = -126;
				snapCamFollowToPos(-160, -126);
			case 'heart-of-gold':
				for (i in 0...opponentStrums.length) {
					opponentStrums.members[i].x += -3000;
				}

				iconP2.alpha = 0;

				camPos.x = 0;
				camPos.y = -126;
				snapCamFollowToPos(0, -126);
			case 'skeleton-passion':
				for (i in 0...opponentStrums.length) {
					opponentStrums.members[i].x += -3000;
				}

				camPos.x = -300;
				camPos.y = -26;
				snapCamFollowToPos(-300, -26);
			case 'meteorite-waltz':
				for (i in 0...opponentStrums.length) {
					opponentStrums.members[i].x += -3000;
				}

				camPos.x = 530;
				camPos.y = 630;
				snapCamFollowToPos(530, 630);
			case 'earth-s-sister':
				iconP1.visible = false;
				iconP2.visible = false;
				healthBarBG.visible = false;
				healthBar.visible = false;
				scoreTxt.visible = false;

				for (i in 0...opponentStrums.length) {
					opponentStrums.members[i].x += -3000;
				}

				camPos.x = 530;
				camPos.y = 600;
				snapCamFollowToPos(530, 600);
			case 'it-s-okay':
				for (i in 0...opponentStrums.length) {
					opponentStrums.members[i].x += -3000;
				}

				iconP2.alpha = 0;

				camPos.x = 630;
				camPos.y = 680;
				snapCamFollowToPos(630, 680);
			case 'satellite-picnic':
				camPos.x = 630;
				camPos.y = 680;
				snapCamFollowToPos(630, 680);
			case 'deadly-colors':
				camPos.x = 630;
				camPos.y = 650;
				snapCamFollowToPos(630, 650);
			case 'treats':
				iconP1.alpha = 0;

				for (i in 0...opponentStrums.length) {
					opponentStrums.members[i].x += -3000;
				}

				if (!ClientPrefs.middleScroll) {
					for (i in 0...playerStrums.length) {
						playerStrums.members[i].x += -650;
					}
				}

				camPos.x = 830;
				camPos.y = 800;
				snapCamFollowToPos(830, 800);
			case 'tricks':
				iconP1.visible = false;
				iconP2.visible = false;
				healthBarBG.visible = false;
				healthBar.visible = false;
				scoreTxt.visible = false;

				for (i in 0...unspawnNotes.length) {
					unspawnNotes[i].missHealth = 0.25;
					unspawnNotes[i].hitHealth = 0.25;
				}

				for (i in 0...playerStrums.length) {
					playerStrums.members[i].x = FlxG.width * 0.34;
					playerStrums.members[i].y = FlxG.height * 0.32;
					playerStrums.members[i].alpha = 0;
				}

				for (i in 0...opponentStrums.length) {
					opponentStrums.members[i].x += -3000;
				}

				camPos.x = 600;
				camPos.y = 650;
				snapCamFollowToPos(600, 650);
			case 'stumble-station':
				camPos.x = 400;
				camPos.y = 900;
				snapCamFollowToPos(400, 900);
			case 'caramel':
				iconP1.visible = false;
				iconP2.visible = false;
				healthBarBG.visible = false;
				healthBar.visible = false;
				scoreTxt.visible = false;

				timeBar.visible = false;
				timeBarBG.visible = false;
				timeTxt.visible = false;

				if (!ClientPrefs.middleScroll) {
					for (i in 0...playerStrums.length) {
						playerStrums.members[i].x += -650;
					}

					for (i in 0...opponentStrums.length) {
						opponentStrums.members[i].x += 650;
					}
				}

				for (i in 0...opponentStrums.length) {
					opponentStrums.members[i].x += -3000;
				}

				for (i in 0...playerStrums.length) {
					playerStrums.members[i].x += 3000;
				}

				camPos.x = 630;
				camPos.y = 650;
				snapCamFollowToPos(630, 650);
		}
		initialCamX = camPos.x;
		initialCamY = camPos.y;
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		scoreTxt.text = 'SCORE: ' + songScore
		+ ' | MISSES: ' + songMisses
		+ ' | RATING: ' + ratingName
		+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');

		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, songname + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		switch (songName) {
			case 'heart-of-gold' | 'skeleton-passion':
				var ghostNoteData = extraGhostSONG.notes;
				extraGhostNotes = new FlxTypedGroup<Note>();
				for (section in ghostNoteData)
				{
					var coolSection:Int = Std.int(section.sectionBeats / 4);
					for (songNotes in section.sectionNotes)
					{
						var daStrumTime:Float = songNotes[0];
						if (daStrumTime < 0)
							daStrumTime = 0;
						var daNoteData:Int = Std.int(songNotes[1]);
						var gottaHitNote:Bool = section.mustHitSection;
						if (songNotes[1] > 3)
						{
							gottaHitNote = !section.mustHitSection;
						}

						var oldNote:Note;
						if (extraGhostNotes.members.length > 0)
							oldNote = extraGhostNotes.members[Std.int(extraGhostNotes.members.length - 1)];
						else
							oldNote = null;

						var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
						swagNote.sustainLength = songNotes[2];
						extraGhostNotes.add(swagNote);
					}
				}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.reloadNote();
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.reloadNote();
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Dadbattle Spotlight':
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);


			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);


				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!ClientPrefs.flashing) phillyGlowGradient.intendedAlpha = 0.7;

				precacheList.set('philly/particle', 'image'); //precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, songname + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, songname + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, songname + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, songname + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, songname + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/
		callOnLuas('onUpdate', [elapsed]);

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		
		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'poignant-comfort') {
			if (curBeat >= 8 && curBeat < 103) {
				cuts.members[4].angle += -0.2;
				cuts.members[5].angle += -0.2;

				var rotRateSh = curStep / 9.5;
				var sh_toy = 450 -Math.sin(rotRateSh * 2) * 600 * 0.2;
				cuts.members[6].y += (sh_toy - dad.y) / 300;
			}

			if (curBeat >= 103  && curBeat < 120) {
				cuts.members[28].angle += -0.05;
				cuts.members[29].angle += -0.07;
				cuts.members[30].angle += -0.09;

				var rotRateSh = curStep / 9.5;
				var sh_toy = 450 -Math.sin(rotRateSh * 2) * 600 * 0.2;
				cuts.members[52].y += (sh_toy - dad.y) / 300;
			}

			if (curBeat >= 120 && curBeat < 152) {
				cuts.members[50].angle += -0.02;
				cuts.members[51].angle += -0.04;

				var rotRateSh = curStep / 9.5;
				var sh_toy = 450 -Math.sin(rotRateSh * 2) * 600 * 0.2;
				cuts.members[52].y += (sh_toy - dad.y) / 300;
			}

			if (curBeat >= 152 && curBeat < 168) {
				cuts.members[35].angle += -0.015;
				cuts.members[36].angle += -0.02;
				cuts.members[37].angle += -0.03;

				var rotRateSh = curStep / 9.5;
				var sh_toy = 450 -Math.sin(rotRateSh * 2) * 600 * 0.2;
				cuts.members[52].y += (sh_toy - dad.y) / 300;
			}

			if (curBeat == 163 && coverScreen.x <= 0 && cuts.members[38].alpha == 0) {
				cuts.members[38].alpha = 1;

				cuts.members[35].alpha = 0;
				cuts.members[36].alpha = 0;
				cuts.members[37].alpha = 0;

				cuts.members[52].scale.set(0.6,0.6);
				cuts.members[52].x += -140;
				cuts.members[52].y += 30;
				FlxTween.tween(cuts.members[52], { x: cuts.members[52].x + 350 }, 1.0);
			}
		}
		

		if (songName == 'earth-s-sister') {
			bg1.x += 1/7.5;
			bg2.x += 1/7;
			bg3.x += 1/4;

			if (curBeat >= 32 && curBeat <= 58) {
				initialCamX = 530;
				initialCamY = 600;
				snapCamFollowToPos(530, 600);
			}
		}

		if (songName == 'deadly-colors') {
			var rotRateSh = curStep / 9.5;
			var sh_toy = 400 -Math.sin(rotRateSh * 2) * 600 * 0.45;
			dad.y += (sh_toy - dad.y) / 300;
			if (!SONG.notes[curSection].mustHitSection) {
				moveCamera(true);
			}
		}

		if (songName == 'treats') {
			var rotRateSh = curStep / 9.5;
			var sh_toy = 580 - Math.sin(rotRateSh * 2) * 600 * 0.45;
			boyfriend.y += (sh_toy - dad.y) / 300;
		}

		if (songName == "tricks") {
			var v = 0;
			bgCameo.forEach(function(cameo:TeintedCameo) {
				cameo.x += cameo.speed;
				if (cameo.x <= 0 - cameo.width) {
					cameo.reloadWalkingChar();
				}
				v ++;
			});

			v = 0;
			scaredCameos.forEach(function(cameo:ScaredCameo) {
				cameo.x += cameo.speed;
				if (cameo.x <= 0 - cameo.width) {
					cameo.outOfBound();
				}
				v ++;
			});
		}

		if (songName == "caramel") {
			if (curBeat >= 4 && curBeat <= 10) {
				bg1.x += -(1/3);
				bg2.x += -(1/3);
			} else if (curBeat >= 12 && curBeat <= 18) {
				bg1.x += (1/3);
				bg2.x += (1/3);
			}
		}

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		#if debug
		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchAnimatedState(new CharacterEditorState(SONG.player2));
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var songName:String = Paths.formatToSongPath(SONG.song);
			if (songName == 'heart-of-gold' || songName == 'skeleton-passion')
			{
				extraGhostNotes.forEach(function(daNote:Note) {
				if (daNote.strumTime - Conductor.songPosition < Conductor.stepCrochet) {
						switch (daNote.noteData) {
							case 4:
								ghostExtras.playAnim('singLEFT', true);
							case 5:
								ghostExtras.playAnim('singDOWN', true);
							case 6:
								ghostExtras.playAnim('singUP', true);
							case 7:
								ghostExtras.playAnim('singRIGHT', true);
						}
					extraGhostNotes.remove(daNote, true);
				}
				});
			}

			if (!inCutscene) {
				if(!cpuControlled) {
					keyShit();
				} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					//boyfriend.animation.curAnim.finish();
				}
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(!daNote.mustPress) strumGroup = opponentStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) //Downscroll
				{
					//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
				}
				else //Upscroll
				{
					//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if(daNote.copyAlpha)
					daNote.alpha = strumAlpha;

				if(daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if(daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if(strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							if(PlayState.isPixelStage) {
								daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
							} else {
								daNote.y -= 19;
							}
						}
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}

				var center:Float = strumY + Note.swagWidth / 2;
				if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
					(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (SONG.notes[curSection] != null && (songName == 'meteorite-waltz' || songName == 'earth-s-sister' || songName == 'it-s-okay' || songName == 'satellite-picnic') && SONG.notes[curSection].mustHitSection) {
			switch (boyfriend.animation.curAnim.name) 
			{
				case 'singLEFT' | 'singLEFT-alt': triggerEventNote('character Camera Offset',Std.string(-ofs),'0');
				case 'singRIGHT' | 'singRIGHT-alt': triggerEventNote('character Camera Offset',Std.string(ofs),'0');
				case 'singUP' | 'singUP-alt': triggerEventNote('character Camera Offset','0',Std.string(-ofs));
				case 'singDOWN' | 'singDOWN-alt': triggerEventNote('character Camera Offset','0',Std.string(ofs));
				case 'idle' | 'idle-alt': triggerEventNote('character Camera Offset','0','0');
			}
		} else if (SONG.notes[curSection] != null && songName == 'satellite-picnic' && !SONG.notes[curSection].mustHitSection) {
			switch (dad.animation.curAnim.name) 
			{
				case 'singLEFT' | 'singLEFT-alt': triggerEventNote('character Camera Offset',Std.string(-ofs),'0');
				case 'singRIGHT' | 'singRIGHT-alt': triggerEventNote('character Camera Offset',Std.string(ofs),'0');
				case 'singUP' | 'singUP-alt': triggerEventNote('character Camera Offset','0',Std.string(-ofs));
				case 'singDOWN' | 'singDOWN-alt': triggerEventNote('character Camera Offset','0',Std.string(ofs));
				case 'idle' | 'idle-alt': triggerEventNote('character Camera Offset','0','0');
			}
		} else {
			triggerEventNote('character Camera Offset','','');
		}

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchAnimatedState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, songname + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		#if debug
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchAnimatedState(new ChartingState());
		chartingMode = true;
		#end

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}

				if (!gameOverCameraKeepZoom) {
					camera.zoom = stageData.defaultZoom;
					defaultCamZoom = camera.zoom;
				} else if (gameOverZoom != -10000) {
					camera.zoom = gameOverZoom;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchAnimatedState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, songname + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Dadbattle Spotlight':
				var val:Null<Int> = Std.parseInt(value1);
				if(val == null) val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
						{
							dadbattleSmokes.visible = false;
						}});
				}

			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Philly Glow':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var doFlash:Void->Void = function() {
					var color:FlxColor = FlxColor.WHITE;
					if(!ClientPrefs.flashing) color.alphaFloat = 0.5;

					FlxG.camera.flash(color, 0.15, null, true);
				};

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: //turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if(!phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if(ClientPrefs.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						var charColor:FlxColor = color;
						if(!ClientPrefs.flashing) charColor.saturation *= 0.5;
						else charColor.saturation *= 0.75;

						for (who in chars)
						{
							who.color = charColor;
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlow.PhillyGlowParticle)
						{
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						color.brightness *= 0.5;
						phillyStreet.color = color;

					case 2: // spawn particles
						if(!ClientPrefs.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:PhillyGlow.PhillyGlowParticle = new PhillyGlow.PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'character Camera Offset':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						if (!noCameraFollow) {
							if (SONG.notes[curSection].mustHitSection) {
								camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
								camFollow.x += boyfriend.cameraPosition[0] + boyfriendCameraOffset[0] + val1;
								camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1] + val2;
							} else if (!SONG.notes[curSection].mustHitSection) {
								camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
								camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0] + val1;
								camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1] + val2;
							}
						} else {
							camFollow.x =  initialCamX + val1;
							camFollow.y =  initialCamY + val2;
						}
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();

			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if (noCameraFollow) return;
		var songName:String = Paths.formatToSongPath(SONG.song);

		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			if (songName == 'satellite-picnic') {
				defaultCamZoom = 1.42;
			}
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
			if (songName == 'satellite-picnic') {
				defaultCamZoom = 1.6;
			}

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	//Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		var ret:Dynamic = callOnLuas('onEndSong', [], false);

		var weekName:String = WeekData.getWeekFileName().toLowerCase();
		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					WeekData.loadTheFirstEnabledMod();

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = CustomAnimatedTransition.nextCamera = null;
					}
					var weekName:String = WeekData.getWeekFileName().toLowerCase();
					switch(weekName)
					{
						case 'spweeked':
							startVideo('EndCredits.mp4', true);
						case 'holidays':
							startVideo('EndCredits2.mp4', true);
						case 'golden-days':
							startVideo('EndCredits3.mp4', true);
					}

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							MusicBeatState.switchState(LoadingState.getNextState(new LoadingsState(), false));
						});
					} else {
						cancelMusicFadeTween();
						MusicBeatState.switchState(LoadingState.getNextState(new LoadingsState(), false));
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				var songName:String = Paths.formatToSongPath(SONG.song);
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = CustomAnimatedTransition.nextCamera = null;
				}
				switch(fromMenu)
				{
					case 0:
						MusicBeatState.switchAnimatedState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('HungryMenuMusic'));
						FlxG.sound.music.time = 9150;
					case 1:
						if (songName == "caramel") {
							startVideo('SSNCUT.mp4', false, true);
						} else {
							MusicBeatState.switchAnimatedState(new PasswordState());
							FlxG.sound.playMusic(Paths.music('HungryMenuMusic'));
							FlxG.sound.music.time = 9150;
						}
				}
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function popUpScore(note:Note = null):Void
		{
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + 8); 
	
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
	
			var placement:String = Std.string(combo);
	
			var score:Int = 350;
	
			var daRating:String = "sick";
	
			if (noteDiff > Conductor.safeZoneOffset * 0.75)
			{
				daRating = 'shit';
				score = 50;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.5)
			{
				daRating = 'bad';
				score = 100;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.25)
			{
				daRating = 'good';
				score = 200;
			}
	
			if(daRating == 'sick' && !note.noteSplashDisabled)
			{
				spawnNoteSplashOnNote(note);
			}

			switch (daRating)
			{
				case "shit": // shit
					totalNotesHit += 0;
					shits++;
				case "bad": // bad
					totalNotesHit += 0.5;
					bads++;
				case "good": // good
					totalNotesHit += 0.75;
					goods++;
				case "sick": // sick
					totalNotesHit += 1;
					sicks++;
			}

			sumScoreTemporary += score;
	
			rating.text = daRating + "! x" + placement;
			rating.alpha = 1;
			//rating.updateFilter();

			scoreGain.text = "+" + score;
			scoreGain.alpha = 1;

			sumScoreTxt.text = Std.string(sumScoreTemporary);
			sumScoreTxt.alpha = 1;

			//filterFrames = FlxFilterFrames.fromFrames(scoreGain.frames, 10, 10, [glowFilter]);
			//filterFrames.applyToSprite(scoreGain, false, true);
			//filterFrames = FlxFilterFrames.fromFrames(sumScoreTxt.frames, 10, 10, [glowFilter]);
			//filterFrames.applyToSprite(sumScoreTxt, false, true);
	
			if(!practiceMode && !cpuControlled) {
				songScore += score;
				songHits++;
				totalPlayed++;
				RecalculateRating();
				if(scoreTxtTween != null) {
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.1;
				scoreTxt.scale.y = 1.1;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});

				comboRatingGroup.forEach(function(txt:TweeningText)
				{
					if(txt.tweenText != null) {
						txt.tweenText.cancel();
					} 
					if(txt.tweenSize != null) {
						txt.tweenSize.cancel();
					}

					txt.scale.x = 1.2;
					txt.scale.y = 1.2;
				
					txt.tweenSize = FlxTween.tween(txt.scale, {x:1, y:1}, 0.2, {
						onComplete: function(twn:FlxTween) {
							txt.tweenSize = null;
						}
					});
				});

				if(comboRatingTimer != null) {
					comboRatingTimer.cancel();
				}

				comboRatingTimer = new FlxTimer().start(1.5, function(tmr:FlxTimer) 
				{
					comboRatingGroup.forEach(function(txt:TweeningText)
					{
						txt.tweenText = FlxTween.tween(txt, {alpha:0}, 2.0, {
							onComplete: function(twn:FlxTween) {
								txt.tweenText = null;
							}
						});
					});
				});
			}
		}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'tricks') {
			cameoPassingNumber ++;
		}
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		health -= daNote.missHealth * healthLoss;
		sumScoreTemporary = 0;
		
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		playMissSound();
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			playMissSound();
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			var songName:String = Paths.formatToSongPath(SONG.song);
			if (songName == 'tricks') {
				var v = cameoPassingNumber % scaredCameos.length;
				scaredCameos.members[v].scaredAway();
				cameoPassingNumber ++;
			}

			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			}
			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		#if hscript
		FunkinLua.haxeInterp = null;
		#end
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'tricks') {
			switch (curStep)
			{
				//part 1
				case 50: scaredCameos.members[0].reloadWalkingChar();
				case 68: tricksGameFunction(3, 2);
				case 72: tricksGameFunction(3, 1);
				case 76: tricksGameFunction(3, 0);
				//part 2
				case 66: scaredCameos.members[1].reloadWalkingChar();
				case 84: tricksGameFunction(0, 3);
				case 86: tricksGameFunction(0, 2);
				case 90: tricksGameFunction(0, 1);
				case 92: tricksGameFunction(0, 0);
				//part 3
				case 82: scaredCameos.members[2].reloadWalkingChar();
				case 100: tricksGameFunction(3, 4);
				case 102: tricksGameFunction(3, 3);
				case 104: tricksGameFunction(3, 2);
				case 106: tricksGameFunction(3, 1);
				case 108: tricksGameFunction(3, 0);
				//part 4
				case 98: scaredCameos.members[3].reloadWalkingChar();
				case 116: tricksGameFunction(0, 3);
				case 120: tricksGameFunction(0, 2);
				case 122: tricksGameFunction(0, 1);
				case 124: tricksGameFunction(0, 0);
				//part 5
				case 114: scaredCameos.members[4].reloadWalkingChar();
				case 132: tricksGameFunction(3, 2);
				case 136: tricksGameFunction(3, 1);
				case 140: tricksGameFunction(3, 0);
				//part 6
				case 130: scaredCameos.members[5].reloadWalkingChar();
				case 148: tricksGameFunction(0, 3);
				case 152: tricksGameFunction(0, 2);
				case 154: tricksGameFunction(0, 1);
				case 156: tricksGameFunction(0, 0);
				//part 7
				case 144: scaredCameos.members[0].reloadWalkingChar();
				case 164: tricksGameFunction(3, 2);
				case 168: tricksGameFunction(3, 1);
				case 172: tricksGameFunction(3, 0);
				//part 8
				case 161: scaredCameos.members[1].reloadWalkingChar();
				case 180: tricksGameFunction(2, 4);
				case 182: tricksGameFunction(2, 3);
				case 184: tricksGameFunction(2, 2);
				case 186: tricksGameFunction(2, 1);
				case 188: tricksGameFunction(2, 0);
				//part 9
				case 177: scaredCameos.members[2].reloadWalkingChar();
				case 192: tricksGameFunction(3, 4);
				case 196: tricksGameFunction(3, 3);
				case 198: tricksGameFunction(3, 2);
				case 200: tricksGameFunction(3, 1);
				case 204: tricksGameFunction(3, 0);
				//part 10
				case 194: scaredCameos.members[3].reloadWalkingChar();
				case 214: tricksGameFunction(0, 3);
				case 216: tricksGameFunction(0, 2);
				case 218: tricksGameFunction(0, 1);
				case 220: tricksGameFunction(0, 0);
				//part 11
				case 210: scaredCameos.members[4].reloadWalkingChar();
				case 228: tricksGameFunction(3, 3);
				case 230: tricksGameFunction(3, 2);
				case 234: tricksGameFunction(3, 1);
				case 236: tricksGameFunction(3, 0);
				//part 12
				case 226: scaredCameos.members[5].reloadWalkingChar();
				case 244: tricksGameFunction(0, 3);
				case 248: tricksGameFunction(0, 2);
				case 250: tricksGameFunction(0, 1);
				case 252: tricksGameFunction(0, 0);
				//part 13
				case 242: scaredCameos.members[0].reloadWalkingChar();
				case 260: tricksGameFunction(3, 2);
				case 264: tricksGameFunction(3, 1);
				case 268: tricksGameFunction(3, 0);
				//part 14
				case 258: scaredCameos.members[1].reloadWalkingChar();
				case 276: tricksGameFunction(0, 3);
				case 280: tricksGameFunction(0, 2);
				case 282: tricksGameFunction(0, 1);
				case 284: tricksGameFunction(0, 0);
				//they laugh
				case 292: tricksGameFunction(2, 4);
				case 296: tricksGameFunction(2, 3);
				case 300: tricksGameFunction(2, 2);
				case 302: 
					tricksGameFunction(2, 1);
					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						counter.alpha = 0;
					});
				//part 15
				case 322: scaredCameos.members[2].reloadWalkingChar();
				case 328: tricksGameFunction(2, 5);
				case 336: tricksGameFunction(2, 4);
				case 340: tricksGameFunction(2, 3);
				case 342: tricksGameFunction(2, 2);
				case 344: tricksGameFunction(2, 1);
				case 348: tricksGameFunction(2, 0);
				//part 16
				case 338: scaredCameos.members[3].reloadWalkingChar();
				case 356: tricksGameFunction(3, 2);
				case 360: tricksGameFunction(3, 1);
				case 364: tricksGameFunction(3, 0);
				//part 17
				case 354: scaredCameos.members[4].reloadWalkingChar();
				case 372: tricksGameFunction(0, 3);
				case 376: tricksGameFunction(0, 2);
				case 378: tricksGameFunction(0, 1);
				case 380: tricksGameFunction(0, 0);
				//part 18
				case 370: scaredCameos.members[5].reloadWalkingChar();
				case 388: tricksGameFunction(3, 2);
				case 392: tricksGameFunction(3, 1);
				case 396: tricksGameFunction(3, 0);
				//part 19
				case 385: scaredCameos.members[0].reloadWalkingChar();
				case 404: tricksGameFunction(0, 3);
				case 406: tricksGameFunction(0, 2);
				case 410: tricksGameFunction(0, 1);
				case 412: tricksGameFunction(0, 0);
				//part 20
				case 402: scaredCameos.members[1].reloadWalkingChar();
				case 420: tricksGameFunction(3, 4);
				case 422: tricksGameFunction(3, 3);
				case 424: tricksGameFunction(3, 2);
				case 426: tricksGameFunction(3, 1);
				case 428: tricksGameFunction(3, 0);
				//part 21
				case 418: scaredCameos.members[2].reloadWalkingChar();
				case 436: tricksGameFunction(0, 3);
				case 440: tricksGameFunction(0, 2);
				case 442: tricksGameFunction(0, 1);
				case 444: tricksGameFunction(0, 0);
				//part 22
				case 434: scaredCameos.members[3].reloadWalkingChar();
				case 452: tricksGameFunction(3, 2);
				case 456: tricksGameFunction(3, 1);
				case 460: tricksGameFunction(3, 0);
				//part 23
				case 450: scaredCameos.members[4].reloadWalkingChar();
				case 468: tricksGameFunction(2, 3);
				case 472: tricksGameFunction(2, 2);
				case 474: tricksGameFunction(2, 1);
				case 476: tricksGameFunction(2, 0);
				//part 24
				case 466: scaredCameos.members[5].reloadWalkingChar();
				case 484: tricksGameFunction(3, 2);
				case 488: tricksGameFunction(3, 1);
				case 492: tricksGameFunction(3, 0);
				//part 25
				case 482: scaredCameos.members[0].reloadWalkingChar();
				case 500: tricksGameFunction(0, 4);
				case 502: tricksGameFunction(0, 3);
				case 504: tricksGameFunction(0, 2);
				case 506: tricksGameFunction(0, 1);
				case 508: tricksGameFunction(0, 0);
				//part 26
				case 498: scaredCameos.members[1].reloadWalkingChar();
				case 512: tricksGameFunction(3, 4);
				case 516: tricksGameFunction(3, 3);
				case 518: 
					tricksGameFunction(3, 2);
					scaredCameos.members[2].reloadWalkingChar();
				case 520: tricksGameFunction(3, 1);
				case 524: tricksGameFunction(3, 0);
				//part 27
				case 534: tricksGameFunction(0, 5);
				case 536: tricksGameFunction(0, 4);
				case 538: tricksGameFunction(0, 3);
				case 540: tricksGameFunction(0, 2);
				case 542: tricksGameFunction(0, 1);
				case 544: tricksGameFunction(0, 0);
			}
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (curBeat == 1) {
			add(bookmark);
			add(nowPlaying);
			add(nameOfSong);
			FlxTween.tween(bookmark, {x : bookmark.x + bookmark.width}, 2.0,{
				ease: FlxEase.quadInOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(bookmark, {x : bookmark.x - bookmark.width}, 2.0,{
						startDelay: 3.0
					});
				}
			});

			FlxTween.tween(nowPlaying, {x : nowPlaying.x + bookmark.width}, 2.0,{
				ease: FlxEase.quadInOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(nowPlaying, {x : nowPlaying.x - bookmark.width}, 2.0,{
						startDelay: 3.0
					});
				}
			});
			

			FlxTween.tween(nameOfSong, {x : nameOfSong.x + bookmark.width}, 2.0,{
				ease: FlxEase.quadInOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(nameOfSong, {x : nameOfSong.x - bookmark.width}, 2.0,{
						startDelay: 3.0
					});
				}
			});
		}

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'meteorite-waltz') {
			if (daisySit != null && daisySit.animation.curAnim.finished || daisySit.animation.curAnim.name == 'idle') daisySit.dance();
			if (lunaSit != null && lunaSit.animation.curAnim.finished || lunaSit.animation.curAnim.name == 'idle') lunaSit.dance();
		}

		if (songName == 'deadly-colors') {
			bg2.animation.play('Crowd Back0', true);
			bg3.animation.play('Crowd Front0', true);
		}

		if (songName == 'poignant-comfort') {
			switch (curBeat)
			{
				case 1: cuts.members[2].animation.play('boolook2 0');
				case 3: cuts.members[2].animation.play('boolook3 0');
				case 5: cuts.members[2].animation.play('booLook1 0');
				case 7: camGame.alpha = 0;
				case 8:
					cuts.members[0].alpha = 0;
					cuts.members[1].alpha = 0;
					cuts.members[2].alpha = 0;
					cuts.members[3].alpha = 1;
					cuts.members[4].alpha = 1;
					cuts.members[5].alpha = 1;
					cuts.members[6].alpha = 1;
					camGame.alpha = 1;
				case 36:
					cuts.members[0].alpha = 1;
					cuts.members[3].alpha = 0;
					cuts.members[4].alpha = 0;
					cuts.members[5].alpha = 0;
					cuts.members[6].alpha = 0;
					cuts.members[8].alpha = 1;
					cuts.members[8].animation.play('DropEffect0');
				case 40:
					cuts.members[8].alpha = 0;

					cuts.members[9].animation.play('Scene1_10');
					cuts.members[9].y += 100;
					FlxTween.tween(cuts.members[9], {y: cuts.members[9].y - 100 }, 0.2);
					FlxTween.tween(cuts.members[9], {alpha: 1 }, 0.1);
				case 44:
					cuts.members[9].alpha = 0;
					cuts.members[10].animation.play('Scene1_20');
					cuts.members[10].alpha = 1;
				case 48: 
					cuts.members[10].alpha = 0;
					cuts.members[11].animation.play('Scene1_30');
					cuts.members[11].alpha = 1;
				case 52: 
					cuts.members[11].alpha = 0;
					cuts.members[12].animation.play('Scene1_40');
					cuts.members[12].alpha = 1;
				case 56: 
					cuts.members[12].alpha = 0;
					cuts.members[13].animation.play('Scene1_50');
					cuts.members[13].alpha = 1;
				case 60: 
					cuts.members[13].alpha = 0;
					cuts.members[14].animation.play('Scene1_60');
					cuts.members[14].alpha = 1;
				case 62:
					cuts.members[14].alpha = 0;
					cuts.members[15].animation.play('Scene1_70');
					cuts.members[15].alpha = 1;
				case 64: 
					cuts.members[15].alpha = 0;
					cuts.members[16].animation.play('Scene1_80');
					cuts.members[16].alpha = 1;
					//part 7
				case 68:
					cuts.members[16].alpha = 0;
					cuts.members[17].animation.play('Scene2_30');
					cuts.members[17].alpha = 1; 
					//part 8 boo relax 1
				case 69:
					cuts.members[17].alpha = 0;
					cuts.members[18].animation.play('Scene2_10');
					cuts.members[18].alpha = 1; 
					//boo relax 2
				case 70:
					cuts.members[18].alpha = 0;
					cuts.members[19].animation.play('Scene2_20');
					cuts.members[19].alpha = 1; 
					//boo relax 3
				case 71:
					cuts.members[19].alpha = 0;
					cuts.members[20].animation.play('Scene2_40');
					cuts.members[20].alpha = 1; 
					//boo relax 4
				case 72:
					cuts.members[20].alpha = 0;
					cuts.members[21].animation.play('Scene2_50');
					cuts.members[21].alpha = 1; 
					//boo surprised
				case 73:
					cuts.members[21].alpha = 0;
					cuts.members[22].animation.play('Scene2_60');
					cuts.members[22].alpha = 1; 
					//boo surprised
				case 76: 
					cuts.members[22].alpha = 0;
					cuts.members[23].animation.play('Scene2_80');
					cuts.members[23].alpha = 1; 
					//part 9
				case 80:
					cuts.members[23].alpha = 0;
					cuts.members[24].animation.play('Scene2_90');
					cuts.members[24].alpha = 1; 
					//part 10
				case 84:
					cuts.members[24].alpha = 0;
					cuts.members[25].animation.play('Scene2_100');
					cuts.members[25].alpha = 1; 
					//part 11
				case 88: 
					cuts.members[25].alpha = 0;
					cuts.members[26].animation.play('Scene2_12_idle_0');
					cuts.members[26].alpha = 1; 
					//part 12
				case 89: cuts.members[26].animation.play('Scene2_120'); //part 13
				case 93:
					cuts.members[26].alpha = 0;
					cuts.members[2].scale.set(0.6,0.6);
					cuts.members[1].alpha = 1; 
					cuts.members[2].alpha = 1; 
					cuts.members[2].animation.play('booLook1 0');
					FlxTween.tween(cuts.members[2].scale, { x: 1, y: 1 }, 0.5);
					//part 14 (boo leaves house 2)
				case 94: cuts.members[2].animation.play('boolook2 0');
				case 96: cuts.members[2].animation.play('boolook3 0');
				case 98: cuts.members[2].animation.play('booLook1 0');
				case 99:
					FlxTween.tween(cuts.members[1], { alpha: 0 }, 0.5);
					FlxTween.tween(cuts.members[2], { alpha: 0 }, 0.5);
					//cause i still look back
				case 103:
					FlxTween.tween(cuts.members[27], { alpha: 1 }, 0.5);
					FlxTween.tween(cuts.members[28], { alpha: 1 }, 0.5);
					FlxTween.tween(cuts.members[29], { alpha: 1 }, 0.5);
					FlxTween.tween(cuts.members[30], { alpha: 1 }, 0.5);
					FlxTween.tween(cuts.members[52], { alpha: 1 }, 0.5);
					//second world around
					//assets 25% #FF9900
				case 116:
					cuts.members[27].alpha = 0;
					cuts.members[28].alpha = 0;
					cuts.members[29].alpha = 0;
					cuts.members[30].alpha = 0;
					cuts.members[52].x += -50;
					cuts.members[52].alpha = 0;
				case 120:
					cuts.members[31].color = 0xFFDABFFE;
					cuts.members[50].color = 0xFFDABFFE;
					cuts.members[51].color = 0xFFDABFFE;
					cuts.members[52].color = 0xFFDABFFE;
					cuts.members[31].alpha = 1;
					cuts.members[50].alpha = 1;
					cuts.members[51].alpha = 1;
					cuts.members[52].alpha = 1;
					//third world around
					//assets 25% #6600FF
				case 136:
					cuts.members[31].alpha = 0;
					cuts.members[50].alpha = 0;
					cuts.members[51].alpha = 0;
					cuts.members[52].alpha = 0;
					cuts.members[32].animation.play('Con10');
					cuts.members[32].alpha = 1;
					//boo 1st view
				case 139:
					cuts.members[32].alpha = 0;
					cuts.members[34].animation.play('Con30');
					cuts.members[34].alpha = 1;
					//boo cries
				case 140:
					cuts.members[34].alpha = 0;
					cuts.members[33].animation.play('Con20');
					cuts.members[33].alpha = 1;
				case 143: cuts.members[33].alpha = 0; //I am moving on
				case 148:
					cuts.members[8].alpha = 1;
					cuts.members[8].animation.play('DropEffect0');
				case 152: 
					cuts.members[8].alpha = 0;
					cuts.members[36].color = 0xFFD8BEFD;
					cuts.members[37].color = 0xFFD8BEFD;
					cuts.members[51].color = 0xFFD8BEFD;
					cuts.members[31].alpha = 1;
					cuts.members[35].alpha = 1;
					cuts.members[36].alpha = 1;
					cuts.members[37].alpha = 1;
					cuts.members[52].alpha = 1;
					//fourth world around
					//back houses 65% #000033
					//floor, ghost 25% #6600FF
				case 163: 
					coverScreen.x += FlxG.width;
					coverScreen.alpha = 1;
					FlxTween.tween(coverScreen, { x: -(FlxG.width) }, 0.5);
					//fast scrolling black screen
				case 166: cuts.members[52].animation.play('booRegSprite6 0'); //Boo turns around
				case 168: 
					cuts.members[31].alpha = 0;
					cuts.members[38].alpha = 0;
					cuts.members[52].alpha = 0;

					cuts.members[39].alpha = 1;
					cuts.members[39].animation.play('Scene3_1_idle_0');
					//enter mansion
				case 170: cuts.members[39].animation.play('Scene3_10');
				case 172:
					cuts.members[39].alpha = 0;
					cuts.members[40].animation.play('Scene3_20');
					cuts.members[40].alpha = 1;
					//boo with bag
				case 176:
					cuts.members[40].alpha = 0;
					cuts.members[41].animation.play('Scene3_30');
					cuts.members[41].alpha = 1;
					//boo in middle of the room
				case 180:
					cuts.members[41].alpha = 0;
					cuts.members[42].x += -50;
					FlxTween.tween(cuts.members[42], { x: cuts.members[42].x + 50 }, 0.2);
					cuts.members[42].animation.play('Scene3_40');
					cuts.members[42].alpha = 1;
					//boo meets biggs
				case 182:
					cuts.members[42].alpha = 0;
					cuts.members[43].x += 50;
					FlxTween.tween(cuts.members[43], { x: cuts.members[43].x - 50 }, 0.2);
					cuts.members[43].animation.play('Scene3_50');
					cuts.members[43].alpha = 1;
					//boo meets buggs
				case 184:
					cuts.members[43].alpha = 0;
					FlxTween.tween(cuts.members[44].scale, { x: 1.8, y:1.8}, 0.5);
					cuts.members[44].animation.play('Scene3_60');
					cuts.members[44].alpha = 1;
					//boo sees room and dezoomes
				case 185: FlxTween.tween(cuts.members[44].scale, { x: 1.5, y:1.5}, 2.0);
				case 188: 
					cuts.members[44].alpha = 0;
					cuts.members[45].animation.play('Scene3_70');
					cuts.members[45].alpha = 1;
					//boo view
				case 190: 
					cuts.members[45].alpha = 0;
					cuts.members[46].animation.play('Scene3_80');
					cuts.members[46].alpha = 1;
					//boo looks left
				case 192: 
					cuts.members[46].alpha = 0;
					cuts.members[47].animation.play('Scene3_90');
					cuts.members[47].alpha = 1;
					//boo looks right
				case 194: 
					cuts.members[47].alpha = 0;
					cuts.members[49].animation.play('Scene3_Last0');
					cuts.members[49].alpha = 1;
					//boo transforms
				case 200:
					cuts.members[49].alpha = 0;
					cuts.members[0].alpha = 0;
					//fin showing up
				case 204: FlxTween.tween(camHUD, { alpha: 0 }, 1.0);
			}

			if (curBeat >= 8 && curBeat < 24) cuts.members[6].animation.play('booRegSprite0');
			if (curBeat >= 24 && curBeat < 30) cuts.members[6].animation.play('booRegSprite2 0');
			if (curBeat >= 31 && curBeat < 36) cuts.members[6].animation.play('booRegSprite0');
			if (curBeat >= 103 && curBeat < 110) cuts.members[52].animation.play('booRegSprite0');
			if (curBeat >= 110 && curBeat < 112) cuts.members[52].animation.play('booRegSprite4 0');
			if (curBeat >= 112 && curBeat < 116) cuts.members[52].animation.play('booRegSprite5 0');
			if (curBeat >= 120 && curBeat < 136) cuts.members[52].animation.play('booRegSprite0');
			if (curBeat >= 152 && curBeat < 166) cuts.members[52].animation.play('booRegSprite0');

			switch (curBeat)
			{
				case 8:
					lyricalText.setPosition(FlxG.width * -0.3, FlxG.height * 0.08);
					lyricalText.text = "Is this relief or\nis this just pain?";
					lyricalText.alpha = 1;
				case 16: lyricalText.text = "Don't understand\nwhy I feel this way.";
				case 24: lyricalText.text = "I'm now free from\nyour embrace!";
				case 31: lyricalText.text = "I am moving on to a";
				case 36:
					lyricalText.alpha = 0;
					secondlyricalText.text = "Better Place";
					secondlyricalText.alpha = 1;
				case 39: FlxTween.tween(secondlyricalText, { alpha: 0 }, 0.5);
				case 40: 
					lyricalText.text = "Moving on";
					lyricalText.alpha = 1;
				case 44: FlxTween.tween(lyricalText, { alpha: 0 }, 1.0); //make it slowly invisible
				case 48: lyricalText.alpha = 1; //make it reappear
				case 54: FlxTween.tween(lyricalText, { alpha: 0 }, 1.0); //make it slowly invisible
				case 56: lyricalText.alpha = 1; //make it reappear
				case 60: FlxTween.tween(lyricalText, { alpha: 0 }, 1.0); //make it slowly invisible
				case 64: lyricalText.alpha = 1; //make it reappear
				case 70: FlxTween.tween(lyricalText, { alpha: 0 }, 1.0); //make it slowly invisible
				case 72:
					lyricalText.alpha = 1; 
					lyricalText.text = "Bittersweet Catastrophe";
				case 80: lyricalText.text = "Why did this come to be?";
				case 88: lyricalText.text = "Was it all pretend?";
				case 94: lyricalText.text = "Was it all?";
				case 99:
					FlxTween.tween(lyricalText, { alpha: 0 }, 0.5);
					secondlyricalText.text = "Cause I still look back";
					FlxTween.tween(secondlyricalText, { alpha: 1 }, 0.5);
				case 103: 
					FlxTween.tween(secondlyricalText, { alpha: 0 }, 0.5);
					//make it slowly invisible
				case 116:
					lyricalText.alpha = 0;
					cuts.members[53].x += 50;
					FlxTween.tween(cuts.members[53], {y: cuts.members[53].y - 50 }, 0.2);
					cuts.members[53].alpha = 1;
					//la
				case 117:
					cuts.members[54].x += 50;
					FlxTween.tween(cuts.members[54], {y: cuts.members[54].y - 50 }, 0.2);
					cuts.members[54].alpha = 1; 
					// la
				case 118: 
					cuts.members[55].x += 50;
					FlxTween.tween(cuts.members[55], {y: cuts.members[55].y - 50 }, 0.2);
					cuts.members[55].alpha = 1;
					//la
				case 119: 
					cuts.members[56].x += 50;
					FlxTween.tween(cuts.members[56], {y: cuts.members[56].y - 50 }, 0.2);
					cuts.members[56].alpha = 1;
				case 120:
					lyricalText.alpha = 1;
					cuts.members[53].alpha = 0;
					cuts.members[54].alpha = 0;
					cuts.members[55].alpha = 0;
					cuts.members[56].alpha = 0;
					lyricalText.text = "Is this relief or\nis this just pain?";
				case 128: lyricalText.text = "Don't understand\nwhy I feel this way.";
				case 136: lyricalText.text = "Still contemplate";
				case 139: lyricalText.text += "\ncause it's heavy weight";
				case 143:
					lyricalText.alpha = 0;
					secondlyricalText.text = "I am moving on,";
					secondlyricalText.alpha = 1;
				case 147: secondlyricalText.text = "To a better place.";
				case 152: 
					secondlyricalText.alpha = 0;
					lyricalText.text = "Moving on";
					lyricalText.alpha = 1;
				case 156: FlxTween.tween(lyricalText, { alpha: 0 }, 1.0);//make it slowly invisible
				case 160: lyricalText.alpha = 1;//make it reappear
				case 166: FlxTween.tween(lyricalText, { alpha: 0 }, 1.0);//make it slowly invisible
				case 168: lyricalText.alpha = 1;//make it reappear
				case 172: FlxTween.tween(lyricalText, { alpha: 0 }, 1.0);//make it slowly invisible
				case 176: lyricalText.alpha = 1;//make it reappear
				case 184: FlxTween.tween(lyricalText, { alpha: 0 }, 1.0);//make it slowly invisible
				case 190: lyricalText.alpha = 1;//make it reappear
				case 192: FlxTween.tween(lyricalText, { alpha: 0 }, 1.0);//make it slowly invisible
				case 196: lyricalText.text = "On";
				case 200: 
					lyricalText.alpha = 0;
					secondlyricalText.setFormat(Paths.font("times new roman bold.ttf"), 160, FlxColor.WHITE, CENTER);
					secondlyricalText.text = "Fin";
					secondlyricalText.y += -50;
					secondlyricalText.alpha = 1;
				case 204: FlxTween.tween(secondlyricalText, { alpha: 0 }, 1.0);
			}
		}

		if (songName == 'tricks') {
			bgCameo.forEach(function(cameo:TeintedCameo) {
				cameo.animation.play('walk');
			});

			scaredCameos.forEach(function(cameo:ScaredCameo) {
				if (!cameo.scared) cameo.animation.play('walk');
			});

			switch (curBeat)
			{
				case 76:
					triggerEventNote('Play Animation', 'CHUCKLESBIGGS', 'bf');
				case 137:
					triggerEventNote('Play Animation', 'CHUCKLESBUGGS', 'bf');
				case 143:
					triggerEventNote('Play Animation', 'CHUCKLESBIGGS2', 'bf');
			}
		}

		if (songName == 'caramel') {
			switch (curBeat)
			{
				case 1:
					cuts.members[0].animation.play('idle');
				case 4:
					cuts.members[0].alpha = 0;

					dad.scale.set(1.2,1.2);
					gf.scale.set(1.2,1.2);
					boyfriend.scale.set(1.2,1.2);

					dad.alpha = 0;
					gf.cameras = [camHUD];
					gf.screenCenter();
					gf.x += -500;
					gf.y += 100;
					FlxTween.tween(gf, { x: 460 }, 0.8); 

					boyfriend.cameras = [camHUD];
					boyfriend.screenCenter();
					boyfriend.x += -900;
					boyfriend.y += 400;
					FlxTween.tween(boyfriend, { x: 60 }, 0.8);

					coverScreen.alpha = 0;
					FlxTween.tween(highBlackBar, { y: highBlackBar.y + 100 }, 0.2);
					FlxTween.tween(lowBlackBar, { y: lowBlackBar.y - 100 }, 0.2);

					lyricalText.x = FlxG.width * -0.05;
					FlxTween.tween(lyricalText, { x: lyricalText.x + 200 }, 0.3);
				case 5:
					FlxTween.tween(lyricalText, { x: lyricalText.x + 80 }, 2.5);
				case 10:
					coverScreen.alpha = 1;
					highBlackBar.setPosition(0,-100);
					lowBlackBar.setPosition(0,FlxG.height);
				case 12:
					dad.alpha = 1;
					dad.cameras = [camHUD];
					dad.screenCenter();
					dad.x += 500;
					dad.y += 100;
					modchartTweens.set('dadTween', FlxTween.tween(dad, { x: 670 }, 0.8));
					gf.alpha = 0;
					gf.cameras = [camGame];
					boyfriend.alpha = 0;
					boyfriend.cameras = [camGame];

					coverScreen.alpha = 0;
					lyricalText.text = "vs LUNA MOND";
					FlxTween.tween(highBlackBar, { y: highBlackBar.y + 100 }, 0.2);
					FlxTween.tween(lowBlackBar, { y: lowBlackBar.y - 100 }, 0.2);
					
					lyricalText.x = FlxG.width * -0.42;
					FlxTween.tween(lyricalText, { x: lyricalText.x + 200 }, 0.3);
				case 13:
					FlxTween.tween(lyricalText, { x: lyricalText.x + 80 }, 2.5);
				case 18:
					coverScreen.alpha = 1;
				case 20:
					remove(blueLayer);
					noCameraFollow = false;
					moveCamera(true);

					dad.scale.set(1,1);
					gf.scale.set(1,1);
					boyfriend.scale.set(1,1);

					dad.cameras = [camGame];
					dad.setPosition(900,610);
					gf.alpha = 1;
					gf.setPosition(70,480);
					boyfriend.alpha = 1;
					boyfriend.setPosition(-90,670);

					lyricalText.alpha = 0;
					if (!ClientPrefs.middleScroll) {
						lyricalText.text = "YOU";
						lyricalText.setFormat(Paths.font("times new roman bold.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						lyricalText.borderSize = 2;
						if (!ClientPrefs.downScroll) lyricalText.setPosition(FlxG.width * -0.27, FlxG.height * 0.23);
						else if (ClientPrefs.downScroll) lyricalText.setPosition(FlxG.width * -0.27, FlxG.height * 0.71);
						lyricalText.alpha = 1;
					}

					coverScreen.alpha = 0;
					iconP1.visible = true;
					iconP2.visible = true;
					healthBarBG.visible = true;
					healthBar.visible = true;
					scoreTxt.visible = true;

					timeBar.visible = true;
					timeBarBG.visible = true;
					//botplayTxt.visible = true;
					timeTxt.visible = true;

					for (i in 0...opponentStrums.length) {
						opponentStrums.members[i].x += 3000;
					}

					for (i in 0...playerStrums.length) {
						playerStrums.members[i].x += -3000;
					}
				case 52:
					FlxTween.tween(lyricalText, { alpha: 0 }, 3.0);
				case 100:
					coverScreen.alpha = 1;
					lyricalText.text = "";
					iconP1.visible = false;
					iconP2.visible = false;
					healthBarBG.visible = false;
					healthBar.visible = false;
					scoreTxt.visible = false;

					timeBar.visible = false;
					timeBarBG.visible = false;
					timeTxt.visible = false;

					for (i in 0...opponentStrums.length) {
						opponentStrums.members[i].x += 3000;
					}

					cuts.members[1].alpha = 1;
					cuts.members[1].animation.play('idle');
				case 101:
					cuts.members[1].alpha = 1;
					cuts.members[1].animation.play('idle');
				case 102:
					cuts.members[1].alpha = 0;
				case 104:
					cuts.members[2].alpha = 1;
					FlxTween.tween(cuts.members[2].scale, {x: 0.6, y: 0.6 }, 0.3);
				case 106:
					cuts.members[2].alpha = 0;
				case 108:
					cuts.members[2].alpha = 1;
					cuts.members[3].alpha = 1;
					cuts.members[3].animation.play('idle');
					cuts.members[4].alpha = 1;
					cuts.members[4].animation.play('idle');
				case 110:
					cuts.members[2].alpha = 0;
					cuts.members[3].alpha = 0;
					cuts.members[4].alpha = 0;
				case 112:
					cuts.members[5].alpha = 1;
					cuts.members[5].animation.play('idle');
				case 116:
					cuts.members[5].alpha = 0;
					coverScreen.alpha = 0;

					iconP1.visible = true;
					iconP2.visible = true;
					healthBarBG.visible = true;
					healthBar.visible = true;
					scoreTxt.visible = true;

					timeBar.visible = true;
					timeBarBG.visible = true;
					timeTxt.visible = true;

					for (i in 0...opponentStrums.length) {
						opponentStrums.members[i].x += -3000;
					}
			}
		}

		if (songName == "treats") {
			bg2.animation.play('CrowdFront0', true);
			if (lunaSit.animation.curAnim == null || lunaSit.animation.curAnim.name == 'idle') {
				lunaSit.playAnim('idle');
			}
			switch (curBeat)
			{
				case 1:
					//lunaSit.idleSuffix = 'idle';
					//lunaSit.recalculateDanceIdle();
				case 3:
					lunaSit.playAnim('PLAY', true);
				case 27:
					FlxTween.tween(boyfriend, { alpha: 1 }, 1.5);
					FlxTween.tween(iconP1, { alpha: 1 }, 1.5);
				case 31:
					FlxTween.tween(camFollow, {x: camFollow.x + 30 }, 0.5);
					FlxTween.tween(camFollowPos, {x: camFollowPos.x + 30}, 0.5);
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.4}, 0.5);
				case 34:
					FlxTween.tween(camFollow, {x: camFollow.x + 10 }, 0.5);
					FlxTween.tween(camFollowPos, {x: camFollowPos.x + 10}, 0.5);
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.2}, 0.5);
				case 36:
					FlxTween.tween(camFollow, {x: camFollow.x - 40 }, 0.5);
					FlxTween.tween(camFollowPos, {x: camFollowPos.x - 40}, 0.5);
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.6}, 0.5);
				case 37:
					FlxTween.color(bg1, 1.0, FlxColor.WHITE, 0xFFFFFFFF);
					FlxTween.color(lunaSit, 1.0, FlxColor.WHITE, 0xFFA8A7CC);
					FlxTween.color(gf, 1.0, FlxColor.WHITE, 0xFFA8A7CC);
					FlxTween.color(dad, 1.0, FlxColor.WHITE, 0xFFA8A7CC);
				case 84:
					lunaSit.playAnim('idle');
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.2}, 0.5);
				case 85:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.4}, 7.0);
				case 100:
					lunaSit.playAnim('PLAY', true);
					FlxTween.color(bg1, 1.0, 0xFFFFFFFF, FlxColor.WHITE);
					FlxTween.color(lunaSit, 1.0, 0xFFA8A7CC, FlxColor.WHITE);
					FlxTween.color(gf, 1.0, 0xFFA8A7CC, FlxColor.WHITE);
					FlxTween.color(dad, 1.0, 0xFFA8A7CC, FlxColor.WHITE);
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.6}, 0.5);
				case 164:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.2}, 0.5);
				case 194:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.1}, 0.5);
				case 196:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.1}, 1.5);
			}
		}

		if (songName == 'earth-s-sister' && curBeat > 15) {
			if (dad.animation.curAnim.name == 'idle') {
				dad.y += 8;
				FlxTween.tween(dad, { y: dad.y - 8 }, 0.2);
			}
			if (boyfriend.animation.curAnim.name == 'idle') {
				boyfriend.y += 8;
				FlxTween.tween(boyfriend, { y: boyfriend.y - 8 }, 0.2);
			}
			if (gf.animation.curAnim.name == 'idle') {
				gf.y += 8;
				FlxTween.tween(gf, { y: gf.y - 8 }, 0.2);
			}
		}

		if (songName == 'deadly-colors') {
			switch (curBeat)
			{
				case 1:
					camZooming = true;
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.3}, 2.5);
				case 8:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.1}, 0.5);
				case 16:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.4}, 1.0);
				case 20:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.5}, 0.3);
				case 22:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.2}, 1.0);
				case 24:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.3}, 0.5);
				case 28:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.2}, 0.2);
				case 29:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.2}, 1.5);
				case 42:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.4}, 1.0);
				case 95:
					FlxTween.color(bg1, 1.0, FlxColor.WHITE, 0xFFAAAAAA);
				case 96:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.1}, 1.0);
				case 105:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.3}, 0.3);
				case 106:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.1}, 0.5);
				case 108:
					FlxTween.color(bg1, 0.5, 0xFFAAAAAA, FlxColor.WHITE);
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.5}, 0.5);
				case 148:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.5}, 0.5);
					FlxTween.color(bg1, 0.5, FlxColor.WHITE, 0xFFAAAAAA);
				case 150:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.5}, 20.0);
				case 166:
					FlxTween.color(bg1, 1.0, 0xFFAAAAAA, 0xFF888888);
				case 210:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.5}, 0.5);
				case 215:
					FlxTween.color(bg1, 1.0, 0xFF888888, FlxColor.WHITE);
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.5}, 0.5);
				case 227:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.5}, 0.5);
				case 232:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.5}, 0.5);
				case 244:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.5}, 0.5);
				case 247:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.2}, 1.0);
				case 250:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.7}, 0.5);

			}
		}

		if (songName == 'it-s-okay') {
			switch (curBeat)
			{
				case 1:
					camZooming = true;
					boyfriend.playAnim('WALKUP', true);
					boyfriend.alpha = 1;
				case 5:
					boyfriend.playAnim('SIGH', true);
				case 6:
					boyfriend.playAnim('INHALE', true);
				case 8:
					FlxTween.tween(camHUD, { alpha: 1 }, 2.0);
					FlxTween.color(boyfriend, 2.0, FlxColor.BLACK, FlxColor.WHITE);
				case 47:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.4}, 1.0);
					FlxTween.tween(camFollow, {y: camFollow.y - 30 }, 1.0);
					FlxTween.tween(camFollowPos, {y: camFollowPos.y - 30}, 1.0);
				case 94:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom - 0.4}, 1.0);
					FlxTween.tween(camFollow, {y: camFollow.y + 30 }, 1.0);
					FlxTween.tween(camFollowPos, {y: camFollowPos.y + 30}, 1.0);
				case 126:
					FlxTween.tween(this, {defaultCamZoom: defaultCamZoom + 0.4}, 1.0);
					FlxTween.tween(camFollow, {y: camFollow.y - 30 }, 1.0);
					FlxTween.tween(camFollowPos, {y: camFollowPos.y - 30}, 1.0);
				case 129:
					FlxTween.tween(camFollow, {y: camFollow.y + 30}, 0.5);
					FlxTween.tween(camFollowPos, {y: camFollowPos.y + 30}, 28.0);
			}
			if (curBeat >= 129 && curBeat < 180) {
				FlxTween.tween(this, {defaultCamZoom : defaultCamZoom - (0.4 / 71)}, 0.5);
			}
		}

		if (songName == 'earth-s-sister') {
			switch (curBeat) 
			{
				case 1:
					lyricalText.alpha = 0;
					lyricalText.text = "Don't wanna get into detail";
					lyricalText.y += 80;
					lyricalText.alpha = 1;
					FlxTween.tween(lyricalText, {y : lyricalText.y - 80}, 0.3,{ease: FlxEase.quadInOut});
					FlxTween.tween(coverScreen, {alpha : 0.7}, 2.0);
				case 4:
					lyricalText.alpha = 0;
					lyricalText.text = "But";
					lyricalText.y += 80;
					lyricalText.alpha = 1;
					FlxTween.tween(lyricalText, {y : lyricalText.y - 80}, 0.3,{ease: FlxEase.quadInOut});
				case 5:
					lyricalText.alpha = 0;
					lyricalText.text = "Let's just say";
					lyricalText.y += 80;
					lyricalText.alpha = 1;
					FlxTween.tween(lyricalText, {y : lyricalText.y - 80}, 0.3,{ease: FlxEase.quadInOut});
				case 8:
					lyricalText.alpha = 0;
					lyricalText.text = "I can't focus much";
					lyricalText.y += 80;
					lyricalText.alpha = 1;
					FlxTween.tween(lyricalText, {y : lyricalText.y - 80}, 0.3,{ease: FlxEase.quadInOut});
				case 10:
					lyricalText.alpha = 0;
					lyricalText.text = "without my mind wandering";
					lyricalText.y += 80;
					lyricalText.alpha = 1;
					FlxTween.tween(lyricalText, {y : lyricalText.y - 80}, 0.3,{ease: FlxEase.quadInOut});
				case 13:
					lyricalText.alpha = 0;
					if (ClientPrefs.downScroll) lyricalText.y = FlxG.height * 0.01;
					else lyricalText.y = FlxG.height * 0.86;
				case 15:
					FlxTween.tween(coverScreen, {alpha: 0}, 0.5);
				case 16:
					lyricalText.text = "(whistling)";
					lyricalText.color = 0xFF4747FF;
					lyricalText.alpha = 1;
				case 25:
					remove(coverScreen);
				case 32:
					lyricalText.text = "Let's go to outer space";
					lyricalText.color = 0xFFFF6400; //Daisy
				case 36:
					lyricalText.text = "I swear that's not cliche";
				case 41:
					lyricalText.alpha = 0;
				case 42:
					lyricalText.alpha = 1;
					lyricalText.text = "It's just you and me baby!";
				case 48:
					lyricalText.text = "Hey";
				case 50:
					lyricalText.text = "What do you say?";
				case 54:
					lyricalText.text = "Would you like to stay here baby?";
				case 64:
					lyricalText.text = "Hey";
					lyricalText.color = 0xFFFF00A1; //Tulip
				case 66:
					lyricalText.text = "What do you say?";
					lyricalText.color = 0xFFFF3749; //Daisy and Tulip
				case 75:
					lyricalText.text = "(more cute whistling)";
					lyricalText.color = 0xFF4747FF; //boo
				case 80:
					lyricalText.text = "We might be worlds away";
					lyricalText.color = 0xFFFF00A1; //Tulip
				case 84:
					lyricalText.text = "My heart always aches";
				case 88:
					lyricalText.text = "but somehow you";
				case 92:
					lyricalText.text = "make it brand new";
				case 97:
					lyricalText.text = "we might be apart";
				case 100:
					lyricalText.text = "but it's just the start";
				case 104:
					lyricalText.text = "come on take my hand";
					lyricalText.color = 0xFFFF3749; //Daisy and Tulip
				case 108:
					lyricalText.text = "i'll show you";
				case 112:
					lyricalText.alpha = 0;
				case 113:
					lyricalText.alpha = 1;
					lyricalText.text = "(whistling)";
					lyricalText.color = 0xFF4747FF; //boo
				case 111:
					FlxTween.color(dad, 1.0, FlxColor.WHITE, 0xFF7372AE);
					FlxTween.color(gf, 1.0, FlxColor.WHITE, 0xFF7372AE);
				case 122:
					FlxTween.tween(this, {defaultCamZoom : defaultCamZoom + 0.8}, 0.5);
				case 123:
					FlxTween.tween(this, {defaultCamZoom : defaultCamZoom + 0.5}, 2.0);
				case 127:
					FlxTween.color(dad, 1, 0xFF7372AE, 0xFFFFFFFF);
					FlxTween.color(gf, 1, 0xFF7372AE, 0xFFFFFFFF);
					FlxTween.tween(this, {defaultCamZoom : defaultCamZoom - 1.3}, 0.5);
				case 128:
					lyricalText.text = "Let's go to outer space";
					lyricalText.color = 0xFFFF3749; //Daisy and Tulip
				case 132:
					lyricalText.text = "I swear it's not cliche";
				case 136:
					lyricalText.text = "I try to take a glance";
				case 140:
					lyricalText.text = "and not take a chance";
				case 144:
					lyricalText.text = "Let's go to outer space";
				case 148:
					lyricalText.text = "I swear it's not cliche";
				case 154:
					lyricalText.text = "It's just you and me baby!";
				case 160:
					lyricalText.text = "Hey";
					lyricalText.color = 0xFFFF6400; //Daisy
				case 161:
					lyricalText.text = "Hey";
					lyricalText.color = 0xFFFF00A1; //Tulip
				case 162:
					lyricalText.text = "What do you say?";
					lyricalText.color = 0xFFFF6400; //Daisy
				case 166:
					lyricalText.text = "Would you like to stay here baby?";
				case 176:
					lyricalText.text = "Hey";
				case 177:
					lyricalText.text = "Hey";
					lyricalText.color = 0xFFFF00A1; //Tulip
				case 178:
					lyricalText.text = "What do you say?";
					lyricalText.color = 0xFFFF6400; //Daisy
				case 179:
					lyricalText.text = "What do you say?";
					lyricalText.color = 0xFFFF00A1; //Tulip
				case 188:
					lyricalText.text = "(whistling)";
					lyricalText.color = 0xFF4747FF; //Boo
				case 192:
					lyricalText.alpha = 0;
				case 203:
					lyricalText.alpha = 1;
				case 208:
					lyricalText.alpha = 0;
					camGame.alpha = 0;
			}
		}

		if (songName == 'meteorite-waltz') {
			switch (curBeat)
			{
				case 120:
					FlxTween.tween(camHUD, { alpha: 0 }, 3.0);
				case 126:
					daisySit.animation.play('NOTICE', true);
					daisySit.y += -1;
				case 127:
					sparkles.alpha = 1;
					sparkles.animation.play('idle', true);
					daisySit.idleSuffix = 'LOOKUPSTILL';
					daisySit.recalculateDanceIdle();
				case 128:
					daisySit.animation.play('LOOKUP', true);
					daisySit.x += -8;
					daisySit.y += 1;
				case 129:
					dad.animation.play('LOOKATDAISY', true);
					dad.x += -3;
					boyfriend.animation.play('LOOKATDAISY', true);
					boyfriend.y += -1;
					lunaSit.animation.play('LOOKATDAISY', true);
					lunaSit.x += -1;
				case 130:
					boyfriend.idleSuffix = 'LOOKATDAISYSTILL';
					boyfriend.recalculateDanceIdle();

					lunaSit.idleSuffix = 'LOOKATDAISYSTILL';
					lunaSit.recalculateDanceIdle();

					dad.idleSuffix = 'LOOKATDAISYSTILL';
					dad.recalculateDanceIdle();
					
					dad.animation.play('LOOKUP', true);
					dad.x += -1;
					boyfriend.animation.play('LOOKUP', true);
					boyfriend.x += 1;
					lunaSit.animation.play('LOOKUP', true);
					lunaSit.x += -1;
				case 133:
					daisySit.idleSuffix = 'LOOKUPSTILL';
					daisySit.recalculateDanceIdle();
				case 134:
					boyfriend.idleSuffix = 'LOOKUPSTILL';
					boyfriend.recalculateDanceIdle();

					lunaSit.idleSuffix = 'LOOKUPSTILL';
					lunaSit.recalculateDanceIdle();

					dad.idleSuffix = 'LOOKUPSTILL';
					dad.recalculateDanceIdle();
				case 135:
					shootingStar.alpha = 1;
					shootingStar.animation.play('idle', true);
				case 140:
					var spr:FlxSprite = new FlxSprite();
					spr.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					spr.alpha = 0;
					add(spr);
					spr.screenCenter();
					spr.y += 250;
					FlxTween.tween(spr, { alpha: 1 }, 3.0);
			}
		}
		trace(curBeat);

		if (songName == 'ghost-picnic') {
			switch (curBeat)
			{
				case 2:
					spotlight.animation.play('SpotlightStillAnim0', true);
				case 36:
					boyfriend.playAnim('TRANSITION', true);
					boyfriend.specialAnim = true;
				case 37:
					triggerEventNote('Change Character', '0', 'boo-stage');
				case 132:
					boyfriend.playAnim('FLIP',true);
					boyfriend.specialAnim = true;
				case 190:
					spotlight.animation.play('SpotlightStillAnim0', true, true);
				case 193:
					spotlight.animation.play('SpotlightStillClosed0', true);
			}
		}

		if (songName == 'heart-of-gold') {
			if (ghostExtras != null && ghostExtras.animation.curAnim.finished || ghostExtras.animation.curAnim.name == 'idle') ghostExtras.playAnim('idle');

			switch (curBeat)
			{
				case 2:
					camZooming = true;
					spotlight.animation.play('SpotlightStillAnim0', true);
				case 6:
					FlxTween.tween(camFollow, { x: camFollow.x + 30, y: camFollow.y + 30}, 0.5);
					FlxTween.tween(camFollowPos, { x: camFollowPos.x + 30, y: camFollowPos.y + 30}, 0.5);
					FlxTween.tween(this, {defaultCamZoom : 1.2}, 0.5);
				case 8:
					FlxTween.tween(camFollow, { x: camFollow.x - 30, y: camFollow.y - 15}, 0.5);
					FlxTween.tween(camFollowPos, { x: camFollowPos.x - 30, y: camFollowPos.y - 15}, 0.5);
					FlxTween.tween(this, {defaultCamZoom : 1.5}, 0.5);
				case 10:
					//snapCamFollowToPos(-100, -126);
					FlxTween.tween(camFollow, { x: -100, y: -126 }, 0.8);
					FlxTween.tween(camFollowPos, { x: -100, y: -126}, 0.8);
					FlxTween.tween(this, {defaultCamZoom : 0.82}, 1.0);
					mid.colorTween = FlxTween.color(mid, 1.0, FlxColor.WHITE, 0xFFFFFFFF);
					fore.colorTween = FlxTween.color(fore, 1.0, FlxColor.WHITE, 0xFFFFFFFF);
					//crowd less dark
					FlxTween.tween(spotlight, { alpha: 0 }, 0.5);
					FlxTween.tween(ghostExtras, { alpha: 1 }, 0.5);
				case 42:
					//camera follows ghost
					FlxTween.tween(dad, { alpha: 1 }, 0.5);
					FlxTween.tween(iconP2, { alpha: 1 }, 0.5);
				case 105:
					//camera follows tulip
					//blue ghost and extra ghost darkens (#6A63305, 50%)
					ghostExtras.colorTween = FlxTween.color(ghostExtras, 1.0, FlxColor.WHITE, 0xFFB7B285);
					boyfriend.colorTween = FlxTween.color(boyfriend, 1.0, FlxColor.WHITE, 0xFFB7B285);
					mid.colorTween = FlxTween.color(mid, 1.0, FlxColor.WHITE, 0xFF000000);
					fore.colorTween = FlxTween.color(fore, 1.0, FlxColor.WHITE, 0xFF000000);
					bgTween = FlxTween.color(bg, 1.0, FlxColor.WHITE, 0xFF666666);

					FlxTween.tween(this, {defaultCamZoom : 1.6}, 1.0);
					FlxTween.tween(camFollow, { x: camFollow.x - 50, y: camFollow.y + 100}, 1);
					FlxTween.tween(camFollowPos, { x: camFollowPos.x - 50, y: camFollowPos.y + 100 }, 1);
					//crowd 100% dark (slow transition)
					//zoom section
				case 137:
					//end of zoom section, go back to normal
					ghostExtras.colorTween = FlxTween.color(ghostExtras, 1.0, 0xFFB7B285, 0xFFFFFFFF);
					boyfriend.colorTween = FlxTween.color(boyfriend, 1.0, 0xFFB7B285, 0xFFFFFFFF);
					mid.colorTween = FlxTween.color(mid, 1.0, 0xFF000000, 0xFFFFFFFF);
					fore.colorTween = FlxTween.color(fore, 1.0, 0xFF000000, 0xFFFFFFFF);
					bgTween = FlxTween.color(bg, 1.0, 0xFF666666, 0xFFFFFFFF);

					FlxTween.tween(this, {defaultCamZoom : 0.82}, 1.0);
					FlxTween.tween(camFollow, { x: camFollow.x + 50, y: camFollow.y - 100 }, 1);
					FlxTween.tween(camFollowPos, { x: camFollowPos.x + 50, y: camFollowPos.y - 100 }, 1);
				case 303:
					//ghost bow
					triggerEventNote('Play Animation', 'BOW', 'boyfriend');
					triggerEventNote('Play Animation', 'BOW', 'dad');
					ghostExtras.playAnim('BOW',true);
					ghostExtras.specialAnim = true;
					mid.colorTween = FlxTween.color(mid, 1.0, FlxColor.WHITE, 0xFF404040);
					fore.colorTween = FlxTween.color(fore, 1.0, FlxColor.WHITE, 0xFF000000);
				case 306:
					triggerEventNote('Play Animation', 'BOW-loop', 'boyfriend');
					triggerEventNote('Play Animation', 'BOW-loop', 'dad');
					ghostExtras.playAnim('BOW-loop',true);
					ghostExtras.specialAnim = true;
					spotlight.animation.play('SpotlightStillClosed0', true);
					FlxTween.tween(spotlight, { alpha: 1 }, 0.5);
					FlxTween.tween(camHUD, { alpha: 0 }, 0.5);
			}

			switch (curBeat)
			{
				case 42: FlxTween.tween(lyricalText, { alpha: 1 }, 0.5);
				case 47: lyricalText.text += " have a heart made of gold.";
				case 55: lyricalText.text = "It's as sweet as honey.";
				case 63: lyricalText.text = "In it's purest form.";
				case 74: lyricalText.text = "You have a heart made of gold.";
				case 87: lyricalText.text = "It's not even cold.";
				case 95: lyricalText.text = "It's always sunny.";
				case 104: lyricalText.text = "And when it snows.";
				case 112: lyricalText.text = "I feel so warm.";
				case 121: lyricalText.text = "And when it snows.";
				case 128: lyricalText.text = "I love the charm.";
				case 138: lyricalText.text = "You have a heart made of gold.";
				case 151: lyricalText.text = "It feels like home.";
				case 159: lyricalText.text = "It feels like home.";
				case 170: lyricalText.alpha = 0;
				case 201: 
					lyricalText.alpha = 1;
					lyricalText.text = "And when it snows.";
				case 208: lyricalText.text = "I feel so home.";
				case 217: lyricalText.text = "And when it snows.";
				case 224: lyricalText.text = "I feel at home with you.";
				case 240: lyricalText.text = "It's true, It's you.";
				case 256: lyricalText.text = "A Heart of Gold is you.";
				case 272: lyricalText.alpha = 0;
				case 290: 
					lyricalText.alpha = 1;
					lyricalText.text = "Oooo, Heart of Gold.";
				case 306: FlxTween.tween(lyricalText, { alpha: 0 }, 0.5);
			}
		}

		if (songName == 'skeleton-passion') {
			if (ghostExtras != null && ghostExtras.animation.curAnim.finished || ghostExtras.animation.curAnim.name == 'idle') ghostExtras.playAnim('idle');

			switch (curBeat)
			{
				case 3:
					FlxTween.tween(camHUD, { alpha: 1 }, 1.0);
				case 5:
					remove(heyGhosts);
					bgTween = FlxTween.color(bg, 0.25, 0xFF3D3D3D, 0xFFFFFFFF);
					fore.colorTween = FlxTween.color(fore, 0.25, 0xFF3D3D3D, 0xFFFFFFFF);
					mid.colorTween = FlxTween.color(mid, 0.25, 0xFF3D3D3D, 0xFFFFFFFF);
					dad.colorTween = FlxTween.color(dad, 0.25, 0xFFFFC1FF, 0xFFFFFFFF);
					boyfriend.colorTween = FlxTween.color(boyfriend, 0.25, 0xFFB290BF, 0xFFFFFFFF);
					ghostExtras.colorTween = FlxTween.color(ghostExtras, 0.25, 0xFFB290BF, 0xFFFFFFFF);
					FlxTween.tween(camera, {zoom : 0.82}, 0.25);
					FlxTween.tween(this, {defaultCamZoom : 0.82}, 0.25);
					FlxTween.tween(camFollow, { x: camFollow.x + 200, y: camFollow.y - 100 }, 0.25);
					FlxTween.tween(camFollowPos, { x: camFollowPos.x + 200, y: camFollowPos.y - 100 }, 0.25);
				case 12: // first camera zoom
					FlxTween.tween(camFollow, { x: camFollow.x - 100, y: camFollow.y + 100 }, 0.25);
					FlxTween.tween(camFollowPos, { x: camFollowPos.x - 100, y: camFollowPos.y + 100 }, 0.25);
					FlxTween.tween(this, {defaultCamZoom : 0.9}, 0.25);
				case 16: // second camera zoom
				FlxTween.tween(this, {defaultCamZoom : 1.2}, 0.25);
				case 19:
					FlxTween.tween(this, {defaultCamZoom : 1.5}, 0.25);
				case 24:
					FlxTween.tween(this, {defaultCamZoom : 1.1}, 0.25);
				case 33:
					FlxTween.tween(this, {defaultCamZoom : 1.5}, 0.25);
				case 35:
					FlxTween.tween(this, {defaultCamZoom : 2.2}, 0.25);
				case 37:
					FlxTween.tween(this, {defaultCamZoom : 0.9}, 0.25);
				case 84:
					bgTween = FlxTween.color(bg, 0.5, 0xFFFFFFFF, 0xFF3D3D3D);
					fore.colorTween = FlxTween.color(fore, 0.5, 0xFFFFFFFF, 0xFF3D3D3D);
					mid.colorTween = FlxTween.color(mid, 0.5, 0xFFFFFFFF, 0xFF3D3D3D);
					dad.colorTween = FlxTween.color(dad, 0.5, 0xFFFFFFFF, 0xFFFFC1FF);
					boyfriend.colorTween = FlxTween.color(boyfriend, 0.5, 0xFFFFFFFF, 0xFFB290BF);
					ghostExtras.colorTween = FlxTween.color(ghostExtras, 0.5, 0xFFFFFFFF, 0xFFB290BF);
				case 100:
					FlxTween.tween(this, {defaultCamZoom : 1.1}, 0.25);
				case 104:
					FlxTween.tween(this, {defaultCamZoom : 1.25}, 0.25);
				case 110:
					FlxTween.tween(this, {defaultCamZoom : 2.2}, 0.25);
					FlxTween.tween(camFollow, { x: camFollow.x + 50, y: camFollow.y - 20 }, 0.25);
					FlxTween.tween(camFollowPos, { x: camFollowPos.x + 50, y: camFollowPos.y - 20 }, 0.25);
				case 112:
					FlxTween.tween(this, {defaultCamZoom : 2.3}, 0.25);
					FlxTween.tween(camFollow, { x: camFollow.x + 50, y: camFollow.y - 20 }, 0.25);
					FlxTween.tween(camFollowPos, { x: camFollowPos.x + 50, y: camFollowPos.y - 20 }, 0.25);
				case 116:
					FlxTween.tween(camFollow, { x: camFollow.x - 100, y: camFollow.y + 40 }, 0.25);
					FlxTween.tween(camFollowPos, { x: camFollowPos.x - 100, y: camFollowPos.y + 40 }, 0.25);
					FlxTween.tween(this, {defaultCamZoom : 0.9}, 0.25);
				case 124:
					FlxTween.tween(this, {defaultCamZoom : 1.2}, 0.25);
				case 132:
					FlxTween.tween(this, {defaultCamZoom : 0.9}, 0.25);
					bgTween = FlxTween.color(bg, 0.25, 0xFF7F7F7F, 0xFFFFFFFF);
					fore.colorTween = FlxTween.color(fore, 0.25, 0xFF7F7F7F, 0xFFFFFFFF);
					mid.colorTween = FlxTween.color(mid, 0.25, 0xFF7F7F7F, 0xFFFFFFFF);
					dad.colorTween = FlxTween.color(dad, 0.25, 0xFFFFC1FF, 0xFFFFFFFF);
					boyfriend.colorTween = FlxTween.color(boyfriend, 0.25, 0xFFB290BF, 0xFFFFFFFF);
					ghostExtras.colorTween = FlxTween.color(ghostExtras, 0.25, 0xFFB290BF, 0xFFFFFFFF);
				case 163: //fast zoom in
					FlxTween.tween(this, {defaultCamZoom : 1.2}, 0.25);
				case 165: //slow zoom in
					FlxTween.tween(this, {defaultCamZoom : 1.5}, 3);
				case 173: //fast zoom in
					FlxTween.tween(this, {defaultCamZoom : 1.6}, 0.25);
				case 174:
					FlxTween.tween(this, {defaultCamZoom : 2.2}, 2.5);
				case 180:
					FlxTween.tween(this, {defaultCamZoom :1.8}, 0.25);
				case 195:
					FlxTween.tween(this, {defaultCamZoom : 1.2}, 0.25);
				case 207:
					FlxTween.tween(this, {defaultCamZoom : 0.9}, 0.25);
				case 215:
					mid.animation.play("clap");
					triggerEventNote('Play Animation', 'BOW', 'boyfriend');
					triggerEventNote('Play Animation', 'BOW', 'dad');
					ghostExtras.playAnim('BOW',true);
					ghostExtras.specialAnim = true;
				case 217:
					triggerEventNote('Play Animation', 'BOW-loop', 'boyfriend');
					triggerEventNote('Play Animation', 'BOW-loop', 'dad');
					ghostExtras.playAnim('BOW-loop',true);
					ghostExtras.specialAnim = true;
					FlxTween.tween(dad, { alpha: 0 }, 0.5);
					FlxTween.tween(boyfriend, { alpha: 0 }, 0.5);
					FlxTween.tween(ghostExtras, { alpha: 0 }, 0.5);
					FlxTween.tween(iconP1, { alpha: 1 }, 0.5);
					FlxTween.tween(iconP2, { alpha: 1 }, 0.5);
				case 230:
					FlxTween.tween(spotlight, { alpha: 1 }, 1.0);
					FlxTween.tween(camHUD, { alpha: 0 }, 1.0);
			}

			switch (curBeat)
			{
				case 6: lyricalText.alpha = 1;
				case 13: lyricalText.text = "And I don't want you to wait around for me.";
				case 21: lyricalText.text = "So go on and live out your wildest dreams.";
				case 33: lyricalText.text = "Woah";
				case 34: lyricalText.text += " Woah";
				case 35: lyricalText.text += " Woah";
				case 36: lyricalText.text += " Woah!";
				case 38: lyricalText.text = "Even though I'm just a skeleton.";
				case 46: lyricalText.text = "I still have this passion.";
				case 54: lyricalText.text = "I want to live out my dreams.";
				case 70: lyricalText.text = "Who said, who said you can't?";
				case 81: lyricalText.alpha = 0;
				case 86: 
					lyricalText.alpha = 1;
					lyricalText.text = "Who said, who said you can't?";
				case 99: lyricalText.text = "And I know it get's old,";
				case 107: lyricalText.text = "Everyday it goes on.";
				case 116: lyricalText.text = "But don't give up now, no!";
				case 125: lyricalText.text = "Don't give up now, cuz!";
				case 134: lyricalText.text = "Even though I'm just a skeleton.";
				case 142: lyricalText.text = "I have so much to live.";
				case 150: lyricalText.text = "I want to show you all my dreams.";
				case 163: lyricalText.alpha = 0;
				case 166: 
					lyricalText.alpha = 1;
					lyricalText.text = "Even though I'm gone I have all this passion.";
				case 173: lyricalText.text = "So don't let yours fade away so quick.";
				case 182: lyricalText.text = "Please show me all of your dreams, your dreams!";
				case 197: lyricalText.text = "Make it into,";
				case 201: lyricalText.text = "Make it into reality.";
				case 215: FlxTween.tween(lyricalText, { alpha: 0 }, 0.5);
			}
		}

		// midevents for boo (stage and transparency stuff mostly)
        if (songName == 'boo') {
			if(curBeat == 13) {
				boyfriend.alpha = 1;
			}
			if(curBeat == 20) {
				door.animation.play('DoorOpenSlow');
			}
			if(curBeat == 26) {
				FlxTween.tween(dad, { alpha: 1 }, 0.5);
				FlxTween.tween(iconP2, { alpha: 1 }, 0.5);
			}
			if(curBeat == 129) {
				FlxTween.tween(dad, { alpha: 0 }, 0.5);
				FlxTween.tween(iconP2, { alpha: 0 }, 0.5);
			}
			if(curBeat == 130) {
				door.animation.play('DoorCloseFast');
			}
			if(curBeat == 148) {
				door.animation.play('DoorOpenFast');
			}
			if(curBeat == 149) {
				FlxTween.tween(dad, { alpha: 1 }, 0.5);
				FlxTween.tween(iconP2, { alpha: 1 }, 0.5);
			}
			if(curBeat == 196) {
				FlxTween.tween(dad, { alpha: 0 }, 0.5);
				FlxTween.tween(iconP2, { alpha: 0 }, 0.5);
			}	
            if(curBeat == 208) {
				silence1.alpha = 1;
				silence1.animation.play('Font1');
			}
			if(curBeat == 212) {
				silence2.alpha = 1;
				silence2.animation.play('Font2');
			}
			if(curBeat == 215) {
				silence3.alpha = 1;
				silence3.animation.play('Font3');
			}
			if(curBeat == 220) {
				silence4.alpha = 1;
				silence4.animation.play('Font4');
			}
			if(curBeat == 290) {
				FlxTween.tween(dad, { alpha: 1 }, 0.5);
				FlxTween.tween(iconP2, { alpha: 1 }, 0.5);
			}
		}
		
        if (songName == 'boo-sticky') {
			if(curBeat == 13) {
				boyfriend.alpha = 1;
			}
			if(curBeat == 20) {
				door.animation.play('DoorOpenSlow');
			}
			if(curBeat == 26) {
				FlxTween.tween(dad, { alpha: 1 }, 0.5);
				FlxTween.tween(iconP2, { alpha: 1 }, 0.5);
			}
			if(curBeat == 129) {
				FlxTween.tween(dad, { alpha: 0 }, 0.5);
				FlxTween.tween(iconP2, { alpha: 0 }, 0.5);
			}
			if(curBeat == 130) {
				door.animation.play('DoorCloseFast');
			}
			if(curBeat == 148) {
				door.animation.play('DoorOpenFast');
			}
			if(curBeat == 149) {
				FlxTween.tween(dad, { alpha: 1 }, 0.5);
				FlxTween.tween(iconP2, { alpha: 1 }, 0.5);
			}
			if(curBeat == 196) {
				FlxTween.tween(dad, { alpha: 0 }, 0.5);
				FlxTween.tween(iconP2, { alpha: 0 }, 0.5);
			}	
            if(curBeat == 208) {
				silence1.alpha = 1;
				silence1.animation.play('Font1');
			}
			if(curBeat == 212) {
				silence2.alpha = 1;
				silence2.animation.play('Font2');
			}
			if(curBeat == 215) {
				silence3.alpha = 1;
				silence3.animation.play('Font3');
			}
			if(curBeat == 220) {
				silence4.alpha = 1;
				silence4.animation.play('Font4');
			}
			if(curBeat == 290) {
				FlxTween.tween(dad, { alpha: 1 }, 0.5);
				FlxTween.tween(iconP2, { alpha: 1 }, 0.5);
			}
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}

		switch (curStage)
		{
			case 'holidayStage':
				mid.dance();
				fore.dance();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			if(ret != FunkinLua.Function_Continue)
				returnVal = ret;
		}
		#end
		//trace(event, returnVal);
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);
		
		if (badHit)
			updateScore(true); // miss notes shouldn't make the scoretxt bounce -Ghost
		else
			updateScore(false);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	function tricksGameFunction(strum:Int, counterValue:Int):Void
	{
		if (counterValue == 0)
		{
			counter.animation.play('now');
			new FlxTimer().start(0.8, function(tmr:FlxTimer)
			{
				counter.alpha = 0;
			});
		} 
		else
		{
			counter.animation.play(Std.string(counterValue));
		}

		playerStrums.members[strum].alpha = 1;
		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			playerStrums.members[strum].alpha = 0;
		});
		counter.alpha = 1;
	}

	function tricksCameo():Void
	{
		TeintedCameo.initialize();
		ScaredCameo.initialize();

		
		var cameoOne:TeintedCameo = new TeintedCameo(0);
		add(cameoOne);

		var cameoTwo:TeintedCameo = new TeintedCameo(1);
		add(cameoTwo);

		var cameoThree:TeintedCameo = new TeintedCameo(2);
		add(cameoThree);

		var cameoFour:TeintedCameo = new TeintedCameo(3);
		add(cameoFour);

		//var cameoSeven:TeintedCameo = new TeintedCameo(4);
		//add(cameoSeven);

		//var cameoTwelve:TeintedCameo = new TeintedCameo(5);
		//add(cameoTwelve);

		bgCameo = new FlxTypedGroup<TeintedCameo>();

		bgCameo.add(cameoOne);
		bgCameo.add(cameoTwo);
		bgCameo.add(cameoThree);
		bgCameo.add(cameoFour);
		//bgCameo.add(cameoTwelve);

		scaredCameos = new FlxTypedGroup<ScaredCameo>();

		var cameoFive:ScaredCameo = new ScaredCameo(1);
		cameoFive.x += 10000;
		add(cameoFive);
		
		var cameoSix:ScaredCameo = new ScaredCameo(1);
		cameoSix.x += 10000;
		add(cameoSix);

		var cameoEight:ScaredCameo = new ScaredCameo(1);
		cameoEight.x += 10000;
		add(cameoEight);

		var cameoNine:ScaredCameo = new ScaredCameo(1);
		cameoNine.x += 10000;
		add(cameoNine);

		var cameoTen:ScaredCameo = new ScaredCameo(1);
		cameoTen.x += 10000;
		add(cameoTen);

		var cameoEleven:ScaredCameo = new ScaredCameo(1);
		cameoEleven.x += 10000;
		add(cameoEleven);
		
		scaredCameos.add(cameoFive);
		scaredCameos.add(cameoSix);
		scaredCameos.add(cameoEight);
		scaredCameos.add(cameoNine);
		scaredCameos.add(cameoTen);
		scaredCameos.add(cameoEleven);
	}

	function playMissSound():Void
	{
		var missSound:FlxSound;
		missSound = new FlxSound().loadEmbedded(Paths.soundRandom('missnote', 1, 3), false, false, songMusicComesBack);
		missSound.volume = FlxG.random.float(0.01, 0.15);
		missSound.play(true);
	}

	function songMusicComesBack():Void
	{
		vocals.volume = 1;
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				switch(achievementName)
				{
					case 'week1_nomiss' | 'week2_nomiss' | 'week3_nomiss' | 'week4_nomiss' | 'week5_nomiss' | 'week6_nomiss' | 'week7_nomiss':
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'week1':
									if(achievementName == 'week1_nomiss') unlock = true;
								case 'week2':
									if(achievementName == 'week2_nomiss') unlock = true;
								case 'week3':
									if(achievementName == 'week3_nomiss') unlock = true;
								case 'week4':
									if(achievementName == 'week4_nomiss') unlock = true;
								case 'week5':
									if(achievementName == 'week5_nomiss') unlock = true;
								case 'week6':
									if(achievementName == 'week6_nomiss') unlock = true;
								case 'week7':
									if(achievementName == 'week7_nomiss') unlock = true;
							}
						}
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = -1;
	var curLightEvent:Int = -1;
}
