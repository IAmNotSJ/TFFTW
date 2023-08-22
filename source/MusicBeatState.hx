package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxBasic;

class MusicBeatState extends FlxUIState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	public static var camBeat:FlxCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		camBeat = FlxG.camera;
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		super.create();

		if(!skip) {
			openSubState(new CustomFadeTransition(0.7, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static var songLoadingScreen:String = "";
	public static var nextGhostAllowed:Bool = false;

	static function loadingScreen(state:MusicBeatState, camera:FlxCamera, ?trans:CustomFadeTransition){
		if(!nextGhostAllowed) {
			NoGhost.disable();
		}
		nextGhostAllowed = false;

		var loading = new FlxSprite().loadGraphic(Paths.image("loading/load"));
		loading.setGraphicSize(FlxG.width, FlxG.height);
		loading.updateHitbox();
		loading.screenCenter();
		loading.scrollFactor.set(0, 0);
		state.add(loading);
		if(trans != null) {
			trans.add(loading);
			loading.cameras = trans.cameras;
		}
		if(camera != null) {
			loading.cameras = [camera];
		}
		loading.antialiasing = ClientPrefs.globalAntialiasing;
		loading.draw();
		songLoadingScreen = "";

		var starf = new FlxSprite(1007, 370);
		starf.frames = Paths.getSparrowAtlas('loading/starf spin');
		starf.animation.addByPrefix('spin', 'starf spin', 24, true);
		starf.animation.play('spin');
		starf.scale.set(3,3);
		state.add(starf);
		if(trans != null) {
			trans.add(starf);
			starf.cameras = trans.cameras;
		}
		if(camera != null) {
			starf.cameras = [camera];
		}
		starf.antialiasing = false;
		starf.draw();

		var black = new FlxSprite().makeGraphic(Std.int(FlxG.width), Std.int(FlxG.height), FlxColor.BLACK);
		black.setGraphicSize(FlxG.width, FlxG.height);
		black.updateHitbox();
		black.screenCenter();
		black.scrollFactor.set(0, 0);
		state.add(black);
		if(trans != null) {
			trans.add(black);
			black.cameras = trans.cameras;
		}
		if(camera != null) {
			black.cameras = [camera];
		}
		black.antialiasing = ClientPrefs.globalAntialiasing;
		black.draw();
		FlxTween.tween(black, {alpha: 0}, 0.2);
	}

	public static function switchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if(!FlxTransitionableState.skipNextTransIn) {
			var camera = CustomFadeTransition.nextCamera;
			var trans = new CustomFadeTransition(0.6, false);
			leState.openSubState(trans);
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					if(songLoadingScreen != "") {
						loadingScreen(leState, camera, trans);

						new FlxTimer().start(3, function(tmr:FlxTimer)
							{
								FlxG.resetState();
							});
					}
					else
						FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					if(songLoadingScreen != "") {
						loadingScreen(leState, camera, trans);

						new FlxTimer().start(3, function(tmr:FlxTimer)
							{
								FlxG.switchState(nextState);
							});
					}
					else
						FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		if(songLoadingScreen != "") {
			loadingScreen(leState, FlxG.cameras.list[FlxG.cameras.list.length - 1]);

			new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					FlxG.switchState(nextState);
				});
		}
		else
			FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
