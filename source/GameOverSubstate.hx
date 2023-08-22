package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var doomBringer:FlxSprite;
	var background:FlxSprite;
	var backgroundPink:FlxSprite;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;

	public static var strikeDirection:String = '';

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-object-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf-object-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		strikeDirection = '';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		PlayState.instance.setOnLuas('inGameOver', true);

		background = new FlxSprite().makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.WHITE);
		background.screenCenter();
		background.scrollFactor.set(0,0);
		add(background);
		if (strikeDirection == '')
			background.visible = false;
		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(boyfriend);

		doomBringer = new FlxSprite(808, 41);
		doomBringer.frames = Paths.getSparrowAtlas('doom charge');
		doomBringer.animation.addByPrefix('charge', 'doom charge', 24, false);
		add(doomBringer);
		doomBringer.visible = false;

		backgroundPink = new FlxSprite().makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.fromRGB(255, 100, 100));
		backgroundPink.screenCenter();
		backgroundPink.scrollFactor.set(0,0);
		backgroundPink.visible = false;
		if (PlayState.SONG.stage == 'doom')
			{
				add(backgroundPink);
			}
			

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x + boyfriend.cameraPosition[0], boyfriend.getGraphicMidpoint().y+ boyfriend.cameraPosition[1]);

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		switch (strikeDirection)
		{
			case '':
				boyfriend.playAnim('firstDeath');
			case 'left':
				boyfriend.playAnim('deathLeft');
			case 'right':
				boyfriend.playAnim('deathRight');
			case 'up':
				boyfriend.playAnim('deathUp');
			case 'down':
				boyfriend.playAnim('deathDown');
		}

		if (PlayState.curStage == 'doom')
			{
				new FlxTimer().start(0.66, function(tmr:FlxTimer) {
					doomBringer.visible = true;
					doomBringer.animation.play('charge');
					
				});

				new FlxTimer().start(3, function(tmr:FlxTimer) {
					background.visible = true;
					boyfriend.color = FlxColor.BLACK;
					FlxG.camera.zoom += 0.05;
					new FlxTimer().start(0.08, function(tmr:FlxTimer) {
						background.visible = false;
						FlxG.camera.shake(0.002, 5);
						new FlxTimer().start(0.08, function(tmr:FlxTimer) {
							backgroundPink.visible = true;
							FlxG.camera.shake(0.002, 5);
						});
					});
				});
			}

		boyfriend.firstDeathAnim = true;


		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;

			WeekData.loadTheFirstEnabledMod();
			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('StrugglinOnAFridayNight'));
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}

		if (boyfriend.animation.curAnim != null && boyfriend.firstDeathAnim)
		{
			if(!isFollowingAlready && PlayState.curStage != 'doom')
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				coolStartDeath();
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		if (PlayState.curStage != 'doom' && strikeDirection == '')
			FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if (PlayState.curStage != 'doom')
				boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			if (PlayState.curStage != 'doom')
				FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
