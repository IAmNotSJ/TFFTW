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
import flixel.group.FlxSpriteGroup;
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
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var eastereggCount:Int = 0;
	
	var titleTextColors:Array<FlxColor> = [0xFF55E5FF, 0xFF125CE6];
	var titleTextAlphas:Array<Float> = [1, .74];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var easterEggGroup:FlxSpriteGroup;

	var mustUpdate:Bool = false;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		//WeekData.loadTheFirstEnabledMod();

		//trace(path, FileSystem.exists(path));

		/*#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end*/

		FlxG.game.focusLostFramerate = 60;
		FlxG.autoPause = false;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'TFFTW');

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
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(!FlxG.save.data.flashingShown) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
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
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();

			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('StrugglinOnAFridayNight'), 0);
			}
		}

		Conductor.changeBPM(200);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image('title/bg'));
		add(bg);
		
		easterEggGroup = new FlxSpriteGroup();
		add(easterEggGroup);

		var earth:FlxSprite = new FlxSprite(247,42);
		earth.loadGraphic(Paths.image('title/earth'));
		add(earth);

		logoBl = new FlxSprite();
		logoBl.frames = Paths.getSparrowAtlas('title/logoBumpin');
		logoBl.screenCenter();
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		new FlxTimer().start(FlxG.random.float(20,30), function(tmr:FlxTimer) {
			if (eastereggCount >= 1)
				{
					if (FlxG.random.int(1,13) == 10)
						{
							addRandomEasterEgg(10);
							addRandomEasterEgg(10);
							addRandomEasterEgg(10);
						}
					else
						addRandomEasterEgg();
				}
			eastereggCount++;
		},0);

		swagShader = new ColorSwap();
		gfDance = new FlxSprite(-350, 320);

		gfDance.frames = Paths.getSparrowAtlas('title/gf');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

		gfDance.antialiasing = ClientPrefs.globalAntialiasing;

		add(gfDance);
		gfDance.shader = swagShader.shader;
		add(logoBl);
		logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(0,591);
		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/titleEnter.png";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "mods/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "assets/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
		#else

		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#end
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (animFrames.length > 0) {
			newTitle = true;
			
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else {
			newTitle = false;
			
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

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
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		if (FlxG.keys.justPressed.F1)
			if (FlxG.random.int(1,13) == 10)
				{
					addRandomEasterEgg(10);
					addRandomEasterEgg(10);
					addRandomEasterEgg(10);
				}
			else
				addRandomEasterEgg();

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
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			
			if(pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						MusicBeatState.switchState(new OutdatedState());
					} else {
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
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



		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					//FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.music('StrugglinOnAFridayNight'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
					createCoolText(['DirectSpoogles'], -30);
				case 9:
					addMoreText('SJ', -30);
				// credTextShit.visible = true;
				case 17:
					addMoreText('OrangeLenny', -30);
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 25:
					addMoreText('Zeno', -30);
				case 33:
					//deleteCoolText();
					addMoreText('GreenyToaster', -30);
				case 41:
					addMoreText('Zeph', -30);
				case 47:
					deleteCoolText();
					createCoolText(['All']);
				case 48:
					addMoreText('Prou');
				case 49:
					deleteCoolText();
					createCoolText(['All']);
					addMoreText('Proudly');
				case 52:
					addMoreText('Present');
				case 57:
					deleteCoolText();
					createCoolText(['A Mod']);
				case 59:
					addMoreText('Based Off Of');
				case 62 :
					addMoreText('The Strugle');
				case 63:
					deleteCoolText();
					createCoolText(['A Mod']);
					addMoreText('Based Off Of');
					addMoreText('The Struggle For');
				case 64:
					deleteCoolText();
					createCoolText(['A Mod']);
					addMoreText('Based Off Of');
					addMoreText('The Struggle For The');
				case 65:
					deleteCoolText();
					createCoolText(['A Mod']);
					addMoreText('Based Off Of');
					addMoreText('The Struggle For The World');
				case 73:
					deleteCoolText();
					createCoolText([curWacky[0]]);
				case 79:
					addMoreText(curWacky[1]);
				case 89:
					deleteCoolText();
					createCoolText(['The']);
				case 91:
					addMoreText('Funkin');
				case 93:
					deleteCoolText();
					createCoolText(['The']);
					addMoreText('Funkin');
					addMoreText('For');
				case 94:
					deleteCoolText();
					createCoolText(['The']);
					addMoreText('Funkin');
					addMoreText('For The');
				case 95:
					deleteCoolText();
					createCoolText(['The']);
					addMoreText('Funkin');
					addMoreText('For The');
					addMoreText('World');
			}
		}

		if (sickBeats % 2 == 0)
				if(logoBl != null)
					logoBl.animation.play('bump', true);
		
			if(gfDance != null) {
				danceLeft = !danceLeft;
				if (danceLeft)
					gfDance.animation.play('danceRight');
				else
					gfDance.animation.play('danceLeft');
			}
	}

	private var sickSteps:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	override function stepHit()
	{
		super.stepHit();
		if(!closedState) {
			sickSteps++;
			
			switch (sickSteps)
			{
				case 389:
					skipIntro();
			}
		}
	}

	function addRandomEasterEgg(?specific:Int = 0):Void
	{
		var scale:Float = FlxG.random.float(0.8,1);
		var easteregg:FlxSprite = new FlxSprite(-350, FlxG.random.int(0,720));
		easteregg.frames = Paths.getSparrowAtlas('title/easter_eggs');
		easteregg.animation.addByPrefix('1', 'orange');
		easteregg.animation.addByPrefix('2', 'lenny');
		easteregg.animation.addByPrefix('3', 'milk');
		easteregg.animation.addByPrefix('4', 'zeph');
		easteregg.animation.addByPrefix('5', 'sj');
		easteregg.animation.addByPrefix('6', 'spoogles');
		easteregg.animation.addByPrefix('7', 'towa');
		easteregg.animation.addByPrefix('8', 'springtrap');
		easteregg.animation.addByPrefix('9', 'old_ship');
		easteregg.animation.addByPrefix('10', 'clone');
		easteregg.animation.addByPrefix('11', 'strike');
		easteregg.animation.addByPrefix('12', 'orion');
		easteregg.animation.addByPrefix('13', 'star');

		easteregg.scale.set(scale,scale);
		easterEggGroup.add(easteregg);
		if (specific != 0)
			easteregg.animation.play('' + specific);
		else
			easteregg.animation.play('' + FlxG.random.int(1,13));

		if (easteregg.animation.curAnim.name == '10')
			{
				easteregg.x = FlxG.random.int(-500, -350);
			}

		FlxTween.tween(easteregg, {x: 1280, angle: FlxG.random.float(-90,90)}, FlxG.random.float(10,15), {onComplete:
			function(twn:FlxTween)
			{
				easteregg.kill();
			}});
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
				remove(ngSpr);
				remove(credGroup);
				FlxG.camera.flash(FlxColor.WHITE, 4);
				FlxTween.tween(gfDance, {x: 13}, 2, {ease: FlxEase.quadOut});
			skippedIntro = true;
		}
	}
}
