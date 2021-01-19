# WebRTC Video 1:1 Swift
<a href="http://dev.bandwidth.com"><img src="https://s3.amazonaws.com/bwdemos/BW-VMP.png"/></a>
</div>

 # Table of Contents

<!-- TOC -->

- [WebRTC Video 1:1 Swift](#webrtc-video-1:1-swift)
- [Description](#description)
- [Setup](#setup)
- [Bandwidth](#bandwidth)
- [Environmental Variables](#environmental-variables)
    - [Ngrok](#ngrok)

<!-- /TOC -->

# Description
This sample allows for two iOS devices to communicate audio and video over WebRTC.

There are two projects in this repository, a Node.js project is located in the `server` directory and an iOS project is located in the `WebRTCVideoStoryboard` directory.

# Setup

In order to run this sample `WebRTC Video` is required to be enabled on your account. Please check with your account manager to ensure you are properly provisioned.

## Configure your HTTP server

Copy the default configuration file `.env.default` to `.env`.

```bash
cp .env.default .env
```

Add your Bandwidth account settings to the new configuration file `.env`.

- BANDWIDTH_ACCOUNT_ID
- BANDWIDTH_USERNAME
- BANDWIDTH_PASSWORD

Install server dependencies and run.

```bash
npm install
node server.js
```

## Configure your iOS project

Open the `WebRTCVideoStoyboard` project in Xcode.

Add a property list file `Config.plist` to your project. This should be added to the `WebRTCVideoStoryboard` folder alongside `Info.plist`.

Add a row to the `Config.plist` property list file with a key `Address` and type `String`. Set the value of the row to the server application address which is accessible to the iOS devices. An ngrok url works well for this.

With the server project running build and run the iOS project on your device from Xcode. Don't forget to do this a second time on a different device. Communicating with yourself is often times rather boring.

While both devices are running the app tap `Connect`. Permissions to your camera and microphone may need to be granted at this time. Both devices should display a large view of the remote camera and a small view of your own camera.

> Note: This project requires two iOS devices to properly send and receive audio and video.

# Bandwidth

In order to use the Bandwidth API users need to set up the appropriate application at the [Bandwidth Dashboard](https://dashboard.bandwidth.com/) and create API credentials.

To create an application log into the [Bandwidth Dashboard](https://dashboard.bandwidth.com/) and navigate to the `Applications` tab.  Fill out the **New Application** form selecting the service (Messaging or Voice) that the application will be used for.  All Bandwidth services require publicly accessible Callback URLs, for more information on how to set one up see [Callback URLs](#callback-urls).

For more information about API credentials see [here](https://dev.bandwidth.com/guides/accountCredentials.html#top)

# Environmental Variables

The sample app uses the below environmental variables.
```
BANDWIDTH_ACCOUNT_ID                 // Your Bandwidth Account Id
BANDWIDTH_USERNAME                   // Your Bandwidth API Username
BANDWIDTH_PASSWORD                   // Your Bandwidth API Password
```

## Ngrok

A simple way to set up a local URL for testing is to use the free tool [ngrok](https://ngrok.com/).  
After you have downloaded and installed `ngrok` run the following command to open a public tunnel to your port (`$PORT`)
```cmd
ngrok http $PORT
```
You can view your public URL at `http://127.0.0.1:{PORT}` after ngrok is running. You can also view the status of the tunnel and requests/responses here.
