# Google Game Services ANE for Android
The Google Game Services AIR native extension allows you to focus on your game logic and easily have access to all the cool features of this great SDK in your AIR games.

**NOTICE: Google has discontinued the [Game Services Project for iOS](https://android-developers.googleblog.com/2017/04/focusing-our-google-play-games-services.html). On iOS, you may consider using [Firebase](https://github.com/myflashlab/Firebase-ANE/)**

**Main Features:**
* Achievements
* Leaderboards
* Real-time Multiplayer
* Cloud Game Saving (Game Snapshots)

[find the latest **asdoc** for this ANE here.](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/googleGames/package-detail.html)  
[How to get started? **read here**](https://github.com/myflashlab/GameServices-ANE/wiki)  

# AIR Usage
For the complete AS3 code usage, see the [demo project here](https://github.com/myflashlab/GameServices-ANE/tree/master/AIR/src).

```actionscript
/*
	Before initializing the GameServices ANE, you need to login users using the GoogleSignin ANE
	https://github.com/myflashlab/GoogleSignIn-ANE
*/

// depending on your app design, you must customize the Signin Options
// If you want GoogleGames signin only, do like below:
var options:GSignInOptions = new GSignInOptions();
options.gamesSignIn = true; // set to true if you are working with Google Games Services ANE.

// you don't want to bother users with a permission page, right? so set these to false 
// and don't ask for extra access scopes.
options.requestId = false;
options.requestProfile = false;
options.requestEmail = false;

// IMPORTANT: if you are not using Game Save Snapshots, you would not need GScopes.DRIVE_APPFOLDER
options.requestScopes = [
	"https://www.googleapis.com/auth/games", // must be set for games
	GScopes.DRIVE_APPFOLDER // optional and only needed if you are using Game Save Snapshots
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
	initGames(); // here, you will initialize the GameServices ANE
}
else
{
	// You should first check if user can signin silently, if she can't, use the signin() method
	GSignIn.silentSignIn();
}

function onSigninSuccess(e:GSignInEvents):void
{
	trace("e.account.scopes: "+ e.account.scopes);
	initGames();
}

function onSilentSigninSuccess(e:GSignInEvents):void
{
	initGames();
}
```
When user signed in successfully, call ```Games.init();``` to initialize the GameServices ANE. And then listen to ```GamesEvents.CONNECT_SUCCESS``` events before calling other methods of this ANE. Make sure you are reading [the Wiki](https://github.com/myflashlab/GameServices-ANE/wiki) to learn how you should use different features of this ANE.

# AIR .xml manifest
```xml
<!--
	First make sure you have setup the GoogleSignin ANE and you have already added
	the required settings to the manifest.
-->


<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

<!-- Optional. Add this if you are using the "Games.metadata.getCurrentAccountName" method -->
<uses-permission android:name="android.permission.GET_ACCOUNTS" />

<!-- application ID which identifies your game settings in the Google Game Services console -->
<meta-data android:name="com.google.android.gms.games.APP_ID" android:value="\ 00000000000"/>



<!--
Embedding the ANE:
-->
  <extensions>

        <!-- Embed the GSignIn ANE which is a must for the Games ANE to work -->
        <extensionID>com.myflashlab.air.extensions.google.signin</extensionID>

        <!-- Dependencies required by the GSignIn ANE -->
        <extensionID>com.myflashlab.air.extensions.dependency.overrideAir</extensionID>
        <extensionID>com.myflashlab.air.extensions.dependency.androidSupport.arch</extensionID>
        <extensionID>com.myflashlab.air.extensions.dependency.androidSupport.core</extensionID>
        <extensionID>com.myflashlab.air.extensions.dependency.androidSupport.v4</extensionID>
        <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.auth</extensionID>
        <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.base</extensionID>
        <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.basement</extensionID>
        <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.tasks</extensionID>

        <!-- gameServices ANE -->
        <extensionID>com.myflashlab.air.extensions.gameServices</extensionID>

        <!-- Dependencies required by the gameServices ANE -->
        <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.games</extensionID>
        <extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.drive</extensionID>

    </extensions>
-->
```

# Requirements 
1. Android API 19+
2. AIR SDK 30+
3. implement [GoogleSignIn](https://www.myflashlabs.com/product/google-signin-ane-adobe-air-native-extension/) in your app first.

# Commercial Version
https://www.myflashlabs.com/product/game-services-air-native-extension/

[![Game Services ANE](https://www.myflashlabs.com/wp-content/uploads/2016/04/product_adobe-air-ane-extension-game-services-2018-595x738.jpg)](https://www.myflashlabs.com/product/game-services-air-native-extension/)

# Tutorials
[How to embed ANEs into **FlashBuilder**, **FlashCC** and **FlashDevelop**](https://www.youtube.com/watch?v=Oubsb_3F3ec&list=PL_mmSjScdnxnSDTMYb1iDX4LemhIJrt1O)  
[How to get started with Games Services?](https://github.com/myflashlab/GameServices-ANE/wiki#get-started-with-games-services)

# Premium Support #
[![Premium Support package](https://www.myflashlabs.com/wp-content/uploads/2016/06/professional-support.jpg)](https://www.myflashlabs.com/product/myflashlabs-support/)
If you are an [active MyFlashLabs club member](https://www.myflashlabs.com/product/myflashlabs-club-membership/), you will have access to our private and secure support ticket system for all our ANEs. Even if you are not a member, you can still receive premium help if you purchase the [premium support package](https://www.myflashlabs.com/product/myflashlabs-support/).