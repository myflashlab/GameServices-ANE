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
	
	import com.doitflash.text.modules.MySprite;
	import com.doitflash.starling.utils.list.List;
	import com.doitflash.consts.Direction;
	import com.doitflash.consts.Orientation;
	import com.doitflash.consts.Easing;
	import com.doitflash.mobileProject.commonCpuSrc.DeviceInfo;
	import flash.data.EncryptedLocalStore;
	
	import com.myflashlab.air.extensions.gameServices.GameServices;
	import com.myflashlab.air.extensions.gameServices.google.events.AuthEvents;
	import com.myflashlab.air.extensions.gameServices.google.events.SnapshotsEvents;
	import com.myflashlab.air.extensions.gameServices.google.snapshot.Snapshot;
	import com.myflashlab.air.extensions.gameServices.google.snapshot.Conflict;
	import com.myflashlab.air.extensions.gameServices.google.player.PlayerLevel;
	import com.myflashlab.air.extensions.nativePermissions.PermissionCheck;
	
	import com.luaye.console.C;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 2/29/2016 8:34 AM
	 */
	public class SnapshotSample extends Sprite 
	{
		private var _exPermissions:PermissionCheck = new PermissionCheck();
		
		private const BTN_WIDTH:Number = 150;
		private const BTN_HEIGHT:Number = 60;
		private const BTN_SPACE:Number = 2;
		private var _txt:TextField;
		private var _body:Sprite;
		private var _list:List;
		private var _numRows:int = 1;
		
		[Embed(source = "saveCoverImage.png")]
		private var MyBitmap:Class;
		
		public function SnapshotSample():void 
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
			_txt.htmlText = "<font face='Arimo' color='#333333' size='20'><b>Game Services ANE V"+GameServices.VERSION+"</b>-\"Snapshot\"</font>";
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
			
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.RECEIVED, onSnapshotReceived);
			
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.SNAPSHOT_WINDOW_NEW, toSaveNewSnapshot);
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.SNAPSHOT_WINDOW_CANCELED, onSnapshotWindowCanceled);
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.SNAPSHOT_WINDOW_PICK, onSnapshotWindowPicked);
			
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.SAVE_STARTED, onSnapshotSaveStarted);
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.CONFLICTED, onSnapshotsConflicted);
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.SAVE_ENDED, onSnapshotSaveEnded);
			
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.LOAD_STARTED, onSnapshotLoadStarted);
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.LOAD_ENDED, onSnapshotLoadEnded);
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.GET_LIST, onSnapshotLoadList);
			
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.CONFLICT_RESOLVING_ERROR, onConflictResolvingError);
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.CONFLICT_RESOLVING_ENDED, onConflictResolvingEnded);
			
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.DELETE_STARTED, onDeleteStarted);
			GameServices.google.snapshots.addEventListener(SnapshotsEvents.DELETE_ENDED, onDeleteEnded);
			
			var btn00:MySprite = createBtn("login");
			btn00.addEventListener(MouseEvent.CLICK, login);
			_list.add(btn00);
			
			function login(e:MouseEvent):void
			{
				GameServices.google.auth.login();
			}
			
			// ----------------------------------------------------------------------
			
			var btn0:MySprite = createBtn("showNativeWindow");
			btn0.addEventListener(MouseEvent.CLICK, showNativeWindow);
			_list.add(btn0);
			
			function showNativeWindow(e:MouseEvent):void
			{
				GameServices.google.snapshots.showNativeWindow("my game saves!", true, true, 6);
			}
			
			// ----------------------------------------------------------------------
			
			var btn1:MySprite = createBtn("load list of saved games");
			btn1.addEventListener(MouseEvent.CLICK, getList);
			_list.add(btn1);
			
			function getList(e:MouseEvent):void
			{
				GameServices.google.snapshots.getList(true);
			}
			
			// ----------------------------------------------------------------------
			
			var btn2:MySprite = createBtn("delete a saved game data");
			btn2.addEventListener(MouseEvent.CLICK, removeSavedGame);
			_list.add(btn2);
			
			function removeSavedGame(e:MouseEvent):void
			{
				GameServices.google.snapshots.remove("mySave-74211");
			}
			
			// ----------------------------------------------------------------------
			
			var btn3:MySprite = createBtn("get info");
			btn3.addEventListener(MouseEvent.CLICK, getInfo);
			_list.add(btn3);
			
			function getInfo(e:MouseEvent):void
			{
				C.log("maxCoverImageSize = " + GameServices.google.snapshots.maxCoverImageSize());
				C.log("maxDataSize = " + GameServices.google.snapshots.maxDataSize());
			}
			
			// ----------------------------------------------------------------------
			
			
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
			C.log("---------------- onLoginSuccess");
			
			// some information about current logged in user.
			C.log("displayName = " + 				e.player.displayName);
			C.log("id = " + 						e.player.id);
			if (e.player.lastLevelUpTimestamp) // it will be null if the player has not leveled up yet!
			{
				C.log("lastLevelUpTimestamp = " + 	e.player.lastLevelUpTimestamp.toLocaleString());
			}
			C.log("title = " + 						e.player.title);
			C.log("xp = " + 						e.player.xp);
			
			var currLevel:PlayerLevel = e.player.currentLevel;
			C.log("currLevel.levelNumber = " + 		currLevel.levelNumber);
			C.log("currLevel.minXp = " + 			currLevel.minXp);
			C.log("currLevel.maxXp = " + 			currLevel.maxXp);
			
			var nextLevel:PlayerLevel = e.player.nextLevel;
			C.log("nextLevel.levelNumber = " + 		nextLevel.levelNumber);
			C.log("nextLevel.minXp = " + 			nextLevel.minXp);
			C.log("nextLevel.maxXp = " + 			nextLevel.maxXp);
			
			C.log("----------------");
		}
		
		private function onLoginError(e:AuthEvents):void
		{
			C.log("onLoginError: ", e.msg);
		}
		
