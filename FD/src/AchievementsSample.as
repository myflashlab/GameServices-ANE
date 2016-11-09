package 
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.StageOrientationEvent;
	import flash.events.StatusEvent;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.AutoCapitalize;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import com.doitflash.text.modules.MySprite;
	import com.doitflash.starling.utils.list.List;
	import com.doitflash.consts.Direction;
	import com.doitflash.consts.Orientation;
	import com.doitflash.consts.Easing;
	import com.doitflash.mobileProject.commonCpuSrc.DeviceInfo;
	import flash.data.EncryptedLocalStore;
	
	import com.myflashlab.air.extensions.gameServices.GameServices;
	import com.myflashlab.air.extensions.gameServices.google.events.AuthEvents;
	import com.myflashlab.air.extensions.gameServices.google.events.AchievementsEvents;
	import com.myflashlab.air.extensions.gameServices.google.achievement.Achievement;
	import com.myflashlab.air.extensions.gameServices.google.player.PlayerLevel;
	import com.myflashlab.air.extensions.nativePermissions.PermissionCheck;
	
	import com.luaye.console.C;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 2/29/2016 8:34 AM
	 */
	public class AchievementsSample extends Sprite 
	{
		private var _exPermissions:PermissionCheck = new PermissionCheck();
		
		private const BTN_WIDTH:Number = 150;
		private const BTN_HEIGHT:Number = 60;
		private const BTN_SPACE:Number = 2;
		private var _txt:TextField;
		private var _body:Sprite;
		private var _list:List;
		private var _numRows:int = 1;
		
		public function AchievementsSample():void 
		{
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate);
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			C.startOnStage(this, "`");
			C.commandLine = false;
			C.commandLineAllowed = false;
			C.x = 20;
			C.width = 250;
			C.height = 150;
			C.strongRef = true;
			C.visible = true;
			C.scaleX = C.scaleY = DeviceInfo.dpiScaleMultiplier;
			
			_txt = new TextField();
			_txt.autoSize = TextFieldAutoSize.LEFT;
			_txt.antiAliasType = AntiAliasType.ADVANCED;
			_txt.multiline = true;
			_txt.wordWrap = true;
			_txt.embedFonts = false;
			_txt.htmlText = "<font face='Arimo' color='#333333' size='20'><b>Game Services ANE V"+GameServices.VERSION+"</b>-\"Achievements\"</font>";
			_txt.scaleX = _txt.scaleY = DeviceInfo.dpiScaleMultiplier;
			this.addChild(_txt);
			
			_body = new Sprite();
			this.addChild(_body);
			
			_list = new List();
			_list.holder = _body;
			_list.itemsHolder = new Sprite();
			_list.orientation = Orientation.VERTICAL;
			_list.hDirection = Direction.LEFT_TO_RIGHT;
			_list.vDirection = Direction.TOP_TO_BOTTOM;
			_list.space = BTN_SPACE;
			
			checkPermissions();
		}
		
		private function onInvoke(e:InvokeEvent):void
		{
			NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvoke);
		}
		
		private function handleActivate(e:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}
		
		private function handleDeactivate(e:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
		}
		
		private function handleKeys(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.BACK)
            {
				e.preventDefault();
				NativeApplication.nativeApplication.exit();
            }
		}
		
		private function onResize(e:*=null):void
		{
			if (_txt)
			{
				_txt.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
				
				C.x = 0;
				C.y = _txt.y + _txt.height + 0;
				C.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
				C.height = 500 * (1 / DeviceInfo.dpiScaleMultiplier);
			}
			
			if (_list)
			{
				_numRows = Math.floor(stage.stageWidth / (BTN_WIDTH * DeviceInfo.dpiScaleMultiplier + BTN_SPACE));
				_list.row = _numRows;
				_list.itemArrange();
			}
			
			if (_body)
			{
				_body.y = stage.stageHeight - _body.height;
			}
		}
		
		private function checkPermissions():void
		{
			checkForStorage();
			
			function checkForStorage():void
			{
				var permissionState:int = _exPermissions.check(PermissionCheck.SOURCE_STORAGE);
				
				if (permissionState == PermissionCheck.PERMISSION_UNKNOWN || permissionState == PermissionCheck.PERMISSION_DENIED)
				{
					_exPermissions.request(PermissionCheck.SOURCE_STORAGE, onStorageRequestResult);
				}
				else
				{
					checkForContacts();
				}
			}
			
			function onStorageRequestResult($state:int):void
			{
				if ($state != PermissionCheck.PERMISSION_GRANTED)
				{
					C.log("You did not allow the app the required permissions!");
				}
				else
				{
					checkForContacts();
				}
			}
			
			function checkForContacts():void
			{
				var permissionState:int = _exPermissions.check(PermissionCheck.SOURCE_CONTACTS);
				
				if (permissionState == PermissionCheck.PERMISSION_UNKNOWN || permissionState == PermissionCheck.PERMISSION_DENIED)
				{
					_exPermissions.request(PermissionCheck.SOURCE_CONTACTS, onContactsRequestResult);
				}
				else
				{
					init();
				}
			}
			
			function onContactsRequestResult($state:int):void
			{
				if ($state != PermissionCheck.PERMISSION_GRANTED)
				{
					C.log("You did not allow the app the required permissions!");
				}
				else
				{
					init();
				}
			}
		}
		
		private function init():void
		{
			// initialize the Game Services and wait for a successful init call before doing anything else
			GameServices.init(false); // set this to 'true' when you are building for production
			GameServices.google.auth.addEventListener(AuthEvents.INIT, onInit);
		}
		
		private function onInit(e:AuthEvents):void
		{
			var result:String;
			
			switch (e.status) // status code indicating whether Game Services can run in your app or not. It can be one of following results:
			{
				case GameServices.SUCCESS:
					
					result = "GameServices.SUCCESS";
					onSuccessfullInit();
					onResize();
					
				break;
				case GameServices.SERVICE_MISSING:
					
					result = "GameServices.SERVICE_MISSING";
					
				break;
				case GameServices.SERVICE_UPDATING:
					
					result = "GameServices.SERVICE_UPDATING";
					
				break;
				case GameServices.SERVICE_VERSION_UPDATE_REQUIRED:
					
					result = "GameServices.SERVICE_VERSION_UPDATE_REQUIRED";
					
				break;
				case GameServices.SERVICE_DISABLED:
					
					result = "GameServices.SERVICE_DISABLED";
					
				break;
				case GameServices.SERVICE_INVALID:
					
					result = "GameServices.SERVICE_INVALID";
					
				break;
				default:
			}
			
			C.log("onInit result = " + result);
		}
		
		private function onSuccessfullInit():void
		{
			// add required listeners for the authentication process of the Game Services ANE
			GameServices.google.auth.addEventListener(AuthEvents.TRYING_SILENT_LOGIN, 		onSilentTry);
			GameServices.google.auth.addEventListener(AuthEvents.LOGIN, 					onLoginSuccess);
			GameServices.google.auth.addEventListener(AuthEvents.ERROR, 					onLoginError);
			
			GameServices.google.achievements.addEventListener(AchievementsEvents.LOAD, 		onAchievementsLoaded);
			GameServices.google.achievements.addEventListener(AchievementsEvents.UPDATE, 	onAchievementUpdated);
			GameServices.google.achievements.addEventListener(AchievementsEvents.ACHIEVEMENTS_WINDOW_DISMISSED, onAchievementsWindowDismissed);
			
			var btn00:MySprite = createBtn("login");
			btn00.addEventListener(MouseEvent.CLICK, login);
			_list.add(btn00);
			
			function login(e:MouseEvent):void
			{
				GameServices.google.auth.login();
			}
			
			// ------------------------------------------------------------
			
			var btn0:MySprite = createBtn("showNativeWindow");
			btn0.addEventListener(MouseEvent.CLICK, showNativeWindow);
			_list.add(btn0);
			
			function showNativeWindow(e:MouseEvent):void
			{
				GameServices.google.achievements.showNativeWindow();
			}
			
			// ------------------------------------------------------------
			
			var btn1:MySprite = createBtn("increment");
			btn1.addEventListener(MouseEvent.CLICK, increment);
			_list.add(btn1);
			
			function increment(e:MouseEvent):void
			{
				// adds the given number of steps to whatever value the current steps are.
				GameServices.google.achievements.increment("CgkI5Yi1zsAQEAIQBQ", 1, true);
			}
			
			// ------------------------------------------------------------
			
			var btn2:MySprite = createBtn("load");
			btn2.addEventListener(MouseEvent.CLICK, load);
			_list.add(btn2);
			
			function load(e:MouseEvent):void
			{
				C.log("wait for the achievements to load...");
				GameServices.google.achievements.load(true);
			}
			
			// ------------------------------------------------------------
			
			var btn3:MySprite = createBtn("reveal");
			btn3.addEventListener(MouseEvent.CLICK, reveal);
			_list.add(btn3);
			
			function reveal(e:MouseEvent):void
			{
				GameServices.google.achievements.reveal("CgkI5Yi1zsAQEAIQBQ", true);
			}
			
			// ------------------------------------------------------------
			
			var btn4:MySprite = createBtn("setSteps");
			btn4.addEventListener(MouseEvent.CLICK, setSteps);
			_list.add(btn4);
			
			function setSteps(e:MouseEvent):void
			{
				// increases the current number of steps to the provided number.
				GameServices.google.achievements.setSteps("CgkI5Yi1zsAQEAIQBQ", 3, true);
			}
			
			// ------------------------------------------------------------
			
			var btn5:MySprite = createBtn("unlock");
			btn5.addEventListener(MouseEvent.CLICK, unlock);
			_list.add(btn5);
			
			function unlock(e:MouseEvent):void
			{
				GameServices.google.achievements.unlock("CgkI5Yi1zsAQEAIQAg", true);
			}
			
			// ------------------------------------------------------------
		}
		
		private function onSilentTry(e:AuthEvents):void
		{
			C.log("canDoSilentLogin = ", e.canDoSilentLogin);
			C.log("If silent try is \"false\", it means that you have to login the user yourself using the \"GameServices.login();\" method.");
			C.log("But if it's \"true\", it means that the user had signed in before and he will be signed in again silently shortly. and you have to wait for the \"AuthEvents.LOGIN\" event.");
			
			if (e.canDoSilentLogin)
			{
				C.log("connecting to Game Services, please wait...");
			}
		}
		
		private function onLoginSuccess(e:AuthEvents):void
		{
			C.log("onLoginSuccess");
			
			// some information about current logged in user.
			trace("displayName = " + 				e.player.displayName);
			trace("id = " + 						e.player.id);
			if (e.player.lastLevelUpTimestamp) // it will be null if the player has not leveled up yet!
			{
				trace("lastLevelUpTimestamp = " + 	e.player.lastLevelUpTimestamp.toLocaleString());
			}
			trace("title = " + 						e.player.title);
			trace("xp = " + 						e.player.xp);
			
			var currLevel:PlayerLevel = e.player.currentLevel;
			trace("currLevel.levelNumber = " + 		currLevel.levelNumber);
			trace("currLevel.minXp = " + 			currLevel.minXp);
			trace("currLevel.maxXp = " + 			currLevel.maxXp);
			
			var nextLevel:PlayerLevel = e.player.nextLevel;
			trace("nextLevel.levelNumber = " + 		nextLevel.levelNumber);
			trace("nextLevel.minXp = " + 			nextLevel.minXp);
			trace("nextLevel.maxXp = " + 			nextLevel.maxXp);
		}
		
		private function onLoginError(e:AuthEvents):void
		{
			C.log("onLoginError: ", e.msg);
		}
		
		// -----------------------------------------------------------------------------------------------------
		
		private function onAchievementsLoaded(e:AchievementsEvents):void
		{
			// use the GamesStatusCodes class to see what each status code means
			C.log("onAchievements Loaded status = ", e.status);
			C.log("onAchievements Loaded data.length = ", e.achievements.length);
			
			var achievement:Achievement;
			for (var i:int = 0; i < e.achievements.length; i++) 
			{
				achievement = e.achievements[i];
				trace("\t id =", achievement.id);
				trace("\t name =", achievement.name);
				trace("\t description =", achievement.description);
				trace("\t state =", achievement.state); // Achievement.STATE_UNLOCKED, Achievement.STATE_REVEALED, Achievement.STATE_HIDDEN
				trace("\t type =", achievement.type); // Achievement.TYPE_STANDARD, Achievement.TYPE_INCREMENTAL
				trace("\t xpValue =", achievement.xpValue);
				
				if (achievement.lastUpdatedTimestamp) trace("\t lastUpdatedTimestamp =", achievement.lastUpdatedTimestamp.toLocaleString());
				else trace("\t lastUpdatedTimestamp = null");
				
				if (achievement.type == Achievement.TYPE_INCREMENTAL)
				{
					trace("\t currentSteps =", achievement.currentSteps);
					trace("\t totalSteps =", achievement.totalSteps);
				}
				
				trace("-------");
			}
		}
		
		private function onAchievementUpdated(e:AchievementsEvents):void
		{
			// use the GamesStatusCodes class to see what each status code means
			// NOTICE: on iOS, if there is any error, status will be always GamesStatusCodes.STATUS_INTERNAL_ERROR
			C.log("onAchievements Updated status = ", e.status);
			C.log("onAchievements Updated achievement ID = ", e.achievementId);
		}
		
		private function onAchievementsWindowDismissed(e:AchievementsEvents):void
		{
			C.log("on Achievements Window Dismissed");
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		/*private function setEncryptedLocalStore($key:String, $value:String):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes($value);
			
			EncryptedLocalStore.setItem($key, bytes);
		}
		
		private function getEncryptedLocalStore($key:String):String
		{
			var value:ByteArray = EncryptedLocalStore.getItem($key);
			
			if (!value) return null;
			
			return value.readUTFBytes(value.length);
		}*/
		
		private function createBtn($str:String):MySprite
		{
			var sp:MySprite = new MySprite();
			sp.addEventListener(MouseEvent.MOUSE_OVER,  onOver);
			sp.addEventListener(MouseEvent.MOUSE_OUT,  onOut);
			sp.addEventListener(MouseEvent.CLICK,  onOut);
			sp.bgAlpha = 1;
			sp.bgColor = 0xDFE4FF;
			sp.drawBg();
			sp.width = BTN_WIDTH * DeviceInfo.dpiScaleMultiplier;
			sp.height = BTN_HEIGHT * DeviceInfo.dpiScaleMultiplier;
			
			function onOver(e:MouseEvent):void
			{
				sp.bgAlpha = 1;
				sp.bgColor = 0xFFDB48;
				sp.drawBg();
			}
			
			function onOut(e:MouseEvent):void
			{
				sp.bgAlpha = 1;
				sp.bgColor = 0xDFE4FF;
				sp.drawBg();
			}
			
			var format:TextFormat = new TextFormat("Arimo", 16, 0x666666, null, null, null, null, null, TextFormatAlign.CENTER);
			
			var txt:TextField = new TextField();
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.antiAliasType = AntiAliasType.ADVANCED;
			txt.mouseEnabled = false;
			txt.multiline = true;
			txt.wordWrap = true;
			txt.scaleX = txt.scaleY = DeviceInfo.dpiScaleMultiplier;
			txt.width = sp.width * (1 / DeviceInfo.dpiScaleMultiplier);
			txt.defaultTextFormat = format;
			txt.text = $str;
			
			txt.y = sp.height - txt.height >> 1;
			sp.addChild(txt);
			
			return sp;
		}
	}
	
}