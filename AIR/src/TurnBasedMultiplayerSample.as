package 
{
	import com.myflashlab.air.extensions.gameServices.google.multiplayer.Participant;
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
	import flash.data.EncryptedLocalStore;
	
	import com.doitflash.text.modules.MySprite;
	import com.doitflash.starling.utils.list.List;
	import com.doitflash.consts.Direction;
	import com.doitflash.consts.Orientation;
	import com.doitflash.consts.Easing;
	import com.doitflash.mobileProject.commonCpuSrc.DeviceInfo;
	
	import com.myflashlab.air.extensions.gameServices.GameServices;
	import com.myflashlab.air.extensions.gameServices.google.GamesStatusCodes;
	import com.myflashlab.air.extensions.gameServices.google.events.AuthEvents;
	import com.myflashlab.air.extensions.gameServices.google.events.TurnBasedEvents;
	import com.myflashlab.air.extensions.gameServices.google.multiplayer.turnBased.TurnBasedMatch;
	import com.myflashlab.air.extensions.gameServices.google.multiplayer.InvitationUIResult;
	import com.myflashlab.air.extensions.gameServices.google.player.PlayerLevel;
	
	import com.luaye.console.C;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 4/2/2016 4:20 PM
	 */
	public class TurnBasedMultiplayerSample extends Sprite 
	{
		private const BTN_WIDTH:Number = 150;
		private const BTN_HEIGHT:Number = 60;
		private const BTN_SPACE:Number = 2;
		private var _txt:TextField;
		private var _body:Sprite;
		private var _list:List;
		private var _numRows:int = 1;
		
		public function TurnBasedMultiplayerSample():void 
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
			_txt.htmlText = "<font face='Arimo' color='#333333' size='20'><b>Game Services ANE V"+GameServices.VERSION+"</b>-\"Turn-based Multiplayer\"</font>";
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
			
			// initialize the Game Services and wait for a successful init call before doing anything else
			GameServices.init(false); // set this to 'true' when you are building for production
			GameServices.google.auth.addEventListener(AuthEvents.INIT, onInit);
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
				C.height = 300 * (1 / DeviceInfo.dpiScaleMultiplier);
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
			
			GameServices.google.multiplayerTurnBased.addEventListener(TurnBasedEvents.MATCHES_WINDOW_DISMISSED, onMatchesWindowDismissed);
			GameServices.google.multiplayerTurnBased.addEventListener(TurnBasedEvents.MATCH_AVAILABLE, onTurnBasedMatchAvailable);
			GameServices.google.multiplayerTurnBased.addEventListener(TurnBasedEvents.INVITING_PLAYERS_RESULT, onInvitingPlayersResult);
			GameServices.google.multiplayerTurnBased.addEventListener(TurnBasedEvents.MATCH_CANCEL, onMatchCancelResult);
			GameServices.google.multiplayerTurnBased.addEventListener(TurnBasedEvents.MATCH_UPDATE, onMatchUpdateResult);
			GameServices.google.multiplayerTurnBased.addEventListener(TurnBasedEvents.MATCH_LEAVE, onMatchLeaveResult);
			GameServices.google.multiplayerTurnBased.addEventListener(TurnBasedEvents.MATCH_LOAD, onMatchLoadResult);
			GameServices.google.multiplayerTurnBased.addEventListener(TurnBasedEvents.MATCHES_LOAD, onMatchesLoadResult);
			GameServices.google.multiplayerTurnBased.addEventListener(TurnBasedEvents.MATCH_RECEIVED, onMatcheReceived);
			GameServices.google.multiplayerTurnBased.addEventListener(TurnBasedEvents.MATCH_REMOVED, onMatcheRemoved);
			
			
			var btn00:MySprite = createBtn("login");
			btn00.addEventListener(MouseEvent.CLICK, login);
			_list.add(btn00);
			
			function login(e:MouseEvent):void
			{
				GameServices.google.auth.login();
			}
			
			// ----------------------------------------------------------------------
			
			var btn01:MySprite = createBtn("showNativeWindowInvitePlayers");
			btn01.addEventListener(MouseEvent.CLICK, showNativeWindowInvitePlayers);
			_list.add(btn01);
			
			function showNativeWindowInvitePlayers(e:MouseEvent):void
			{
				GameServices.google.multiplayerTurnBased.showNativeWindowInvitePlayers(1, 3, 0, -1);
			}
			
			// ----------------------------------------------------------------------
			
			var btn02:MySprite = createBtn("createMatch");
			btn02.addEventListener(MouseEvent.CLICK, createMatch);
			_list.add(btn02);
			
			function createMatch(e:MouseEvent):void
			{
				// listen to TurnBasedEvents.TURN_BASED_MATCH_AVAILABLE for the results
				GameServices.google.multiplayerTurnBased.createMatch(1, 1, 0, -1, null);
			}
			
			// ----------------------------------------------------------------------
			
			var btn03:MySprite = createBtn("showNativeWindowInbox");
			btn03.addEventListener(MouseEvent.CLICK, showNativeWindowInbox);
			_list.add(btn03);
			
			function showNativeWindowInbox(e:MouseEvent):void
			{
				// listen to TurnBasedEvents.MATCHES_WINDOW_DISMISSED for the results
				GameServices.google.multiplayerTurnBased.showNativeWindowInbox();
			}
			
			// ----------------------------------------------------------------------
			
			var btn05:MySprite = createBtn("load matches");
			btn05.addEventListener(MouseEvent.CLICK, toLoadMatches);
			_list.add(btn05);
			
			function toLoadMatches(e:MouseEvent):void
			{
				// listen to TurnBasedEvents.MATCHES_LOAD for the results
				GameServices.google.multiplayerTurnBased.loadMatchesByStatus(	GameServices.SORT_ORDER_MOST_RECENT_FIRST, 
																				TurnBasedMatch.MATCH_TURN_STATUS_INVITED,
																				TurnBasedMatch.MATCH_TURN_STATUS_MY_TURN,
																				TurnBasedMatch.MATCH_TURN_STATUS_THEIR_TURN,
																				TurnBasedMatch.MATCH_TURN_STATUS_COMPLETE)
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
		
// -----------------------------------------------------------------------------------------------------------------
		
		private function onMatchesWindowDismissed(e:TurnBasedEvents):void
		{
			C.log("onMatchesWindowDismissed");
		}
		
		private function onTurnBasedMatchAvailable(e:TurnBasedEvents):void
		{
			C.log("onTurnBasedMatchAvailable > status = " + e.status);
			
			if (!e.match) return;
			
			traceTheMatch(e.match);
		}
		
		private function onInvitingPlayersResult(e:TurnBasedEvents):void
		{
			if (e.invitationResult == GameServices.INVITING_PLAYERS_RESULT_OK)
			{
				C.log("invitation window OK");
			}
			else if (e.invitationResult == GameServices.INVITING_PLAYERS_RESULT_CANCELED)
			{
				C.log("invitation window canceled");	
			}
		}
		
		private function onMatchCancelResult(e:TurnBasedEvents):void
		{
			C.log("onMatchCancelResult > status = " + e.status);
			C.log("onMatchCancelResult > matchId = " + e.matchId);
		}
		
		private function onMatchUpdateResult(e:TurnBasedEvents):void
		{
			C.log("onMatchUpdateResult > status = " + e.status);
			
			onTurnBasedMatchAvailable(e);
		}
		
		private function onMatchLeaveResult(e:TurnBasedEvents):void
		{
			C.log("onMatchLeaveResult > status = " + e.status);
			
			onTurnBasedMatchAvailable(e);
		}
		
		private function onMatchLoadResult(e:TurnBasedEvents):void
		{
			C.log("onMatchLoadResult > status = " + e.status);
			
			onTurnBasedMatchAvailable(e);
		}
		
		private function onMatchesLoadResult(e:TurnBasedEvents):void
		{
			C.log("on Matches Load Result > status = " + e.status);
			
			if (e.completedMatches)
			{
				for each(var match1:TurnBasedMatch in e.completedMatches)
				{
					traceTheMatch(match1);
				}
			}
			
			if (e.myTurnMatches)
			{
				for each(var match2:TurnBasedMatch in e.myTurnMatches)
				{
					traceTheMatch(match2);
				}
			}
			
			if (e.theirTurnMatches)
			{
				for each(var match3:TurnBasedMatch in e.theirTurnMatches)
				{
					traceTheMatch(match3);
				}
			}
		}
		
		private function onMatcheReceived(e:TurnBasedEvents):void
		{
			C.log("on Matche Received > status = " + e.status);
			traceTheMatch(e.match);
		}
		
		private function onMatcheRemoved(e:TurnBasedEvents):void
		{
			C.log("onMatcheRemoved id = " + e.matchId);
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		private function traceTheMatch(match:TurnBasedMatch):void
		{
			var participant:Participant = match.descriptionParticipant;
			
			trace("-------------------- traceTheMatch");
			trace("availableAutoMatchSlots = " + match.availableAutoMatchSlots);
			trace("canRematch = " + match.canRematch());
			trace("creationTimestamp = " + match.creationTimestamp.toLocaleDateString());
			trace("creatorId = " + match.creatorId);
			trace("data = " + match.data);
			trace("description = " + match.description);
			
			if (participant)
			{
				trace("participant.displayName = " + participant.displayName);
				trace("participant.isConnectedToRoom = " + participant.isConnectedToRoom);
				trace("participant.participantId = " + participant.participantId);
				trace("participant.status = " + participant.status);
			}
			
			trace("descriptionParticipantId = " + match.descriptionParticipantId);
			trace("getParticipantIds = " + match.getParticipantIds());
			trace("isLocallyModified = " + match.isLocallyModified);
			trace("lastUpdatedTimestamp = " + match.lastUpdatedTimestamp.toLocaleDateString());
			trace("lastUpdaterId = " + match.lastUpdaterId);
			trace("matchId = " + match.matchId);
			trace("matchNumber = " + match.matchNumber);
			trace("pendingParticipantId = " + match.pendingParticipantId);
			trace("previousMatchData = " + match.previousMatchData);
			trace("rematchId = " + match.rematchId);
			trace("status = " + match.status);
			trace("turnStatus = " + match.turnStatus);
			trace("variant = " + match.variant);
			trace("version = " + match.version);
			
			trace(" ");
			if (match.data) trace("\t This is a game that has already started!");
			else trace("\t This game has just started by the caller user!");
			trace(" ");
			
			
			var playerId:String = GameServices.google.players.currentPlayer.id;
			var myParticipantId:String = match.getParticipantId(playerId);
			trace("myParticipantId = " + myParticipantId);
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
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