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

//import TopDownLevel;
	
	//[SWF(backgroundColor = "#333333", frameRate = "30", width = "800", height = "600")]
	
	public class IsoGame3d extends Sprite
	{
		private var starling:Starling;
		
		public function IsoGame3d()
		{
			if (stage) init();
			else addEventListener(flash.events.Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:flash.events.Event=null):void
		{
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			trace("starting starling ",Starling.VERSION);
			Starling.multitouchEnabled = false; // useful on mobile devices
			Starling.handleLostContext = true; // required on Windows , false for iOS & true for Android
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//starling = new Starling(TopDownLevel, stage);
			//starling = new Starling(IsometricLevel, stage);
			starling = new Starling(Designer_v4, stage,null,null,"auto",Context3DProfile.BASELINE);//"baseline");
			
			starling.showStats = true;
			starling.antiAliasing = 1;
			//starling.enableErrorChecking = true;
			starling.enableErrorChecking = Capabilities.isDebugger;
			
			/*
			starling.stage3D.addEventListener(Event.CONTEXT3D_CREATE, function(e:Event):void 
			{
				starling.start();				
			});
			*/
			
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