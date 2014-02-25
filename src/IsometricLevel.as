package
{
import flash.geom.Point;
import flash.utils.Dictionary;

import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.RenderTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

public class IsometricLevel extends DisplayObjectContainer
	{
		[Embed(source="../media/graphics/isotiles.png")]
		public static const AssetTex:Class;
		
		[Embed(source = "../media/graphics/isotiles.xml", mimeType = "application/octet-stream")]
		private static const AssetXml:Class;		
		
		private var texAtlas:TextureAtlas;
		private var rTex:RenderTexture;
		private var rTexImage:Image;
		private var screenOffset:Point=new Point(360,150);
		
		private var tileWidth:uint=40;
		private var regPoints:Dictionary=new Dictionary();
		
		private var groundArray:Array=[["tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png"],
			["tiles0005.png","tiles0005.png","tiles0005.png","tiles0003.png","tiles0003.png","tiles0003.png","tiles0003.png","tiles0001.png","tiles0001.png","tiles0005.png"],
			["tiles0005.png","tiles0005.png","tiles0005.png","tiles0002.png","tiles0002.png","tiles0002.png","tiles0003.png","tiles0001.png","tiles0001.png","tiles0005.png"],
			["tiles0005.png","tiles0002.png","tiles0005.png","tiles0003.png","tiles0003.png","tiles0002.png","tiles0003.png","tiles0001.png","tiles0001.png","tiles0005.png"],
			["tiles0005.png","tiles0002.png","tiles0003.png","tiles0003.png","tiles0005.png","tiles0002.png","tiles0003.png","tiles0001.png","tiles0001.png","tiles0005.png"],
			["tiles0005.png","tiles0002.png","tiles0002.png","tiles0002.png","tiles0002.png","tiles0002.png","tiles0003.png","tiles0001.png","tiles0001.png","tiles0005.png"],
			["tiles0005.png","tiles0003.png","tiles0003.png","tiles0003.png","tiles0003.png","tiles0003.png","tiles0005.png","tiles0001.png","tiles0001.png","tiles0005.png"],
			["tiles0005.png","tiles0001.png","tiles0001.png","tiles0005.png","tiles0005.png","tiles0001.png","tiles0001.png","tiles0001.png","tiles0001.png","tiles0005.png"],
			["tiles0005.png","tiles0001.png","tiles0001.png","tiles0001.png","tiles0001.png","tiles0001.png","tiles0001.png","tiles0001.png","tiles0001.png","tiles0005.png"],
			["tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png","tiles0005.png"]];
		private var overlayArray:Array=[["*","*","nonwalk0001.png","nonwalk0001.png","nonwalk0006.png","nonwalk0006.png","nonwalk0006.png","nonwalk0006.png","nonwalk0006.png","nonwalk0002.png"],
			["*","*","*","*","*","*","*","*","*","nonwalk0007.png"],
			["nonwalk0001.png","*","green castle.png","*","*","*","*","*","*","nonwalk0007.png"],
			["nonwalk0001.png","flag green.png","nonwalk00011.png","*","*","*","*","*","*","nonwalk0003.png"],
			["nonwalk0007.png","*","*","*","nonwalk0009.png","*","*","*","*","nonwalk0003.png"],
			["nonwalk0007.png","*","*","*","*","*","*","*","*","nonwalk0004.png"],
			["nonwalk0007.png","*","*","*","*","*","nonwalk0008.png","*","*","nonwalk0004.png"],
			["nonwalk0007.png","*","*","nonwalk0009.png","nonwalk0009.png","*","*","*","*","nonwalk0004.png"],
			["nonwalk0007.png","*","*","*","*","*","*","*","*","nonwalk00012.png"],
			["nonwalk0008.png","nonwalk0006.png","nonwalk0006.png","nonwalk0006.png","nonwalk0006.png","nonwalk0008.png","nonwalk0006.png","nonwalk0006.png","nonwalk0006.png","nonwalk0001.png"]];
		
		public function IsometricLevel()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(e:Event):void 
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			regPoints["blue castle.png"]	= new Point(-59.5,227.5);
			regPoints["flag blue.png"]		= new Point(11.5,44.5);
			regPoints["flag green.png"]		= new Point(12.5,41.5);
			regPoints["green castle.png"]	= new Point(-61.5,227.5);
			regPoints["nonwalk0001.png"]	= new Point(7.5,52);
			regPoints["nonwalk00010.png"]	= new Point(-11,16);
			regPoints["nonwalk00011.png"]	= new Point(-13,14);
			regPoints["nonwalk00012.png"]	= new Point(-3.5,88.5);
			regPoints["nonwalk00013.png"]	= new Point(-15,100.5);
			regPoints["nonwalk0002.png"]	= new Point(9.5,50);
			regPoints["nonwalk0003.png"]	= new Point(7.5,52);
			regPoints["nonwalk0004.png"]	= new Point(1.5,61);
			regPoints["nonwalk0005.png"]	= new Point(8.5,56);
			regPoints["nonwalk0006.png"]	= new Point(6.5,52);
			regPoints["nonwalk0007.png"]	= new Point(6.5,51);
			regPoints["nonwalk0008.png"]	= new Point(6.5,49);
			regPoints["nonwalk0009.png"]	= new Point(-12,19);
			
			var tex:Texture = Texture.fromBitmap(new AssetTex(),false);
			var img:Image;
			texAtlas = new TextureAtlas(tex,XML(new AssetXml()));
			
			rTex = new RenderTexture(stage.stageWidth,stage.stageHeight);
			rTexImage = new Image(rTex);
			addChild(rTexImage);
			
			var pt:Point=new Point();
			
			for(var i:int=0; i<groundArray.length; i++){
				for(var j:int=0; j<groundArray[0].length; j++){
					img = new Image(texAtlas.getTexture(String(groundArray[i][j]).split(".")[0]));
					pt.x = j * tileWidth;
					pt.y = i * tileWidth;
					pt = IsoHelper.cartToIso(pt);
					img.x = pt.x + screenOffset.x;
					img.y = pt.y + screenOffset.y;
					rTex.draw(img);
					
					//draw overlay
					if(overlayArray[i][j]!="*"){
						img = new Image(texAtlas.getTexture(String(overlayArray[i][j]).split(".")[0]));
						img.x = pt.x + screenOffset.x;
						img.y = pt.y + screenOffset.y;
						if(regPoints[overlayArray[i][j]]!=null){
							img.x += regPoints[overlayArray[i][j]].x;
							img.y -= regPoints[overlayArray[i][j]].y;
						}
						rTex.draw(img);
					}
				}
			}
			
			rTexImage.addEventListener(TouchEvent.TOUCH,onTouch);
		}
		private function onTouch(e:TouchEvent):void{
			var t:Touch = e.getTouch(rTexImage,TouchPhase.ENDED);
			if(t){
				var tp:Point = new Point(t.globalX,t.globalY);
				tp.x -= screenOffset.x;
				tp.y -= screenOffset.y;
				//image offset
				tp.x -= tileWidth;
				tp = IsoHelper.isoToCart(tp);
				//tp.x -= tileWidth/2;
				//tp.y += tileWidth/2;
				tp = IsoHelper.getTileIndices(tp,tileWidth);
				trace(tp,overlayArray[tp.y][tp.x]);
			}
		}
	}
}