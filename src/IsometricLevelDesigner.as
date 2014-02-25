package
{

import feathers.themes.AeonDesktopTheme;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display3D.Context3DProfile;
import flash.events.Event;
import flash.system.Capabilities;

import starling.core.Starling;
import starling.events.Event;
import Assets.Designer_v4;

[SWF(backgroundColor = "#004400", frameRate = "30", width "1124", height = "900")]
	
	public class IsometricLevelDesigner extends Sprite
	{
		private var starling:Starling;
		public function IsometricLevelDesigner()
		{
			if (stage) init();
			else addEventListener(flash.events.Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:flash.events.Event = null):void 
		{
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			trace("starting starling ",Starling.VERSION);
			Starling.multitouchEnabled = false; // useful on mobile devices
			Starling.handleLostContext = true; // required on Windows , false for iOS & true for Android
			
			
			starling = new Starling(Designer_V4,stage,null,null,"auto",Context3DProfile.BASELINE);//"baseline");
			starling.showStats = false;
			starling.simulateMultitouch  = false;
			starling.enableErrorChecking = Capabilities.isDebugger;
			starling.antiAliasing=0;
			
			starling.start();
			
			// this event is dispatched when stage3D is set up
			starling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
		}
		private function onRootCreated(event:starling.events.Event, app:Designer_v4):void
		{
			new AeonDesktopTheme();
			app.start();
		}
			
	}
}