package
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import ui.MainUI;
	
	/**
	 * 简易2d骨骼动画导出工具
	 * @author lzm
	 */	
	[SWF(width="800",height="600")]
	public class BoneAnimationExport extends MainUI
	{
		private var appDomain:ApplicationDomain;//当前导出文档的信息
		private var clazzKeys:Vector.<String>;
		
		private var images:Dictionary;
		private var movies:Dictionary;
		
		private var imagesData:Object;
		private var moviesData:Object;
		
		public function BoneAnimationExport()
		{
			super();
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			addEventListener("onExportAnimationBtn",startExport);	
			
		}
		
		private function startExport(e:Event):void{
			if(exportPath == "" || swfPath == ""){
				return;
			}
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
			loader.load(new URLRequest(swfPath));
		}
		
		private function loadComplete(e:Event):void{
			clearMovies();
			
			export();
			
			function export():void{
				var loaderInfo:LoaderInfo = e.target as LoaderInfo;
				loaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
				
				appDomain = loaderInfo.content.loaderInfo.applicationDomain;
				clazzKeys = appDomain.getQualifiedDefinitionNames();
				
				parseExportTarget();
				exportImageToDisk();
				exportMovieInfosToDisk();
				
				loaderInfo.loader.unloadAndStop();
			}
		}
		
		/**
		 * 获取图片和动画对象
		 * */
		private function parseExportTarget():void{
			images = new Dictionary();
			movies = new Dictionary();
			imagesData = new Object();
			moviesData = new Object();
			
			var clazz:Class;
			var mc:MovieClip;
			var length:int = clazzKeys.length;
			for (var i:int = 0; i < length; i++) {
				clazz = appDomain.getDefinition(clazzKeys[i]) as Class;
				mc = new clazz() as MovieClip;
				if(mc.currentLabels.length == 0){
					images[getQualifiedClassName(mc)] = mc;
				}else{
					movies[getQualifiedClassName(mc)] = mc;
				}
			}
		}
		
		/**
		 * 输出图片到硬盘
		 * */
		private function exportImageToDisk():void{
			var k:String;
			var mc:MovieClip;
			var rect:Rectangle;
			var bitmapdata:BitmapData;
			var imageByteArrayData:ByteArray;
			var file:File;
			var fs:FileStream;
			var imgData:Object;
			for (k in images) {
				mc = images[k];
				
				mc.scaleX = mc.scaleY = exportScaleValue;
				addMcToTempContent(mc);
				
				rect = mc.getRect(tempContent);
				mc.x = -rect.x;
				mc.y = -rect.y;
				
				bitmapdata = new BitmapData(rect.width,rect.height,true,0);
				bitmapdata.draw(tempContent);
				
				imageByteArrayData = PNGEncoder.encode(bitmapdata);
				file = new File(exportPath+k+".png");
				
				fs = new FileStream();
				fs.open(file,FileMode.WRITE);
				fs.writeBytes(imageByteArrayData);
				fs.close();
				
				mc.scaleX = mc.scaleY = 1;
				addMovieClip(mc);
				
				imgData = {pivotX:formatNumber(rect.x / exportScaleValue) ,pivotY:formatNumber(rect.y / exportScaleValue)};
				imagesData[k] = imgData;
			}
		}
		
		/**
		 * 输出影片信息到硬盘 
		 * 
		 */		
		private function exportMovieInfosToDisk():void{
			var k:String;
			var mc:MovieClip;
			for(k in movies){
				mc = movies[k];
				moviesData[k] = getMovieInfos(mc);
			}
			
			var file:File = new File(exportPath + "movies.json");
			var fs:FileStream = new FileStream();
			var data:ByteArray = new ByteArray();
			data.writeUTFBytes(JSON.stringify({images:imagesData,movies:moviesData}));
			fs.open(file,FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
			
		}
		
		/**
		 * 获取一个movieClip的帧信息 
		 * @param movie
		 * @return 
		 * 
		 */		
		private function getMovieInfos(movie:MovieClip):Object{
			var frameInfos:Object = new Object();
			var labels:Array = movie.currentLabels;
			var currentLabel:FrameLabel;
			var totalFrames:int = movie.totalFrames;
			var currentFrame:int = 0;
			
			for (var i:int = 0; i < labels.length; i++) {
				currentLabel = labels[i];
				currentFrame = currentLabel.frame;
				movie.gotoAndStop(currentLabel.name);
				
				var lableFramesInfos:Array = [];
				var index:int = 0;
				while(movie.currentLabel == currentLabel.name && currentFrame <= totalFrames){
					
					var frameData:Array = [];
					for (var j:int = 0; j < movie.numChildren; j++) {
						var child:DisplayObject = movie.getChildAt(j);
						frameData[j] = [
							getQualifiedClassName(child),
							formatNumber(child.x),
							formatNumber(child.y),
							formatNumber(child.scaleX),
							formatNumber(child.scaleY),
							formatNumber(MatrixUtil.getSkewX(child.transform.matrix)),
							formatNumber(MatrixUtil.getSkewY(child.transform.matrix))
						];
					}
					
					currentFrame++;
					movie.gotoAndStop(currentFrame);
					
					lableFramesInfos[index] = frameData;
					index++;
				}
				frameInfos[currentLabel.name] = lableFramesInfos;
			}
			return {images:getMovieImages(movie),frameInfos:frameInfos};
		}
		
		/**
		 * 获取movieClip包含的图片 
		 * @return 
		 * 
		 */		
		private function getMovieImages(movie:MovieClip):Array{
			addMcToTempContent(movie);
			var totalFrames:int = movie.totalFrames;
			var movieImages:Array = [];//影片包含的图片有哪些
			var imageName:String;
			for (var i:int = 1; i <= totalFrames; i++) {
				movie.gotoAndStop(i);
				for (var j:int = 0; j < movie.numChildren; j++) {
					imageName = getQualifiedClassName(movie.getChildAt(j));
					if(movieImages.indexOf(imageName) == -1){
						movieImages.push(imageName);
					}
				}
			}
			return movieImages;
		}
	}
}