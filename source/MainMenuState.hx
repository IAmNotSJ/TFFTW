package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

import WeekData;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC
	public static var tfftwVersion:String = '1.0.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story',
		'freeplay',
		'credits',
		'options',
		'tsftw'
	];
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var mainWeekHighscore:Int = 0;

	var trophy_hat:FlxSprite;
	var trophy_doom:FlxSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/bg'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0,0);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		trophy_hat = new FlxSprite(31, 310);
		
		if (FlxG.save.data.swagMainWeek)
			trophy_hat.loadGraphic(Paths.image('mainmenu/trophy_hat_gold'));
		else
			trophy_hat.loadGraphic(Paths.image('mainmenu/trophy_hat_bronze'));
		trophy_hat.updateHitbox();
		trophy_hat.scrollFactor.set(0,0);
		trophy_hat.antialiasing = ClientPrefs.globalAntialiasing;
		if (FlxG.save.data.mainWeekBeat)
			add(trophy_hat);

		trophy_doom = new FlxSprite(910, 337);
		if (FlxG.save.data.swagDoomBeat)
			trophy_doom.loadGraphic(Paths.image('mainmenu/trophy_doom_gold'));
		else
			trophy_doom.loadGraphic(Paths.image('mainmenu/trophy_doom_bronze'));
		trophy_doom.updateHitbox();
		trophy_doom.scrollFactor.set(0,0);
		trophy_doom.antialiasing = ClientPrefs.globalAntialiasing;
		if (FlxG.save.data.doomBeat)
			add(trophy_doom);

		var bar:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('mainmenu/bar'));
		bar.updateHitbox();
		bar.screenCenter(X);
		bar.scrollFactor.set(0,0);
		bar.antialiasing = ClientPrefs.globalAntialiasing;
		bar.y = FlxG.height - bar.height + 40;
		add(bar);
		

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(25 + (i * 500), 610);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/buttons');
			menuItem.animation.addByPrefix('idle', optionShit[i] + "_menu", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(1, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, 12, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, 30, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, 48, 0, "The Funkin For The World v" + tfftwVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		if (FlxG.save.data.mainWeekBeat && FlxG.save.data.swagMainWeek)
			{
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
					{
						addSparkle(false);
					}, 0);
			}
		if (FlxG.save.data.doomBeat && FlxG.save.data.swagDoomBeat)
			{
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
					{
						addSparkle(true);
					}, 0);
			}

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}
 
			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'tsftw')
				{
					CoolUtil.browserLoad('https://www.youtube.com/@TheStrugglefortheWorld');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

	}

	function addSparkle(right:Bool = false)
		{
			var sparkle:FlxSprite = new FlxSprite();
			sparkle.frames = Paths.getSparrowAtlas('mainmenu/sparkle');
			sparkle.animation.addByPrefix('appear', 'sparkle glow', 24, false);
			sparkle.scrollFactor.set(0,0);
			sparkle.animation.play('appear');
			add(sparkle);
			var scale:Float = FlxG.random.float(0.9, 1.1);
			sparkle.scale.set(scale, scale);
			
			if (!right)
				sparkle.setPosition(FlxG.random.int(31,295), FlxG.random.int(310, 618));
			else
				sparkle.setPosition(FlxG.random.int(910,1192), FlxG.random.int(337, 590));
			new FlxTimer().start(0.708, function(tmr:FlxTimer)
				{
					sparkle.kill();
				});
		}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				var offset:Float = 0;
				switch (curSelected)
				{
					case 0:
						offset = -7;
					case 1:
						offset = 21.75 * 1;
					case 2:
						offset = 21.75 * 4 - 20;
					case 3:
						offset = 21.75 * 4 - 1;
					case 4:
						offset = 21.75 * 4 - 5;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x - 25 - offset, camFollow.y);
				spr.centerOffsets();
			}
		});
	}
}
