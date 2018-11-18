# Google Game Services ANE V4.1.1 for Android
The Google Game Services AIR native extension allows you to focus on your game logic and easily have access to all the cool features of this great SDK in your AIR games.

**NOTICE: Google has discontinued the [Game Services Project for iOS](https://android-developers.googleblog.com/2017/04/focusing-our-google-play-games-services.html). On iOS, you may consider using [Firebase](https://github.com/myflashlab/Firebase-ANE/)**

**Main Features:**
* Achievements
* Leaderboards
* Real-time Multiplayer
* Cloud Game Saving (Game Snapshots)

# asdoc
[find the latest asdoc for this ANE here.](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/googleGames/package-detail.html)  
[How to get started? **read here**](https://github.com/myflashlab/GameServices-ANE/wiki)  
[Download demo ANE](https://github.com/myflashlab/GameServices-ANE/tree/master/AIR/lib)  

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
1. Android API 15+
2. AIR SDK 30+
3. implement [GoogleSignIn](https://www.myflashlabs.com/product/google-signin-ane-adobe-air-native-extension/) in your app first.

# Commercial Version
http://www.myflashlabs.com/product/game-services-air-native-extension/

![Game Services ANE](https://www.myflashlabs.com/wp-content/uploads/2016/04/product_adobe-air-ane-extension-game-services-595x738.jpg)

# Tutorials
[How to embed ANEs into **FlashBuilder**, **FlashCC** and **FlashDevelop**](https://www.youtube.com/watch?v=Oubsb_3F3ec&list=PL_mmSjScdnxnSDTMYb1iDX4LemhIJrt1O)  
[How to get started with Games Services?](https://github.com/myflashlab/GameServices-ANE/wiki#get-started-with-games-services)

# Changelog
*Nov 18, 2018 - V4.1.1*
* Works with OverrideAir ANE V5.6.1 or higher
* Works with ANELAB V1.1.26 or higher

*Sep 20, 2018 - V4.1.0*
* Updated to dependencies V15.0.1
* ANE still depends on GoogleSignIn ANE but notice that we have updated GoogleSignin ANE also to V1.3.0 and have removed AndroidSupport ANE and have replaced it with smaller ones.

*Mar 22, 2018 - V4.0.0*
* Updated to the latest SDK version. iOS support is removed by Google and AS3 usage has changed dramatically.
* Google Authentication now happens in the [GoogleSignin ANE](https://github.com/myflashlab/GoogleSignIn-ANE). You need to have that ANE installed first.
* [asDoc](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/googleGames/package-detail.html) packages have been changed.
* Start reading the [WIKI pages](https://github.com/myflashlab/GameServices-ANE/wiki) to get familiar with the new API.

*Dec 15, 2017 - V2.2.3*
* Optimized for [ANE-LAB software](https://github.com/myflashlab/ANE-LAB).

*Apr 26, 2017 - V2.2.1*
* Fixed issue https://github.com/myflashlab/GameServices-ANE/issues/14

*Mar 18, 2017 - V2.2.0*
* min iOS version to support this ANE is 8.0
* Updated SDK to 10.2.0 
* ```overrideAir.ane``` is now also necessary if you are building for iOS only
* Known issue, [conflict between gameServices and GoogleSignin](https://github.com/playgameservices/ios-basic-samples/issues/15)

*Nov 09, 2016 - V2.1.0*
* Optimized for Android manual permissions if you are targeting AIR SDK 24+

*Jun 05, 2016 - V2.0.0*
* Updated to Game Services V9.0.1
* All of the depenency ANEs must be updated to Google Play Services V9.0.1. (just replacing the new ANEs with your current ones is enough)
* New dpenendancy .ane is introduced. *googlePlayServices_authBase.ane* you should add this .ane to your project also. ```<extensionID>com.myflashlab.air.extensions.dependency.googlePlayServices.auth.base</extensionID>```

*May 14, 2016 - V1.0.0*
* beginning of the journey!

*Apr 17, 2016 - V0.0.1*
* (beta tests)Game Services works on Android only at the moment