// -----------------------------------------------------------------------------------------------------------------
		
		private function toSaveNewSnapshot(e:SnapshotsEvents):void
		{
			C.log("to Save New Snapshot...");
			
			// generate a unique name for this save instance.
			var name:String = "mySave-" + Number(Math.random().toFixed(5)) * 100000;
			
			// this is the game content you're saving
			var content:String = "save any string but you may find saving JSON Strings more helpful for saving complex game data.";
			
			// This is the description
			var description:String = "description of the save item";
			
			// (optional) cover image for your save-game item
			var coverImg:Bitmap = new MyBitmap() as Bitmap;
			var coverImgBmd:BitmapData = coverImg.bitmapData;
			
			// (optional) progress value
			var progressValue:Number = 20;
			
			// (optional) played time
			var playedTime:Number = 123456;
			
			GameServices.google.snapshots.save(name, content, description, coverImgBmd, progressValue, playedTime, GameServices.RESOLUTION_POLICY_MANUAL);
		}
		
		private function onSnapshotWindowCanceled(e:SnapshotsEvents):void
		{
			C.log("onSnapshotWindowCanceled");
		}
		
		private function onSnapshotWindowPicked(e:SnapshotsEvents):void
		{
			C.log("on Snapshot Window Picked: " + e.snapshotName);
			
			GameServices.google.snapshots.load(e.snapshotName);
		}
		
		private function onSnapshotReceived(e:SnapshotsEvents):void
		{
			C.log("on Snapshot Received: " + e.snapshotName);
			
			GameServices.google.snapshots.load(e.snapshotName);
		}
		
// -----------------------------------------------------------------------------------------------------------------

		private function onSnapshotSaveStarted(e:SnapshotsEvents):void
		{
			C.log("Save Started > " + e.snapshotName);
		}
		
		private function onSnapshotsConflicted(e:SnapshotsEvents):void
		{
			C.log("-------------- Snapshots Conflicted! You should resolve the conflict now.");
			
			C.log("conflict id = " + e.conflict.id);
			C.log(">>>>>>>>>");
			C.log("\t server version uniqueName = " + 					e.conflict.serverSnapshot.uniqueName);
			C.log("\t server version progressValue = " + 				e.conflict.serverSnapshot.progressValue);
			C.log("\t server version content = " + 						e.conflict.serverSnapshot.content);
			C.log("\t server version lastModifiedTimestamp = " +		e.conflict.serverSnapshot.lastModifiedTimestamp.toLocaleString());
			C.log(">>>>>>>>>");
			C.log("\t conflicted version uniqueName = " + 				e.conflict.conflictingSnapshot.uniqueName);
			C.log("\t conflicted version progressValue = " + 			e.conflict.conflictingSnapshot.progressValue);
			C.log("\t conflicted version content = " + 					e.conflict.conflictingSnapshot.content);
			C.log("\t conflicted version lastModifiedTimestamp = " + 	e.conflict.conflictingSnapshot.lastModifiedTimestamp.toLocaleString());
			
			C.log("--------------");
		}
		
		private function onSnapshotSaveEnded(e:SnapshotsEvents):void
		{
			// use the GamesStatusCodes class to see what each status code means
			C.log("Save Ended > " + e.status);
		}
		
// -----------------------------------------------------------------------------------------------------------------

		private function onSnapshotLoadStarted(e:SnapshotsEvents):void
		{
			C.log("Load Started > " + e.snapshotName);
		}
		
		private function onSnapshotLoadEnded(e:SnapshotsEvents):void
		{
			// use the GamesStatusCodes class to see what each status code means
			C.log("------------ Load Ended status: " + e.status);
			
			C.log("e.snapshot.uniqueName = " + e.snapshot.uniqueName);
			C.log("e.snapshot.description = " + e.snapshot.description);
			C.log("e.snapshot.lastModifiedTimestamp = " + e.snapshot.lastModifiedTimestamp.toLocaleDateString());
			C.log("e.snapshot.playedTime = " + e.snapshot.playedTime);
			C.log("e.snapshot.progressValue = " + e.snapshot.progressValue);
			C.log("e.snapshot.content = " + e.snapshot.content);
			
			C.log("------------");
		}
		
		private function onSnapshotLoadList(e:SnapshotsEvents):void
		{
			C.log("---------- onSnapshotLoadList");
			
			C.log("Number of available saved games: " + e.snapshotList.length);
			C.log("list of available saved games: " + e.snapshotList);
			
			C.log("------------");
		}
		
// -----------------------------------------------------------------------------------------------------------------
		
		private function onConflictResolvingError(e:SnapshotsEvents):void
		{
			C.log("on Conflict Resolving Error: " + e.msg);
		}
		
		private function onConflictResolvingEnded(e:SnapshotsEvents):void
		{
			// use the GamesStatusCodes class to see what each status code means
			C.log("on Conflict Resolving Ended: " + e.status);
		}
		
// -----------------------------------------------------------------------------------------------------------------
		
		private function onDeleteStarted(e:SnapshotsEvents):void
		{
			C.log("on Delete Started: " + e.snapshotName);
		}
		
		private function onDeleteEnded(e:SnapshotsEvents):void
		{
			// use the GamesStatusCodes class to see what each status code means
			C.log("on Delete Ended status: " + e.status);
			C.log("snapshot name: " + e.snapshotName);
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