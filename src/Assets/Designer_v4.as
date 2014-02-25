package Assets 
{
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.controls.Panel;
import feathers.controls.Radio;
import feathers.controls.ScrollContainer;
import feathers.controls.Scroller;
import feathers.layout.VerticalLayout;

//import helpers.IsoHelper;
//import Assets.IsoHelper;

//import starling.core.Starling;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Shape;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.RenderTexture;
import starling.textures.Texture;

import images.PNGEncoder;

public class Designer_v4 extends DisplayObjectContainer
	{
		
		private var groundCanvas:RenderTexture;
		private var topCanvas:RenderTexture;
		private var groundImage:Image;
		private var topImage:Image;
		private var tileWidth:uint=40;
		private var grid:Shape;
		
		private var floodBtn:Button;
		private var exportBtn:Button;
		private var loadBtn:Button;
		private var editBtn:Button;
		private var resetBtn:Button;
		private var doneBtn:Button;
		private var grabBtn:Button;
		private var topLayer:Radio;
		private var bottomLayer:Radio;
		private var container:ScrollContainer;
		
		private var file:File=new File();
		private var folderContents:Array=new Array();
		private var selectionDone:Boolean;
		private var stencilLoaded:Boolean;
		private var groundArray:Array;
		private var topArray:Array;
		private var stencil:Texture;
		private var stencilImage:Image;
		private var nonStdTile:Image;
		private var touch:Touch;
		private var _isPressed:Boolean;
		private var selectedItem:ImageLoader;
		private var urlReq:URLRequest;
		private var loader:Loader;
		private var matrix:Matrix=new Matrix();
		private var regDict:Dictionary=new Dictionary();
		private var editingTile:Boolean;
		private var editingArea:Sprite;
		private var regPtZero:Point = new Point(500,600);
		private var IsoHelper:Object;
		
		[RemoteClass]
		
		public function Designer_v4()
		{
			super();
			addEventListener(starling.events.Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:starling.events.Event):void 
		{
			removeEventListener(starling.events.Event.ADDED_TO_STAGE, init);
		}
		public function start():void{
			//entry point
			//grid = new Shape();
			grid=IsoHelper.createIsoGrid(33,33,tileWidth,tileWidth);
			//grid =  helpers.IsoHelper.createIsoGrid(33, 33, tileWidth, tileWidth);
			grid.x=512;
			grid.y=-294;
						
			groundCanvas=new RenderTexture(1024,768,true);
			topCanvas=new RenderTexture(1024,768,true);
			groundCanvas.draw(grid);
			topCanvas.draw(grid);
			groundImage=new Image(groundCanvas);
			topImage=new Image(topCanvas);
			addChild(groundImage);
			addChild(topImage);
			addChild(grid);
			//grid.width=1024;
			//grid.height=768;
			
			var panel:Panel=new Panel();
			
			panel.width=100;
			panel.height=768;
			panel.x=1024;
			addChild(panel);
			panel=new Panel();
			panel.width=stage.stageWidth;
			panel.height=132;
			panel.y=stage.stageHeight-panel.height;
			addChild(panel);
			
			container = new ScrollContainer();
			var layout:VerticalLayout =new VerticalLayout();
			layout.gap = 10;
			layout.padding = 10;
			container.layout = layout;
			container.x=1024;
			container.height=768;
			container.interactionMode=Scroller.INTERACTION_MODE_MOUSE;
			addChild( container );
			
			floodBtn=new Button();
			floodBtn.label="Flood Fill";
			floodBtn.x=10;
			floodBtn.y=panel.y+10;
			addChild(floodBtn);
			floodBtn.addEventListener(starling.events.Event.TRIGGERED,floodFill);
			
			loadBtn=new Button();
			loadBtn.label="Load Tiles";
			loadBtn.x=10;
			loadBtn.y=panel.y+50;
			addChild(loadBtn);
			loadBtn.addEventListener(starling.events.Event.TRIGGERED,browseForFolder);
			
			editBtn=new Button();
			editBtn.label="Edit Reg. Pt.";
			editBtn.x=100;
			editBtn.y=panel.y+10;
			addChild(editBtn);
			editBtn.addEventListener(starling.events.Event.TRIGGERED,createTileEditor);
			
			exportBtn=new Button();
			exportBtn.label="Export Level";
			exportBtn.x=100;
			exportBtn.y=panel.y+50;
			addChild(exportBtn);
			exportBtn.addEventListener(starling.events.Event.TRIGGERED,exportLevel);
			
			resetBtn=new Button();
			resetBtn.label="Reset Layer";
			resetBtn.x=190;
			resetBtn.y=panel.y+50;
			addChild(resetBtn);
			resetBtn.addEventListener(starling.events.Event.TRIGGERED,clearLayer);
			
			grabBtn=new Button();
			grabBtn.label="Screen Grab";
			grabBtn.x=190;
			grabBtn.y=panel.y+10;
			addChild(grabBtn);
			grabBtn.addEventListener(starling.events.Event.TRIGGERED,screenGrab);
			
			bottomLayer=new Radio();
			bottomLayer.label="Ground Layer";
			bottomLayer.x=280;
			bottomLayer.y=panel.y+50;
			addChild(bottomLayer);
			
			topLayer=new Radio();
			topLayer.label="Overlay Layer";
			topLayer.x=280;
			topLayer.y=panel.y+10;
			addChild(topLayer);
			
			file.addEventListener(flash.events.Event.SELECT, folderSelect);
			file.addEventListener(flash.events.Event.CANCEL, enableAll);
			
			editingTile=_isPressed=selectionDone=stencilLoaded=false;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, imgLoaded);
			
			stencil=Texture.fromColor(20,20,0xff0000,true);
			stencilImage=new Image(stencil);
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			addChild(stencilImage);
			stencilImage.x=600;
			stencilImage.y=770;
			
			nonStdTile=new Image(Texture.fromColor(20,20,0xff0000,true));
			editingArea=new Sprite();
			addChild(editingArea);
			var isoGrid:Shape = IsoHelper.createFilledSingleIsoGrid(tileWidth,tileWidth,0xcc0000);
			isoGrid.x = regPtZero.x;// + isoGrid.width / 2;
			isoGrid.y = regPtZero.y;
			editingArea.addChild(isoGrid);
			editingArea.addChild(nonStdTile);
			editingArea.visible=false;
			
			doneBtn=new Button();
			doneBtn.label="Done Edits";
			doneBtn.x=900;
			doneBtn.y=panel.y+20;
			editingArea.addChild(doneBtn);
			doneBtn.addEventListener(starling.events.Event.TRIGGERED,doneEditing);
		}
		
		
		
		private function doneEditing():void
		{
			regDict[folderContents[selectedItem.name].name]=new Point(int((nonStdTile.x - regPtZero.x)*10)/10,int((regPtZero.y - nonStdTile.y)*10)/10);
			editingTile=false;
			editingArea.visible=false;
			groundImage.visible=topImage.visible=grid.visible=true;
			enableAll();
		}
		private function createTileEditor(e:starling.events.Event):void
		{
			if (! stencilLoaded)
			{
				return;
			}
			disableAll();
			groundImage.visible=topImage.visible=grid.visible=false;
			var offset:Point = new Point(0,0);
			if (regDict[folderContents[selectedItem.name].name] != null)
			{
				offset = regDict[folderContents[selectedItem.name].name];
			}
			editingTile=true;
			editingArea.visible=true;
			
			
			nonStdTile.texture=stencil;
			nonStdTile.readjustSize();
			
			nonStdTile.x = regPtZero.x + offset.x;
			nonStdTile.y = regPtZero.y - offset.y;
			
		}
		private function onTouch(e:TouchEvent):void
		{
			touch = e.getTouch(this);
			if(!touch){
				return;
			}
			if (touch.phase == TouchPhase.BEGAN)
			{
				if(!editingTile&&touch.target is ImageLoader){
					stencilLoaded = false;
					selectItem(touch.target as ImageLoader);
				}
				_isPressed = true;
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				_isPressed = false;
				
			}
			
			if(!_isPressed||!stencilLoaded){
				return;
			}
			if(touch.globalX>1024||touch.globalY>768){
				return;
			}
			if(editingTile){
				nonStdTile.x = touch.globalX - nonStdTile.width / 2;
				nonStdTile.y = touch.globalY - nonStdTile.height / 2;
			}else{
				var pt:Point = touch.getLocation(grid);
				pt = IsoHelper.getTileIndices(IsoHelper.isoToCart(pt),tileWidth);
				changeArray(pt);
			}
		}
		
		private function changeArray(pt:Point):void
		{
			if (pt.x > -1 && pt.x < groundArray[0].length && pt.y > -1 && pt.y < groundArray.length)
			{
				if(bottomLayer.isSelected){
					groundArray[pt.y][pt.x] = "\"" + folderContents[selectedItem.name].name + "\"";
				}else if(topLayer.isSelected){
					topArray[pt.y][pt.x] = "\"" + folderContents[selectedItem.name].name + "\"";
				}
				drawTile(pt.x,pt.y,true);
			}
		}
		private function drawTile(col:int, row:int, doConvert:Boolean=false):void
		{
			var pt:Point=new Point();
			var offset:Point = new Point(0,0);
			if (regDict[folderContents[selectedItem.name].name] != null)
			{
				offset = regDict[folderContents[selectedItem.name].name];
				
			}
			pt.x=col;
			pt.y=row;
			if (doConvert)
			{
				pt=IsoHelper.get2dFromTileIndices(pt,tileWidth);
				pt=IsoHelper.cartToIso(pt);
				pt.x+=grid.x;
				pt.y+=grid.y;
			}
			matrix.ty = pt.y - offset.y;
			matrix.tx = pt.x + offset.x-tileWidth;//isoTileWidth/2;
			//trace("draw");
			if(bottomLayer.isSelected){
				groundCanvas.draw(stencilImage,matrix);
			}else if(topLayer.isSelected){
				topCanvas.draw(stencilImage,matrix);
			}
		}
		private function floodFill(e:starling.events.Event=null):void
		{
			if (! stencilLoaded)
			{
				return;
			}
			
			for (var i:uint=0; i<groundArray.length; i++)
			{//row
				for (var j:uint=0; j<groundArray[0].length; j++)
				{//col
					if(bottomLayer.isSelected){
						groundArray[i][j] = "\"" + folderContents[selectedItem.name].name + "\"";
					}else if(topLayer.isSelected){
						topArray[i][j] = "\"" + folderContents[selectedItem.name].name + "\"";
						
					}
				}
			}
			floodFillLayer();
		}
		private function floodFillLayer():void{
			var pos:Point=new Point();
			
			for (var i:uint=0; i<groundArray.length; i++)
			{//row
				for (var j:uint=0; j<groundArray[0].length; j++)
				{//col
					pos.x=j;
					pos.y=i;
					pos=IsoHelper.get2dFromTileIndices(pos,tileWidth);
					pos=IsoHelper.cartToIso(pos);
					pos.x+=grid.x;
					pos.y+=grid.y;
					drawTile(pos.x,pos.y);
				}
			}
			
		}
		private function clearLayer(e:starling.events.Event):void
		{
			if (! stencilLoaded)
			{
				return;
			}
			for (var i:uint=0; i<groundArray.length; i++)
			{//row
				for (var j:uint=0; j<groundArray[0].length; j++)
				{//col
					if(bottomLayer.isSelected){
						groundArray[i][j] = "\"*\"";
					}else if(topLayer.isSelected){
						topArray[i][j] = "\"*\"";
					}
				}
			}
			
			if(bottomLayer.isSelected)
			{
				groundCanvas.clear();
				groundCanvas.draw(grid);
			}else if(topLayer.isSelected){
				topCanvas.clear();
				topCanvas.draw(grid);
			}
			
		}
		private function selectItem(target:ImageLoader):void
		{
			if(selectedItem!=null){
				selectedItem.color=0xffffff;
			}
			selectedItem=target;
			selectedItem.color=0x00ff0033;
			loadStencil(selectedItem);
		}
		private function loadStencil(img:ImageLoader):void
		{
			urlReq = new URLRequest(String(img.source));
			loader.load(urlReq);
			//trace(folderContents[img.name].name,img.source);
		}
		private function imgLoaded(e:flash.events.Event):void
		{
			stencil.dispose();
			stencil=Texture.fromBitmap(loader.content as Bitmap, false,true);
			stencilImage.texture=stencil;
			stencilImage.readjustSize();
			stencilLoaded = true;
			//trace("stencil loaded");
			stencilImage.y=800-stencilImage.height/2;
		}
		
		private function populateTiles():void
		{//trace("folder has ",folderContents);
			var imgLoader:ImageLoader;
			
			for (var i:uint=0; i<folderContents.length; i++)
			{
				imgLoader=new ImageLoader();
				imgLoader.width=imgLoader.height=80;
				imgLoader.source=folderContents[i].url;
				container.addChild(imgLoader);
				imgLoader.name=i.toString();
				
				if(i==0){
					selectItem(imgLoader);
				}
			}
			
			groundArray=new Array();
			topArray=new Array();
			
			for (i=0; i<33; i++)
			{
				groundArray[i]=new Array();
				topArray[i]=new Array();
				for (var j:uint=0; j<33; j++)
				{
					groundArray[i].push("\"*\"");
					topArray[i].push("\"*\"");
				}
			}
			topLayer.isSelected =false;
			bottomLayer.isSelected =true;
			enableAll();
		}
		private function exportLevel(e:starling.events.Event):void{
			var docsDir:File = File.documentsDirectory;
			try
			{
				docsDir.browseForDirectory("Save As");
				docsDir.addEventListener(flash.events.Event.SELECT, saveTxtData);
			}
			catch (error:Error)
			{
				trace("Failed:", error.message);
			}
		}
		private function saveTxtData(e:flash.events.Event):void
		{
			var stub:String = "[=]";
			var newStub:String;
			var finalLevelString:String = "var groundArray:Array=";
			finalLevelString+=("[");
			for (var i:uint=0; i<groundArray.length; i++)
			{//row
				newStub = stub.replace("=",groundArray[i].concat());
				finalLevelString+=(newStub);
				if (i != groundArray.length - 1)
				{
					finalLevelString+=(",");
				}
			}
			finalLevelString+=("];");
			
			finalLevelString +=  "var topArray:Array=";
			finalLevelString+=("[");
			for (i=0; i<topArray.length; i++)
			{//row
				newStub = stub.replace("=",topArray[i].concat());
				finalLevelString+=(newStub);
				if (i != topArray.length - 1)
				{
					finalLevelString+=(",");
				}
			}
			finalLevelString+=("];");
			finalLevelString+=("var screenOffset:Point=new Point("+grid.x+","+grid.y+");");
			finalLevelString+=("var tileWidth:uint="+tileWidth+";");
			finalLevelString+=("var regPoints:Dictionary=/*points*/new Dictionary();");
			for (i=0; i<folderContents.length; i++)
			{
				if (regDict[folderContents[i].name] != null)
				{
					finalLevelString+=("regPoints[\""+folderContents[i].name+"\"]=new Point("+regDict[folderContents[i].name].x+","+regDict[folderContents[i].name].y+");");
				}
			}
			
			var txtFile:File = e.target as File;
			txtFile = txtFile.resolvePath(txtFile.nativePath + "/isoLevel.txt");
			
			// Write the image data to a file.
			var imageFileStream:FileStream = new FileStream();
			imageFileStream.open(txtFile, FileMode.WRITE);
			imageFileStream.writeUTFBytes(finalLevelString);
			imageFileStream.close();
			
		}
		private function screenGrab(e:starling.events.Event):void
		{
			var docsDir:File = File.documentsDirectory;
			try
			{
				docsDir.browseForDirectory("Save As");
				docsDir.addEventListener(flash.events.Event.SELECT, saveImgData);
			}
			catch (error:Error)
			{
				trace("Failed:", error.message);
			}
		}
		private function saveImgData(e:flash.events.Event):void
		{
			grid.visible=false;
			disableAll();
			// Encode the image as a PNG.
			var pngEncoder:PNGEncoder = new PNGEncoder();
			var imageByteArray:ByteArray = PNGEncoder.encode(this.stage.drawToBitmapData());
			
			var imageFile:File = e.target as File;
			imageFile = imageFile.resolvePath(imageFile.nativePath + "/isoLevel.png");
			
			// Write the image data to a file.
			var imageFileStream:FileStream = new FileStream();
			imageFileStream.open(imageFile, FileMode.WRITE);
			imageFileStream.writeBytes(imageByteArray);
			imageFileStream.close();
			
			pngEncoder = null;
			imageByteArray = null;
			
			enableAll();
			grid.visible=true;
		}
		private function startConversion():void
		{
			if (selectionDone)
			{
				disableAll();
				
				folderContents.splice(0);
				folderContents = null;
				folderContents=new Array();
				getFilesRecursive(file);
				
				if (folderContents.length > 0)
				{
					populateTiles();
				}
				else
				{
					enableAll();
					
				}
				
			}
			else
			{
				
			}
		}
		private function getFilesRecursive(folder:File):void
		{
			var contents:Array = folder.getDirectoryListing();
			var tempS:String;
			for (var i:uint = 0; i < contents.length; i++)
			{
				if (contents[i].isDirectory)
				{
					if (contents[i].name != "." && contents[i].name != "..")
					{
						//it's a directory
						getFilesRecursive(contents[i]);
					}
				}
				else
				{
					tempS = contents[i].name.toLowerCase();
					if (tempS.substr(tempS.length - 3,3) == "jpg" || tempS.substr(tempS.length - 3,3) == "png")
					{
						folderContents.push(contents[i]);
					}
				}
			}
			
		}
		private function browseForFolder(event:starling.events.Event):void
		{
			if(stencilLoaded){
				stencilLoaded = false;
				stencil.dispose();
			}
			disableAll();
			file.browseForDirectory("Please select assets directory...");
			
		}
		private function folderSelect(evt:flash.events.Event):void
		{
			enableAll();
			selectionDone = true;
			startConversion();
		}
		private function disableAll():void
		{
			grabBtn.isEnabled = resetBtn.isEnabled = floodBtn.isEnabled = exportBtn.isEnabled = loadBtn.isEnabled = editBtn.isEnabled = topLayer.isEnabled = bottomLayer.isEnabled = false;
			container.isEnabled=false;
		}
		private function enableAll():void
		{
			grabBtn.isEnabled=resetBtn.isEnabled=floodBtn.isEnabled=exportBtn.isEnabled=loadBtn.isEnabled=editBtn.isEnabled=topLayer.isEnabled=bottomLayer.isEnabled=true;
			container.isEnabled=true;
		}
	}
}