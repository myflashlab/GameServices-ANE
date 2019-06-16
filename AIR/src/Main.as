package
{
import com.myflashlab.air.extensions.googleGames.Games;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.display.Sprite;
import com.doitflash.consts.Direction;
import com.doitflash.consts.Orientation;
import com.doitflash.mobileProject.commonCpuSrc.DeviceInfo;
import com.doitflash.starling.utils.list.List;
import com.doitflash.text.modules.MySprite;

import com.luaye.console.C;

import flash.desktop.NativeApplication;
import flash.desktop.SystemIdleMode;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import com.myflashlab.air.extensions.googleGames.*;
import com.myflashlab.air.extensions.gSignIn.*;
import com.myflashlab.air.extensions.dependency.OverrideAir;

/**
 * ...
 * @author Hadi Tavakoli - 3/3/18 6:52 PM
 */
public class Main extends Sprite
{
	private const BTN_WIDTH:Number = 150;
	private const BTN_HEIGHT:Number = 60;
	private const BTN_SPACE:Number = 2;
	private var _txt:TextField;
	private var _body:Sprite;
	private var _list:List;
	private var _numRows:int = 1;
	
	[Embed(source = "saveCoverImage.png")]
	private var MyBitmap:Class;
	private var coverImg:Bitmap = new MyBitmap() as Bitmap;
	
	private var _room:Room;
	private var _otherParticipantId:String;
	
	public function Main()
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
		_txt.htmlText = "<font face='Arimo' color='#333333' size='20'><b>Game Services ANE V" + Games.VERSION + "</font>";
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
		
		init();
		onResize();
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
	
	private function onResize(e:* = null):void
	{
		if(_txt)
		{
			_txt.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
			
			C.x = 0;
			C.y = _txt.y + _txt.height + 0;
			C.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
			C.height = 300 * (1 / DeviceInfo.dpiScaleMultiplier);
		}
		
		if(_list)
		{
			_numRows = Math.floor(stage.stageWidth / (BTN_WIDTH * DeviceInfo.dpiScaleMultiplier + BTN_SPACE));
			_list.row = _numRows;
			_list.itemArrange();
		}
		
		if(_body)
		{
			_body.y = stage.stageHeight - _body.height;
		}
	}
	
	private function init():void
	{
		// Remove OverrideAir debugger in production builds
		OverrideAir.enableDebugger(function ($ane:String, $class:String, $msg:String):void
		{
			trace($ane+" ("+$class+") "+$msg);
		});
		
		// depending on your app design, you must customize the Signin Options
		// If you want GoogleGames signin only, do like below:
		var options:GSignInOptions = new GSignInOptions();
		options.gamesSignIn = true; // set to true if you are working with Google Games Services ANE.
		options.requestId = false;
		options.requestProfile = false;
		options.requestEmail = false;
		options.requestScopes = [
			"https://www.googleapis.com/auth/games",
			GScopes.DRIVE_APPFOLDER
		];
		
		// then pass the options to the initialization method of the GSignIn ANE
		GSignIn.init(options);
		
		// Finally, add listeners
		GSignIn.listener.addEventListener(GSignInEvents.SILENT_SIGNIN_SUCCESS, onSilentSigninSuccess);
		GSignIn.listener.addEventListener(GSignInEvents.SILENT_SIGNIN_FAILURE, onSilentSigninFailure);
		GSignIn.listener.addEventListener(GSignInEvents.SIGNIN_SUCCESS, onSigninSuccess);
		GSignIn.listener.addEventListener(GSignInEvents.SIGNIN_FAILURE, onSigninFailure);
		GSignIn.listener.addEventListener(GSignInEvents.SIGNOUT_SUCCESS, onSignoutSuccess);
		GSignIn.listener.addEventListener(GSignInEvents.SIGNOUT_FAILURE, onSignoutFailure);
		
		// check if user is already loggedin or not
		var account:GAccount = GSignIn.signedInAccount;
		if(account)
		{
			initGames();
		}
		else
		{
			// You should first check if user can signin silently, if she can't, use the signin() method
			GSignIn.silentSignIn();
		}
		
		addSignInBtn();
	}
	
	private function addSignInBtn():void
	{
		var btn0:MySprite = createBtn("signin");
		btn0.addEventListener(MouseEvent.CLICK, signin);
		_list.add(btn0);
		
		function signin(e:MouseEvent):void
		{
			if(!GSignIn.signedInAccount) GSignIn.signin();
			else C.log("You are already signed in!");
		}
	}
	
	private function onSignoutSuccess(e:GSignInEvents):void
	{
		_list.removeAll();
		addSignInBtn();
		
		C.log("onSignoutSuccess");
		Games.dismiss();
	}
	
	private function onSignoutFailure(e:GSignInEvents):void
	{
		C.log("onSignoutFailure: " + e.msg);
	}
	
	private function onSigninSuccess(e:GSignInEvents):void
	{
		trace("e.account.scopes: "+ e.account.scopes);
		C.log("----------------");
		C.log("onSigninSuccess");
		initGames();
	}
	
	private function onSigninFailure(e:GSignInEvents):void
	{
		C.log("onSigninFailure: " + e.msg);
	}
	
	private function onSilentSigninSuccess(e:GSignInEvents):void
	{
		C.log("----------------");
		C.log("onSilentSigninSuccess");
		initGames();
	}
	
	private function onSilentSigninFailure(e:GSignInEvents):void
	{
		/*
			check the meaning of failure code here:
			https://developers.google.com/android/reference/com/google/android/gms/auth/api/signin/GoogleSignInStatusCodes
			https://developers.google.com/android/reference/com/google/android/gms/common/api/CommonStatusCodes
		 */
		C.log("onSilentSigninFailure: " + e.msg);
	}
	
	private function initGames():void
	{
		Games.init();
		
		if(!Games.listener.hasEventListener(GamesEvents.CONNECT_SUCCESS))
		{
			Games.listener.addEventListener(GamesEvents.CONNECT_SUCCESS, onConnectSuccess);
			Games.listener.addEventListener(GamesEvents.CONNECT_FAILURE, onConnectFailure);
			Games.listener.addEventListener(GamesEvents.ACTIVITY_RESULT_CODES, onActivityResultCodes);
		}
		
		if(!Games.realtime.hasEventListener(GamesEvents.REAL_TIME_ROOM_CREATED))
		{
			Games.realtime.addEventListener(GamesEvents.REAL_TIME_ROOM_CREATED, onRoomCreated);
			Games.realtime.addEventListener(GamesEvents.REAL_TIME_ROOM_CONNECTED, onRoomConnected);
			Games.realtime.addEventListener(GamesEvents.REAL_TIME_ROOM_JOINED, onRoomJoined);
			Games.realtime.addEventListener(GamesEvents.REAL_TIME_ROOM_LEFT, onRoomLeft);
			
			Games.realtime.addEventListener(GamesEvents.ROOM_STATUS_UPDATED, onRoomStatusUpdated);
			Games.realtime.addEventListener(GamesEvents.WAITING_ROOM_WINDOW_DISMISSED, onWaitingRoomDismissed);
			Games.realtime.addEventListener(GamesEvents.WAITING_ROOM_WINDOW_FAILURE, onWaitingRoomFailure);
			Games.realtime.addEventListener(GamesEvents.WAITING_ROOM_RESULT, onWaitingRoomResult);
			
			Games.realtime.addEventListener(GamesEvents.MESSAGE_SENT, onMessageSent);
			Games.realtime.addEventListener(GamesEvents.MESSAGE_RECEIVED, onMessageReceived);
			
			Games.invitations.addEventListener(GamesEvents.INVITE_PLAYERS_WINDOW_FAILURE, onInvitingPlayersWinFailure);
			Games.invitations.addEventListener(GamesEvents.INVITING_PLAYERS_RESULT, onInvitingPlayersResult);
			Games.invitations.addEventListener(GamesEvents.INVITATION_RECEIVED, onInvitationReceived);
			Games.invitations.addEventListener(GamesEvents.INVITATION_REMOVED, onInvitationRemoved);
		}
		
		function onConnectFailure(e:GamesEvents):void
		{
			C.log("onConnectFailure: " + e.msg);
		}
		
		function onActivityResultCodes(e:GamesEvents):void
		{
			// https://developers.google.com/android/reference/com/google/android/gms/games/GamesActivityResultCodes
			C.log("onActivityResultCodes: " + e.status);
		}
	}
	
	private function onConnectSuccess(e:GamesEvents):void
	{
		_list.removeAll();
		
		var btn1:MySprite = createBtn("signout");
		btn1.addEventListener(MouseEvent.CLICK, signout);
		_list.add(btn1);
		
		function signout(e:MouseEvent):void
		{
			if(GSignIn.signedInAccount) GSignIn.signOut();
			else C.log("You are NOT signed in!");
		}
		
		
		trace("------------------------------------");
		trace("displayName: " + e.player.displayName);
		trace("id: " + e.player.id);
		trace("lastPlayedTimestamp: " + e.player.lastPlayedTimestamp);
		trace("title: " + e.player.title);
		trace("retrievedTimestamp: " + e.player.retrievedTimestamp);
		trace("hasHiResImage: " + e.player.hasHiResImage);
		trace("hasIconImage: " + e.player.hasIconImage);
		
		if(e.player.levelInfo)
		{
			trace("levelInfo.currentXpTotal: " + e.player.levelInfo.currentXpTotal);
			trace("levelInfo.isMaxLevel: " + e.player.levelInfo.isMaxLevel);
			trace("levelInfo.lastLevelUpTimestamp: " + e.player.levelInfo.lastLevelUpTimestamp);
			
			trace("levelInfo.currentLevel.levelNumber: " + e.player.levelInfo.currentLevel.levelNumber);
			trace("levelInfo.currentLevel.maxXp: " + e.player.levelInfo.currentLevel.maxXp);
			trace("levelInfo.currentLevel.minXp: " + e.player.levelInfo.currentLevel.minXp);
			
			trace("levelInfo.nextLevel.levelNumber: " + e.player.levelInfo.nextLevel.levelNumber);
			trace("levelInfo.nextLevel.maxXp: " + e.player.levelInfo.nextLevel.maxXp);
			trace("levelInfo.nextLevel.minXp: " + e.player.levelInfo.nextLevel.minXp);
		}
		trace("------------------------------------");
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn001:MySprite = createBtn("Achievements: Window", 0xd6dcfc);
		btn001.addEventListener(MouseEvent.CLICK, showAchievementsNativeWindow);
		_list.add(btn001);
		
		function showAchievementsNativeWindow(e:MouseEvent):void
		{
			if(!Games.achievements.hasEventListener(GamesEvents.ACHIEVEMENTS_WINDOW_FAILURE))
				Games.achievements.addEventListener(GamesEvents.ACHIEVEMENTS_WINDOW_FAILURE, onAchievementsWindowFailure);
			
			if(!Games.achievements.hasEventListener(GamesEvents.ACHIEVEMENTS_WINDOW_DISMISSED))
				Games.achievements.addEventListener(GamesEvents.ACHIEVEMENTS_WINDOW_DISMISSED, onAchievementsWindowDismissed);
			
			Games.achievements.showNativeWindow();
		}
		
		function onAchievementsWindowFailure(e:GamesEvents):void
		{
			trace("onAchievementsWindowFailure: " + e.msg);
		}
		
		function onAchievementsWindowDismissed(e:GamesEvents):void
		{
			trace("onAchievementsWindowDismissed");
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn002:MySprite = createBtn("Achievements: Load", 0xd6dcfc);
		btn002.addEventListener(MouseEvent.CLICK, loadAchievements);
		_list.add(btn002);
		
		function loadAchievements(e:MouseEvent):void
		{
			if(!Games.achievements.hasEventListener(GamesEvents.ACHIEVEMENT_LOAD_RESULT))
				Games.achievements.addEventListener(GamesEvents.ACHIEVEMENT_LOAD_RESULT, onAchievementsLoadResult);
			
			Games.achievements.load(true);
		}
		
		function onAchievementsLoadResult(e:GamesEvents):void
		{
			if(e.status == Games.SUCCESS)
			{
				trace("Number of loaded achievements: " + e.achievements.length);
				
				for (var i:int = 0; i < e.achievements.length; i++)
				{
					var achievement:Achievement = e.achievements[i];
					trace("\t id =", achievement.id);
					trace("\t name =", achievement.name);
					trace("\t description =", achievement.description);
					trace("\t state =", achievement.state); // Achievement.STATE_UNLOCKED, Achievement.STATE_REVEALED, Achievement.STATE_HIDDEN
					trace("\t type =", achievement.type); // Achievement.TYPE_STANDARD, Achievement.TYPE_INCREMENTAL
					trace("\t xpValue =", achievement.xpValue);
					trace("\t lastUpdatedTimestamp =", achievement.lastUpdatedTimestamp);
					
					if (achievement.type == Achievement.TYPE_INCREMENTAL)
					{
						trace("\t currentSteps =", achievement.currentSteps);
						trace("\t totalSteps =", achievement.totalSteps);
					}
					
					achievement.loadRevealedImage(false, function ($achievement:Achievement, $image:File):void
					{
						if($image)
						{
							trace("onRevealedImageLoaded: " + $image.nativePath);
							trace("RevealedImage.size: " + $image.size);
						}
						else
						{
							trace("RevealedImage NOT AVAILABLE!")
						}
					});
				}
			}
			else if(e.status == Games.FAILURE)
			{
				trace("onAchievementsLoadResult failure: " + e.msg);
			}
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn003:MySprite = createBtn("Achievements: increment", 0xd6dcfc);
		btn003.addEventListener(MouseEvent.CLICK, incrementAchievements);
		_list.add(btn003);
		
		function incrementAchievements(e:MouseEvent):void
		{
			if(!Games.achievements.hasEventListener(GamesEvents.ACHIEVEMENT_UPDATE_RESULT))
				Games.achievements.addEventListener(GamesEvents.ACHIEVEMENT_UPDATE_RESULT, onAchievementsUpdate);
			
			Games.achievements.increment("CgkI5Yi1zsAQEAIQAQ", 1, true); // if false, listener won't be dispatched
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn004:MySprite = createBtn("Achievements: reveal", 0xd6dcfc);
		btn004.addEventListener(MouseEvent.CLICK, revealAchievements);
		_list.add(btn004);
		
		function revealAchievements(e:MouseEvent):void
		{
			if(!Games.achievements.hasEventListener(GamesEvents.ACHIEVEMENT_UPDATE_RESULT))
				Games.achievements.addEventListener(GamesEvents.ACHIEVEMENT_UPDATE_RESULT, onAchievementsUpdate);
			
			Games.achievements.reveal("CgkI5Yi1zsAQEAIQAQ", true); // if false, listener won't be dispatched
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn005:MySprite = createBtn("Achievements: setSteps", 0xd6dcfc);
		btn005.addEventListener(MouseEvent.CLICK, setStepsAchievements);
		_list.add(btn005);
		
		function setStepsAchievements(e:MouseEvent):void
		{
			if(!Games.achievements.hasEventListener(GamesEvents.ACHIEVEMENT_UPDATE_RESULT))
				Games.achievements.addEventListener(GamesEvents.ACHIEVEMENT_UPDATE_RESULT, onAchievementsUpdate);
			
			Games.achievements.setSteps("CgkI5Yi1zsAQEAIQAQ", 5000, true); // if false, listener won't be dispatched
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn006:MySprite = createBtn("Achievements: unlock", 0xd6dcfc);
		btn006.addEventListener(MouseEvent.CLICK, unlockAchievements);
		_list.add(btn006);
		
		function unlockAchievements(e:MouseEvent):void
		{
			if(!Games.achievements.hasEventListener(GamesEvents.ACHIEVEMENT_UPDATE_RESULT))
				Games.achievements.addEventListener(GamesEvents.ACHIEVEMENT_UPDATE_RESULT, onAchievementsUpdate);
			
			Games.achievements.unlock("CgkI5Yi1zsAQEAIQBA", true); // if false, listener won't be dispatched
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		function onAchievementsUpdate(e:GamesEvents):void
		{
			if(e.status == Games.SUCCESS)
			{
				trace("onAchievementsUpdate for " + e.achievementId + " success. the achievement is unlocked? " + e.isAchievementUnlocked);
				
				/**
				 * IMPORTANT:
				 *
				 * e.isAchievementUnlocked is irrelevant when Games.achievements.reveal is called!
				 * if the achievement is unlocked, calling Games.achievements.reveal would do nothing because
				 * the achievement is already unlocked and revealed. You should use e.isAchievementUnlocked when
				 * increment, setSteps or unlock
				 */
			}
			else if(e.status == Games.FAILURE)
			{
				trace("onAchievementsUpdate for " + e.achievementId + " failure: " + e.msg);
			}
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn010:MySprite = createBtn("GamesMetadata: currGame", 0xd0c4ef);
		btn010.addEventListener(MouseEvent.CLICK, getGamesMetadata);
		_list.add(btn010);
		
		function getGamesMetadata(e:MouseEvent):void
		{
			Games.metadata.currentGame(onCurrentGameCallback);
		}
		
		function onCurrentGameCallback($game:Game, $error:Error):void
		{
			if($error)
			{
				trace($error.message);
				return;
			}
			
			trace("achievementTotalCount: " + $game.achievementTotalCount);
			trace("applicationId: " + $game.applicationId);
			trace("description: " + $game.description);
			trace("developerName: " + $game.developerName);
			trace("displayName: " + $game.displayName);
			trace("hasGamepadSupport: " + $game.hasGamepadSupport);
			trace("isRealTimeMultiplayerEnabled: " + $game.isRealTimeMultiplayerEnabled);
			trace("isTurnBasedMultiplayerEnabled: " + $game.isTurnBasedMultiplayerEnabled);
			trace("leaderboardCount: " + $game.leaderboardCount);
			trace("primaryCategory: " + $game.primaryCategory);
			trace("secondaryCategory: " + $game.secondaryCategory);
			trace("snapshotsEnabled: " + $game.snapshotsEnabled);
			trace("themeColor: " + $game.themeColor);
			
			$game.loadIconImage(false, function ($file:File):void
			{
				trace("$game.loadIconImage:" + $file.nativePath);
			});
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn011:MySprite = createBtn("GamesMetadata: info", 0xd0c4ef);
		btn011.addEventListener(MouseEvent.CLICK, getGamesInfo);
		_list.add(btn011);
		
		function getGamesInfo(e:MouseEvent):void
		{
			Games.metadata.getAppId(function ($appId:String, $error:Error):void
			{
				if($error)
				{
					trace($error.message);
					return;
				}
				
				trace("Games.metadata.getAppId: " + $appId);
			});
			
			Games.metadata.getCurrentAccountName(function ($accountName:String, $error:Error):void
			{
				if($error)
				{
					trace($error.message);
					return;
				}
				
				trace("Games.metadata.getCurrentAccountName: " + $accountName);
			});
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn012:MySprite = createBtn("GamesSettings: Window", 0xd0c4ef);
		btn012.addEventListener(MouseEvent.CLICK, showGamesSettingsNativeWindow);
		_list.add(btn012);
		
		function showGamesSettingsNativeWindow(e:MouseEvent):void
		{
			if(!Games.listener.hasEventListener(GamesEvents.SETTINGS_WINDOW_FAILURE))
				Games.listener.addEventListener(GamesEvents.SETTINGS_WINDOW_FAILURE, onSettingsWindowFailure);
			
			if(!Games.listener.hasEventListener(GamesEvents.SETTING_WINDOW_DISMISSED))
				Games.listener.addEventListener(GamesEvents.SETTING_WINDOW_DISMISSED, onSettingsWindowDismissed);
			
			Games.showSettingsWindow();
		}
		
		function onSettingsWindowFailure(e:GamesEvents):void
		{
			trace("onSettingsWindowFailure: " + e.msg);
		}
		
		function onSettingsWindowDismissed(e:GamesEvents):void
		{
			trace("onSettingsWindowDismissed");
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn020:MySprite = createBtn("Leaderboards: Window by id", 0xafb6db);
		btn020.addEventListener(MouseEvent.CLICK, showLeaderboardsNativeWindowById);
		_list.add(btn020);
		
		function showLeaderboardsNativeWindowById(e:MouseEvent):void
		{
			if(!Games.leaderboards.hasEventListener(GamesEvents.LEADERBOARDS_WINDOW_FAILURE))
				Games.leaderboards.addEventListener(GamesEvents.LEADERBOARDS_WINDOW_FAILURE, onLeaderboardsWindowFailure);
			
			if(!Games.leaderboards.hasEventListener(GamesEvents.LEADERBOARDS_WINDOW_DISMISSED))
				Games.leaderboards.addEventListener(GamesEvents.LEADERBOARDS_WINDOW_DISMISSED, onLeaderboardsWindowDismissed);
			
			Games.leaderboards.showNativeWindow("CgkI5Yi1zsAQEAIQBg", Leaderboards.TIME_SPAN_ALL_TIME);
		}
		
		function onLeaderboardsWindowFailure(e:GamesEvents):void
		{
			trace("onLeaderboardsWindowFailure: " + e.leaderboardId + " " + e.msg);
		}
		
		function onLeaderboardsWindowDismissed(e:GamesEvents):void
		{
			trace("onLeaderboardsWindowDismissed");
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn021:MySprite = createBtn("Leaderboards: Window all", 0xafb6db);
		btn021.addEventListener(MouseEvent.CLICK, showLeaderboardsNativeWindow);
		_list.add(btn021);
		
		function showLeaderboardsNativeWindow(e:MouseEvent):void
		{
			if(!Games.leaderboards.hasEventListener(GamesEvents.LEADERBOARDS_WINDOW_FAILURE))
				Games.leaderboards.addEventListener(GamesEvents.LEADERBOARDS_WINDOW_FAILURE, onLeaderboardsWindowFailure);
			
			if(!Games.leaderboards.hasEventListener(GamesEvents.LEADERBOARDS_WINDOW_DISMISSED))
				Games.leaderboards.addEventListener(GamesEvents.LEADERBOARDS_WINDOW_DISMISSED, onLeaderboardsWindowDismissed);
			
			Games.leaderboards.showNativeWindowAll();
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn022:MySprite = createBtn("Leaderboards: submitScore", 0xafb6db);
		btn022.addEventListener(MouseEvent.CLICK, submitScore);
		_list.add(btn022);
		
		var rawScore:int = 0;
		
		function submitScore(e:MouseEvent):void
		{
			if(!Games.leaderboards.hasEventListener(GamesEvents.LEADERBOARDS_SUBMIT_SCORE_RESULT))
					Games.leaderboards.addEventListener(GamesEvents.LEADERBOARDS_SUBMIT_SCORE_RESULT, onLeaderboardSubmitScoreResult);
			
			Games.leaderboards.submitScore("CgkI5Yi1zsAQEAIQBg", ++rawScore, "ScoreMetadata_"+rawScore, true);
		}
		
		function onLeaderboardSubmitScoreResult(e:GamesEvents):void
		{
			if(e.status == Games.SUCCESS)
			{
				trace("------------- Games.leaderboards.submitScore");
				trace("onLeaderboardSubmitScoreResult(" + e.leaderboardId + ") Success, playerId: " + e.playerId);
				trace("scoreToday: " + e.scoreToday.formattedScore + ", is newBest: " + e.scoreToday.newBest);
				trace("scoreThisWeek: " + e.scoreThisWeek.formattedScore + ", is newBest: " + e.scoreThisWeek.newBest);
				trace("scoreAllTime: " + e.scoreAllTime.formattedScore + ", is newBest: " + e.scoreAllTime.newBest);
				trace("-------------");
			}
			else if(e.status == Games.FAILURE)
			{
				trace("onLeaderboardSubmitScoreResult(" + e.leaderboardId + ") Failure: " + e.msg);
			}
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn023:MySprite = createBtn("Leaderboards: loadCurrentPlayerScore", 0xafb6db);
		btn023.addEventListener(MouseEvent.CLICK, loadCurrentPlayerScore);
		_list.add(btn023);
		
		function loadCurrentPlayerScore(e:MouseEvent):void
		{
			if(!Games.leaderboards.hasEventListener(GamesEvents.LEADERBOARDS_LOAD_PLAYER_SCORE_RESULT))
					Games.leaderboards.addEventListener(GamesEvents.LEADERBOARDS_LOAD_PLAYER_SCORE_RESULT, onLoadCurrentPlayerScore);
			
			Games.leaderboards.loadCurrentPlayerScore("CgkI5Yi1zsAQEAIQBg", Leaderboards.TIME_SPAN_ALL_TIME);
		}
		
		function onLoadCurrentPlayerScore(e:GamesEvents):void
		{
			if(e.status == Games.SUCCESS)
			{
				trace("------------- Games.leaderboards.loadCurrentPlayerScore");
				trace("displayRank: " + e.score.displayRank);
				trace("displayScore: " + e.score.displayScore);
				trace("rank: " + e.score.rank);
				trace("rawScore: " + e.score.rawScore);
				trace("scoreHolderDisplayName: " + e.score.scoreHolderDisplayName);
				trace("scoreMetadata: " + e.score.scoreMetadata);
				trace("timestamp: " + e.score.timestamp);
				trace("-------------");
			}
			else if(e.status == Games.FAILURE)
			{
				trace("onLoadCurrentPlayerScore(" + e.leaderboardId + ") Failure: " + e.msg);
			}
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn024:MySprite = createBtn("Leaderboards: loadMetadata", 0xafb6db);
		btn024.addEventListener(MouseEvent.CLICK, loadMetadata);
		_list.add(btn024);
		
		function loadMetadata(e:MouseEvent):void
		{
			if(!Games.leaderboards.hasEventListener(GamesEvents.LEADERBOARDS_LOAD_META_DATA_RESULT))
					Games.leaderboards.addEventListener(GamesEvents.LEADERBOARDS_LOAD_META_DATA_RESULT, onLoadMetadataResult);
					
			Games.leaderboards.loadMetadata(null, true);
		}
		
		function onLoadMetadataResult(e:GamesEvents):void
		{
			if(e.status == Games.SUCCESS)
			{
				trace("------------- Games.leaderboards.loadMetadata");
				for(var i:int=0; i < e.leaderboards.length; i++)
				{
					var currLeaderboard:Leaderboard = e.leaderboards[i];
					trace("displayName: " + currLeaderboard.displayName);
					trace("leaderboardId: " + currLeaderboard.leaderboardId);
					trace("scoreOrder: " + currLeaderboard.scoreOrder);
					trace("-");
				}
				trace("-------------");
			}
			else if(e.status == Games.FAILURE)
			{
				trace("onLoadMetadataResult Failure: " + e.msg);
			}
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn025:MySprite = createBtn("Leaderboards: load Centered Scores", 0xafb6db);
		btn025.addEventListener(MouseEvent.CLICK, loadPlayerCenteredScores);
		_list.add(btn025);
		
		function loadPlayerCenteredScores(e:MouseEvent):void
		{
			if(!Games.leaderboards.hasEventListener(GamesEvents.LEADERBOARDS_LOAD_SCORES_RESULT))
					Games.leaderboards.addEventListener(GamesEvents.LEADERBOARDS_LOAD_SCORES_RESULT, onLoadScoresResult);
			
			Games.leaderboards.loadPlayerCenteredScores("CgkI5Yi1zsAQEAIQBg", Leaderboards.TIME_SPAN_ALL_TIME, 10, true);
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn026:MySprite = createBtn("Leaderboards: load more scores", 0xafb6db);
		btn026.addEventListener(MouseEvent.CLICK, loadMoreScores);
		_list.add(btn026);
		
		function loadMoreScores(e:MouseEvent):void
		{
			if(!Games.leaderboards.hasEventListener(GamesEvents.LEADERBOARDS_LOAD_SCORES_RESULT))
				Games.leaderboards.addEventListener(GamesEvents.LEADERBOARDS_LOAD_SCORES_RESULT, onLoadScoresResult);
			
			Games.leaderboards.loadMoreScores(Games.PAGE_DIRECTION_NONE);
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn027:MySprite = createBtn("Leaderboards: load top scores", 0xafb6db);
		btn027.addEventListener(MouseEvent.CLICK, loadTopScores);
		_list.add(btn027);
		
		function loadTopScores(e:MouseEvent):void
		{
			if(!Games.leaderboards.hasEventListener(GamesEvents.LEADERBOARDS_LOAD_SCORES_RESULT))
				Games.leaderboards.addEventListener(GamesEvents.LEADERBOARDS_LOAD_SCORES_RESULT, onLoadScoresResult);
			
			Games.leaderboards.loadTopScores("CgkI5Yi1zsAQEAIQBg", Leaderboards.TIME_SPAN_ALL_TIME, 10, true);
		}
		
		function onLoadScoresResult(e:GamesEvents):void
		{
			if(e.status == Games.SUCCESS)
			{
				trace("------------- Games.leaderboards.loadPlayerCenteredScores/loadMoreScores/loadTopScores");
				for(var i:int=0; i < e.scores.length; i++)
				{
					var score:Score = e.scores[i];
					trace("displayRank: " + e.score.displayRank);
					trace("displayScore: " + e.score.displayScore);
					trace("rank: " + e.score.rank);
					trace("rawScore: " + e.score.rawScore);
					trace("scoreHolderDisplayName: " + e.score.scoreHolderDisplayName);
					trace("scoreMetadata: " + e.score.scoreMetadata);
					trace("timestamp: " + e.score.timestamp);
					trace("-");
				}
				trace("-------------");
			}
			else if(e.status == Games.FAILURE)
			{
				trace("onLoadScoresResult Failure: " + e.msg);
			}
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn030:MySprite = createBtn("TheEvents: load", 0x9ebce2);
		btn030.addEventListener(MouseEvent.CLICK, loadEvents);
		_list.add(btn030);
		
		function loadEvents(e:MouseEvent):void
		{
			Games.events.load(true, function ($events:Array, $error:Error):void
			{
				if($error)
				{
					trace($error.message);
					return;
				}
				
				trace("--------------- Games.events.load");
				
				for(var i:int=0; i < $events.length; i++)
				{
					var currEvent:TheEvent = $events[i];
					trace("description: " + currEvent.description);
					trace("eventId: " + currEvent.eventId);
					trace("formattedValue: " + currEvent.formattedValue);
					trace("isVisible: " + currEvent.isVisible);
					trace("name: " + currEvent.name);
					trace("value: " + currEvent.value);
					trace("-");
				}
				
				trace("---------------");
			});
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn031:MySprite = createBtn("TheEvents: loadById", 0x9ebce2);
		btn031.addEventListener(MouseEvent.CLICK, loadEventsByIds);
		_list.add(btn031);
		
		function loadEventsByIds(e:MouseEvent):void
		{
			Games.events.loadByIds(true, ["CgkI5Yi1zsAQEAIQCg", "CgkI5Yi1zsAQEAIQCw"], function ($events:Array, $error:Error):void
			{
				if($error)
				{
					trace($error.message);
					return;
				}
				
				trace("--------------- Games.events.load");
				
				for(var i:int=0; i < $events.length; i++)
				{
					var currEvent:TheEvent = $events[i];
					trace("description: " + currEvent.description);
					trace("eventId: " + currEvent.eventId);
					trace("formattedValue: " + currEvent.formattedValue);
					trace("isVisible: " + currEvent.isVisible);
					trace("name: " + currEvent.name);
					trace("value: " + currEvent.value);
					trace("-");
				}
				
				trace("---------------");
			});
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn032:MySprite = createBtn("TheEvents: increment", 0x9ebce2);
		btn032.addEventListener(MouseEvent.CLICK, incrementEvents);
		_list.add(btn032);
		
		function incrementEvents(e:MouseEvent):void
		{
			Games.events.increment("CgkI5Yi1zsAQEAIQCg", 7);
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn040:MySprite = createBtn("Snapshots: native window", 0x9ed8e2);
		btn040.addEventListener(MouseEvent.CLICK, snapshotsNativeWindow);
		_list.add(btn040);
		
		function snapshotsNativeWindow(e:MouseEvent):void
		{
			if(!Games.snapshots.hasEventListener(GamesEvents.SNAPSHOT_WINDOW_FAILURE))
			{
				Games.snapshots.addEventListener(GamesEvents.SNAPSHOT_WINDOW_FAILURE, onSnapshotWindowFailure);
				Games.snapshots.addEventListener(GamesEvents.SNAPSHOT_WINDOW_DISMISSED, onSnapshotWindowDismissed);
				Games.snapshots.addEventListener(GamesEvents.SNAPSHOT_WINDOW_NEW, onSnapshotWindowNew);
				Games.snapshots.addEventListener(GamesEvents.SNAPSHOT_WINDOW_PICK, onSnapshotWindowPick);
			}
			
			Games.snapshots.showNativeWindow("my game saves!", true, true, 6);
		}
		
		function onSnapshotWindowFailure(e:GamesEvents):void
		{
			trace("onSnapshotWindowFailure: " + e.msg);
		}
		
		function onSnapshotWindowDismissed(e:GamesEvents):void
		{
			trace("onSnapshotWindowDismissed");
		}
		
		function onSnapshotWindowNew(e:GamesEvents):void
		{
			trace("onSnapshotWindowNew");
		}
		
		function onSnapshotWindowPick(e:GamesEvents):void
		{
			trace("---------- onSnapshotWindowPick");
			trace("coverImageAspectRatio: " + e.snapshotMetadata.coverImageAspectRatio);
			trace("description: " + e.snapshotMetadata.description);
			trace("deviceName: " + e.snapshotMetadata.deviceName);
			trace("hasChangePending: " + e.snapshotMetadata.hasChangePending);
			trace("lastModifiedTimestamp: " + e.snapshotMetadata.lastModifiedTimestamp);
			trace("playedTime: " + e.snapshotMetadata.playedTime);
			trace("progressValue: " + e.snapshotMetadata.progressValue);
			trace("uniqueName: " + e.snapshotMetadata.uniqueName);
			trace("owner.displayName: " + e.snapshotMetadata.owner.displayName);
			trace("gameMetadata.displayName: " + e.snapshotMetadata.gameMetadata.displayName);
			trace("----------");
			
			if(!Games.snapshots.hasEventListener(GamesEvents.SNAPSHOT_LOAD_STARTED))
			{
				Games.snapshots.addEventListener(GamesEvents.SNAPSHOT_LOAD_STARTED, onSnapshotLoadStarted);
				Games.snapshots.addEventListener(GamesEvents.SNAPSHOT_LOAD_ENDED, onSnapshotLoadEnded);
			}
			
			Games.snapshots.load(e.snapshotMetadata.uniqueName);
		}
		
		function onSnapshotLoadStarted(e:GamesEvents):void
		{
			trace("onSnapshotLoadStarted: " + e.snapshotName);
		}
		
		function onSnapshotLoadEnded(e:GamesEvents):void
		{
			if(e.status == Games.SUCCESS)
			{
				trace("serverSnapshot.metadata.uniqueName " + e.serverSnapshot.metadata.uniqueName);
				trace("serverSnapshot.metadata.lastModifiedTimestamp " + e.serverSnapshot.metadata.lastModifiedTimestamp);
				trace("serverSnapshot.content " + e.serverSnapshot.content);
			}
			else if(e.status == Games.FAILURE)
			{
				trace("onSnapshotLoadEnded: " + e.msg);
			}
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn041:MySprite = createBtn("Snapshots: save", 0x9ed8e2);
		btn041.addEventListener(MouseEvent.CLICK, snapshotsave);
		_list.add(btn041);
		
		function snapshotsave(e:MouseEvent):void
		{
			if(!Games.snapshots.hasEventListener(GamesEvents.SNAPSHOT_SAVE_STARTED))
			{
				Games.snapshots.addEventListener(GamesEvents.SNAPSHOT_SAVE_STARTED, onSaveStarted);
				Games.snapshots.addEventListener(GamesEvents.SNAPSHOT_SAVE_CONFLICTED, onSaveConflicted);
				Games.snapshots.addEventListener(GamesEvents.SNAPSHOT_SAVE_ENDED, onSaveEnded);
			}
			
			Games.snapshots.save(
					"mySave-" + Number(Math.random().toFixed(5)) * 100000,
					"save any string but you may find saving JSON Strings more helpful for saving complex game data.",
					"description of the save item",
					coverImg.bitmapData,
					20,
					123456,
					Snapshots.RESOLUTION_POLICY_MANUAL
			)
		}
		
		function onSaveStarted(e:GamesEvents):void
		{
			C.log("onSaveStarted: " + e.snapshotName);
		}
		
		function onSaveConflicted(e:GamesEvents):void
		{
			trace("-------------- onSaveConflicted. You should resolve the conflict now using 'resolveConflict' method");
			trace("conflict id: " + e.conflictId);
			trace("serverSnapshot.metadata.uniqueName " + e.serverSnapshot.metadata.uniqueName);
			trace("serverSnapshot.metadata.lastModifiedTimestamp " + e.serverSnapshot.metadata.lastModifiedTimestamp);
			trace("serverSnapshot.content " + e.serverSnapshot.content);
			trace("-");
			trace("conflictingSnapshot.metadata.uniqueName " + e.conflictingSnapshot.metadata.uniqueName);
			trace("conflictingSnapshot.metadata.lastModifiedTimestamp " + e.conflictingSnapshot.metadata.lastModifiedTimestamp);
			trace("conflictingSnapshot.content " + e.conflictingSnapshot.content);
			trace("-----------");
		}
		
		function onSaveEnded(e:GamesEvents):void
		{
			if(e.status == Games.SUCCESS)
			{
				trace("onSaveEnded");
			}
			else if(e.status == Games.FAILURE)
			{
				trace("onSaveEnded: " + e.msg);
			}
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn042:MySprite = createBtn("Snapshots: get list", 0x9ed8e2);
		btn042.addEventListener(MouseEvent.CLICK, snapshotGetList);
		_list.add(btn042);
		
		function snapshotGetList(e:MouseEvent):void
		{
			if(!Games.snapshots.hasEventListener(GamesEvents.SNAPSHOT_GET_LIST))
					Games.snapshots.addEventListener(GamesEvents.SNAPSHOT_GET_LIST, onSnapshotsList);
			
			Games.snapshots.getList(true);
		}
		
		function onSnapshotsList(e:GamesEvents):void
		{
			if(e.status == Games.SUCCESS)
			{
				trace("--------------- onSnapshotsList");
				
				for(var i:int=0; i < e.snapshotNames.length; i++)
				{
					trace(i + ") snapshotNames.uniqueName: " + e.snapshotNames[i]);
				}
				
				trace("---------------");
			}
			else if(e.status == Games.FAILURE)
			{
				trace("onSnapshotsList: " + e.msg);
			}
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn043:MySprite = createBtn("Snapshots: get constants", 0x9ed8e2);
		btn043.addEventListener(MouseEvent.CLICK, getConstants);
		_list.add(btn043);
		
		function getConstants(e:MouseEvent):void
		{
			Games.snapshots.maxCoverImageSize(function ($size:int, $error:Error):void
			{
				if($error)
				{
					trace("Games.snapshots.maxCoverImageSize: " + $error.message);
				}
				else
				{
					trace("Games.snapshots.maxCoverImageSize: " + $size);
				}
			});
			
			Games.snapshots.maxDataSize(function ($size:int, $error:Error):void
			{
				if($error)
				{
					trace("Games.snapshots.maxDataSize: " + $error.message);
				}
				else
				{
					trace("Games.snapshots.maxDataSize: " + $size);
				}
			});
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn050:MySprite = createBtn("Realtime: create room", 0x77eab1);
		btn050.addEventListener(MouseEvent.CLICK, createRoom);
		_list.add(btn050);
		
		function createRoom(e:MouseEvent):void
		{
			Games.realtime.showWaitingRoomAutomatically = false;
			Games.realtime.createRoom(1, 2, 0, -1, null);
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn051:MySprite = createBtn("Realtime: leave room", 0x77eab1);
		btn051.addEventListener(MouseEvent.CLICK, leaveRoom);
		_list.add(btn051);
		
		function leaveRoom(e:MouseEvent):void
		{
			Games.realtime.leave(_room);
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn053:MySprite = createBtn("Realtime: reliable msg", 0x77eab1);
		btn053.addEventListener(MouseEvent.CLICK, sendReliableMsg);
		_list.add(btn053);
		
		function sendReliableMsg(e:MouseEvent):void
		{
			if(!_room)
			{
				C.log("_room is not available yet!");
				return;
			}
			
			Games.realtime.sendReliableMessage(
					"my reliable data... " + Math.random(),
					_room.roomId,
					_otherParticipantId,
					function ($tokenId:int, $error:Error):void
					{
						if($error)
						{
							trace("Games.realtime.sendReliableMessage failure: " + $error.message);
						}
						
						trace("Games.realtime.sendReliableMessage tokenId: " + $tokenId);
					}
			);
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn054:MySprite = createBtn("Realtime: unreliable msg", 0x77eab1);
		btn054.addEventListener(MouseEvent.CLICK, sendUnreliableMsg);
		_list.add(btn054);
		
		function sendUnreliableMsg(e:MouseEvent):void
		{
			if(!_room)
			{
				C.log("_room is not available yet!");
				return;
			}
			
			Games.realtime.sendUnreliableMessage(
					"unreliable data... " + Math.random(),
					_room.roomId,
					[],
					function ($error:Error):void
					{
						if($error)
						{
							trace("Games.realtime.sendUnreliableMessage failure: " + $error.message);
						}
					}
			);
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn060:MySprite = createBtn("invitation: inbox window", 0x7be871);
		btn060.addEventListener(MouseEvent.CLICK, invitationInboxWindow);
		_list.add(btn060);
		
		function invitationInboxWindow(e:MouseEvent):void
		{
			if(!Games.invitations.hasEventListener(GamesEvents.INVITATION_INBOX_WINDOW_FAILURE))
			{
				Games.invitations.addEventListener(GamesEvents.INVITATION_INBOX_WINDOW_FAILURE, onInvitationInboxFailure);
				Games.invitations.addEventListener(GamesEvents.INVITATION_WINDOW_DISMISSED, onInvitationWindowDismissed);
			}
			
			Games.invitations.showNativeWindow();
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn061:MySprite = createBtn("Realtime: invite window", 0x7be871);
		btn061.addEventListener(MouseEvent.CLICK, invitePlayersWindow);
		_list.add(btn061);
		
		function invitePlayersWindow(e:MouseEvent):void
		{
			Games.realtime.showNativeWindowInvitePlayers(1, 3, 0, -1);
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn062:MySprite = createBtn("invitation: load", 0x7be871);
		btn062.addEventListener(MouseEvent.CLICK, loadInvitations);
		_list.add(btn062);
		
		function loadInvitations(e:MouseEvent):void
		{
			if(!Games.invitations.hasEventListener(GamesEvents.INVITATION_LOAD_RESULT))
			{
				Games.invitations.addEventListener(GamesEvents.INVITATION_LOAD_RESULT, onInvitationLoadResult);
			}
			
			Games.invitations.load(Games.SORT_ORDER_SOCIAL_AGGREGATION);
		}
		
		function onInvitationLoadResult(e:GamesEvents):void
		{
			if(e.status == Games.SUCCESS)
			{
				trace("onInvitationLoadResult: " + e.invitations.length);
				
				for(var i:int=0; i < e.invitations.length; i++)
				{
					var invitation:Invitation = e.invitations[i];
					trace("\t creationTimestamp: " + invitation.creationTimestamp);
					trace("\t id: " + invitation.id);
					trace("\t invitationType: " + invitation.invitationType);
					trace("\t inviter.displayName: " + invitation.inviter.displayName);
					trace("\t -");
				}
			}
			else if(e.status == Games.FAILURE)
			{
				trace("onInvitationLoadResult failure: " + e.msg);
			}
		}
		
		// ---------------------------------------------------------------------------------------------------------
		// ---------------------------------------------------------------------------------------------------------
		
		onResize();
	}
	
	private function onMessageSent(e:GamesEvents):void
	{
		if(e.status == Games.SUCCESS)
		{
			trace("--------------- onMessageSent");
			trace("tokenId " + e.tokenId);
			trace("recipientParticipantId " + e.recipientParticipantId);
			trace("-----------");
		}
		else if(e.status == Games.FAILURE)
		{
			trace("onMessageSent Failure: " + e.msg);
		}
	}
	
	private function onMessageReceived(e:GamesEvents):void
	{
		trace("--------------------- onMessageReceived");
		trace("isReliable: " + e.realTimeMessage.isReliable);
		trace("messageData: " + e.realTimeMessage.messageData);
		trace("senderParticipantId: " + e.realTimeMessage.senderParticipantId);
		trace("----------");
	}
	
	private function onWaitingRoomFailure(e:GamesEvents):void
	{
		trace("onWaitingRoomFailure: " + e.msg);
	}
	
	private function onWaitingRoomDismissed(e:GamesEvents):void
	{
		trace("onWaitingRoomDismissed");
	}
	
	private function onWaitingRoomResult(e:GamesEvents):void
	{
		if(e.status == Games.SUCCESS)
		{
			//				_room = e.room;
			trace("onWaitingRoomResult result OK");
		}
		else if(e.status == Games.FAILURE)
		{
			trace("onWaitingRoomResult result" + e.msg);
		}
	}
	
	private function onRoomStatusUpdated(e:GamesEvents):void
	{
		trace("onRoomStatusUpdated: " + e.roomEvent);
		
		switch(e.roomEvent)
		{
			case Room.ROOM_EVENT_CONNECTING:
				
				
				break;
			case Room.ROOM_EVENT_AUTO_MATCHING:
				
				
				break;
			case Room.ROOM_EVENT_PEER_INVITED:
				
				//					trace("participantIds: " + e.participantIds);
				
				break;
			case Room.ROOM_EVENT_PEER_DECLINED:
				
				//					trace("participantIds: " + e.participantIds);
				
				break;
			case Room.ROOM_EVENT_PEER_JOINED:
				
				_otherParticipantId = e.participantIds[0];
				//					trace("participantIds: " + e.participantIds);
				
				break;
			case Room.ROOM_EVENT_PEER_LEFT:
				
				//					trace("participantIds: " + e.participantIds);
				
				break;
			case Room.ROOM_EVENT_CONNECTED:
				
				
				break;
			case Room.ROOM_EVENT_DISCONNECTED:
				
				
				break;
			case Room.ROOM_EVENT_PEERS_CONNECTED:
				
				//					trace("participantIds: " + e.participantIds);
				
				break;
			case Room.ROOM_EVENT_PEERS_DISCONNECTED:
				
				//					trace("participantIds: " + e.participantIds);
				
				break;
			case Room.ROOM_EVENT_P2P_CONNECTED:
				
				//					trace("participantId: " + e.participantId);
				
				break;
			case Room.ROOM_EVENT_P2P_DISCONNECTED:
				
				//					trace("participantId: " + e.participantId);
				
				break;
		}
	}
	
	private function onRoomCreated(e:GamesEvents):void
	{
		if(e.status == Games.SUCCESS)
		{
			_room = e.room;
			trace("---------------- onRoomCreated");
			traceTheRoom();
		}
		else if(e.status == Games.FAILURE)
		{
			trace("onRoomCreated failed: " + e.msg);
		}
	}
	
	private function onRoomConnected(e:GamesEvents):void
	{
		if(e.status == Games.SUCCESS)
		{
			_room = e.room;
			trace("---------------- onRoomConnected");
			traceTheRoom();
		}
		else if(e.status == Games.FAILURE)
		{
			trace("onRoomConnected failed: " + e.msg);
		}
	}
	
	private function onRoomJoined(e:GamesEvents):void
	{
		if(e.status == Games.SUCCESS)
		{
			_room = e.room;
			trace("---------------- onRoomJoined");
			traceTheRoom();
		}
		else if(e.status == Games.FAILURE)
		{
			trace("onRoomJoined failed: " + e.msg);
		}
	}
	
	private function onRoomLeft(e:GamesEvents):void
	{
		if(e.status == Games.SUCCESS)
		{
			trace("onRoomLeft roomId: " + e.roomId);
		}
		else if(e.status == Games.FAILURE)
		{
			trace("onRoomLeft failed: " + e.msg);
		}
	}
	
	private function traceTheRoom():void
	{
		//return;
		
		trace("creatorId: " + _room.creatorId);
		trace("creationTimestamp: " + _room.creationTimestamp);
		trace("description: " + _room.description);
		trace("participantIds: " + _room.participantIds);
		trace("autoMatchWaitEstimateSeconds: " + _room.autoMatchWaitEstimateSeconds);
		trace("-");
		for(var i:int=0; i < _room.participantIds.length; i++)
		{
			var participant:Participant = _room.getParticipant(_room.participantIds[i]);
			trace("participant.displayName: " + participant.displayName);
			trace("participant.isConnectedToRoom: " + participant.isConnectedToRoom);
			trace("participant.id: " + participant.id);
			
			// TODO: what's the problem with this?!
			// trace("participant status: " + _room.getParticipantStatus(participant.id));
			trace("-");
		}
		trace("----------------");
	}
	
	private function onInvitationReceived(e:GamesEvents):void
	{
		trace("--------------- onInvitationReceived");
		trace("id: " + e.invitation.id);
		(e.invitation.invitationType == Invitations.INVITATION_TYPE_REAL_TIME)?trace("type: realtime"):trace("type: turnbased");
		trace("inviter.displayName: " + e.invitation.inviter.displayName);
		trace("inviter.player.displayName: " + e.invitation.inviter.player.displayName);
		trace("-");
		
		// we just received an invitation! so the player can now click a button and join the game...
		Games.realtime.joinRoom(e.invitation.id);
	}
	
	private function onInvitationRemoved(e:GamesEvents):void
	{
		trace("onInvitationRemoved: " + e.invitationId);
	}
	
	private function onInvitingPlayersWinFailure(e:GamesEvents):void
	{
		trace("onInvitingPlayersWinFailure: " + e.msg);
	}
	
	private function onInvitingPlayersResult(e:GamesEvents):void
	{
		/**
		 * On a successful operation, room will be created automatically.
		 */
		
		trace("onInvitingPlayersResult status: " + e.status);
	}
	
	private function onInvitationInboxFailure(e:GamesEvents):void
	{
		trace("onInvitationInboxFailure: " + e.msg);
	}
	
	private function onInvitationWindowDismissed(e:GamesEvents):void
	{
	
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	private function createBtn($str:String, $bgColor:uint=0xDFE4FF):MySprite
	{
		var sp:MySprite = new MySprite();
		sp.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		sp.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		sp.addEventListener(MouseEvent.CLICK, onOut);
		sp.bgAlpha = 1;
		sp.bgColor = $bgColor;
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
			sp.bgColor = $bgColor;
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
