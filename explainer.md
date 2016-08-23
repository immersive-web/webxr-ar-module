# WebVR Explained

## What is WebVR?
[WebVR](https://w3c.github.io/webvr/) is an API that provides access to input and output capabilities commonly associated with Virtual Reality hardware like [Google’s Daydream](https://vr.google.com/daydream/) or the [Oculus Rift](https://www3.oculus.com/en-us/rift/). More simply: It lets you create Virtual Reality web sites that you can view in a VR headset.

### Ooh, so like Johnny Mnemonic where the internet is all 90’s CGI?
Nope, not even slightly. And why do you even want that? That’s a terrible UX.

WebVR, at least initially, is aimed at letting you create VR experiences that are embedded in the web that we know and love today. It’s explicitly not about creating a browser that you use completely in VR (although it could work well in an environment like that.)

### Goals
Enable Virtual Reality applications on the web by allowing pages to:

 * Detect available Virtual Reality devices.
 * Query the devices capabilities.
 * Poll the device’s position and orientation.
 * Display imagery on the device at the appropriate framerate.

### Non-Goals

 * Define how a Virtual Reality browser would work.
 * Take full advantage of Augmented Reality devices.
 * Build “[The Metaverse](https://en.wikipedia.org/wiki/Metaverse)”

## Use Cases
Given the marketing of early VR hardware to gamers it’s natural to expect that this API will primarily be used for development of games. While that’s certainly something we expect to see given the history of the WebGL API, which is tightly related, we’ll probably see far more “long tail” style content than large scale games. Broadly, VR content on the web will likely cover areas that do not cleanly fit into the app store models being used as the primary distribution methods by all the major VR hardware providers, or where the content itself is not permitted by the store guidelines. These would include, but are not limited to:

### Video
360 degree and 3D video are an area of intense interest (for example, see [ABC’s 360 degree video coverage of the upcoming US election](http://abcnews.go.com/US/fullpage/abc-news-vr-virtual-reality-news-stories-33768357)), and the web has proven massively effective at distributing video in the past. A VR-enabled video player would, upon detecting the presence of VR hardware, show a “View in VR” button, similar to the “Fullscreen” buttons that many video players use today. When the user clicks that button the video would begin rendering in the headset, responding to head movement to allow the video to be viewed more naturally. Traditional 2D video could also be presented in the headset as though the user is sitting in front of a theater-sized screen, providing a more immersive experience.

### Object/Data Visualization
Site can provide easy 3D visualizations through WebVR, often as a progressive improvement to their more traditional rendering. Viewing 3D models (like [SketchFab](https://sketchfab.com/)), architectural previs, medical imaging, mapping, or [basic data visualization](http://graphics.wsj.com/3d-nasdaq/) can all be more impactful, easier to understand, and convey an accurate sense of scale in VR. Many of those uses are difficult for users to justify installing a native app for, especially when the Web puts the content you want a link away. Home shopping with applications like [Matterport](https://matterport.com/try/) serve as a particularly effective demonstration of this. Depending on device capabilities sites can scale all the way from a simple photo carousel to an interactive 3D model on screen to viewing the walkthrough in VR, giving users the impression of actually being present in the house. The ability for this to be a low friction experience for users is a huge asset for both users and developers, since they don’t need to convince users to install a heavy executable before hand.

### Artistic experiences
VR provides an interesting canvas for artists looking to explore the possibilities of a new medium. Many times shorter, abstract, or highly experimental experiences are poor fits for a store model, where the perceived overhead of downloading and installing a native executable may be disproportionate to the content delivered. The web’s transient nature makes these types of applications more appealing, since they provide a friction free way to view the experience. It also allows the artist to more easily attract people to the content and target the widest range of devices with a single code base.

## Basic API usage

### Device detection
The first thing that any VR-enabled page will want to do is enumerate the available VR hardware and determine which one to interact with.

```js
var vrDisplay = null;
navigator.getVRDisplays().then(function (displays) {
  // Use the first display in the array if one is available. If multiple
  // displays are present you may want to present the user with a way to
  // select which display they wish to use.
  if (displays.length > 0) {
    vrDisplay = displays[0];
    // User has VR hardware, advertise your page’s VR features to them.
    showVRFeatures();
  } else {
    // No VR hardware available.
  }
});
```

[`navigator.getVRDisplays`](https://w3c.github.io/webvr/#navigator-getvrdisplays-attribute) returns a promise that, when fulfilled, provides a list of available displays. Each [`VRDisplay`](https://w3c.github.io/webvr/#interface-vrdisplay) represents a single piece of physical VR hardware. On desktops this will usually be a headset peripheral, and on mobile devices it may represent the device itself in conjunction with a viewer harness, such as Cardboard or a GearVR.

### Device Capabilities
VR headsets can differ significantly in their tracking and display capabilities. For example: VR hardware tracks the hardware’s orientation and/or position of the hardware in space. If a headset can only track orientation it’s referred to as 3 Degree of Freedom (3DoF) tracking. If it can track both orientation and position it’s referred to as 6 Degree of Freedom (6DoF) tracking.

To determine what the headset is capable of and adjust the page’s behavior accordingly, developers can inspect the [`VRDisplay.capabilities`](https://w3c.github.io/webvr/#interface-vrdisplaycapabilities) attribute.

```js
if (vrDisplay.capabilities.hasPosition) {
  // This VRDisplay can track its position.
}
if (vrDisplay.capabilities.hasOrientation) {
  // This VRDisplay can track its orientation.
  // This should almost always be the case.
}
if (vrDisplay.capabilities.hasExternalDisplay) {
  // The headset is a separate display from the main monitor.
  // This means you should consider mirroring the content shown on
  // the headset.
  // On PCs this is usually true. On mobile this is usually false.
}
if (vrDisplay.capabilities.canPresent) {
  // If this is false the VRDisplay can’t actually present content to
  // the user in stereo, so while you may want to take the tracking
  // into account you shouldn’t advertise “VR mode” to users.
  // Tango devices are good examples of a VRDisplay that would expose
  // 6DoF tracking, but no presentation capabilities. Instead they
  // can be used as a “magic window” into a virtual space.
}
```

### Headset Input
WebVR provides tracking information via the [`VRDisplay.getPose()`](https://w3c.github.io/webvr/#dom-vrdisplay-getpose) function, which developers use to poll the display for new position, orientation, velocity, and acceleration data each frame. The ideal pattern for using this information is to query it in a [`VRDisplay.requestAnimationFrame`](https://w3c.github.io/webvr/#dom-vrdisplay-requestanimationframe) callback loop, which runs at the refresh rate of the headset (frequently higher than the average monitor). The pose is then used to update either the viewpoint of a scene or the position and orientation of an object within that scene.

```js
function onAnimationFrame (t) {
  // When presenting content to the VRDisplay we want to update at its
  // refresh rate if it differs from the refresh rate of the main
  // display. Calling VRDisplay.requestAnimationFrame ensures we render
  // at the right speed for VR.
  vrDisplay.requestAnimationFrame(onAnimationFrame);

  // Orientation is reported as a quaternion
  camera.orientation = pose.orientation;

  // Need to account for the fact that not all VR hardware reports position
  if (pose.position)
  	camera.position = pose.position;
  else
      camera.position = [0, 0, 0];

  drawScene(camera);
}
```

### Rendering
Currently the only supported rendering method is WebGL, though that’s likely to change in future versions of the API. In order to render a WebGL scene that will feel correct when viewed through a headset, values from the [`VREyeParameters`](https://w3c.github.io/webvr/#interface-vreyeparameters) interface that describe the field of view, resolution, and interpupillary distance (IPD) are used to set up WebGL’s view and projection matrices.

```js
function drawSceneForEye(eyeName, camera) {
  // eyeName is either “left” or “right”
  var eye = vrDisplay.getEyeParameters(eyeName);

  // Adjust the camera to render correctly for this eye
  camera.setFieldOfView(eye.fieldOfView);
  camera.position.translate(eye.offset);

  // Render scene’s 3D content here using the camera
}
```

### Output
VR hardware frequently needs to make use of specialized display paths to allow it counteract distortion introduced by the lenses, compensate for latency, and more. As a result, VR content can’t simply be drawn to the screen like a normal web app but instead must be explicitly submitted to the `VRDisplay`. In order to do that the page first requests permission to begin presenting to the `VRDisplay` using [`VRDisplay.requestPresent`](https://w3c.github.io/webvr/#dom-vrdisplay-requestpresent), which takes in the WebGL canvas whose contents will be shown on the headset and returns a promise that indicates if the page can begin presenting or not.

```js
function enterVRMode() {
  vrDisplay.requestPresent([{ source: glCanvas }]).then(function () {
    // Presentation began successfully, so kick off the animation loop
    vrDisplay.requestAnimationFrame(onAnimationFrame);
  }, function () {
    // Unable to begin presentation for some reason.
  });
}
```

The page is responsible for rendering a stereo view by drawing out the content for each eye to one half of the canvas. Then, once the rendering is complete the page notifies the headset that it’s done by calling [`VRDisplay.submitFrame`](https://w3c.github.io/webvr/#dom-vrdisplay-submitframe).

```js
function drawScene(camera) {
  // Draw the left eye
  gl.viewport(0, 0, glCanvas.width * 0.5, glCanvas.height);
  drawSceneForEye(“left”, camera);

  // Draw the right eye
  gl.viewport(glCanvas.width * 0.5, 0, glCanvas.width * 0.5, glCanvas.height);
  drawSceneForEye(“right”, camera);

  // Notify the VRDisplay that the new frame is ready.
  vrDisplay.submitFrame();
}
```

To stop presenting to the `VRDisplay` the page calls [`VRDisplay.exitPresent`](https://w3c.github.io/webvr/#dom-vrdisplay-exitpresent).

### More sample code
This overview attempts to touch on all the important parts of using WebVR, but avoids discussing advanced uses for the sake of clarity. For developers that want to dig a bit deeper there are several working samples of the API in action at https://webvr.info/samples/. These samples each outline a specific part of the API with plenty of code comments to help guide developers through what everything is doing.

## I don’t understand why this is a new API. Why can’t we use…

### DeviceOrientation Events
The data provided by a `VRPose` is similar to `DeviceOrientationEvent`, with some important differences:
 * It’s an explicit polling interface, which ensures that new input is available for each frame. The event-driven `DeviceOrientation` data may skip a frame, or may deliver two updates in a single frame, which can lead to disruptive, jittery motion in a VR application.
 * `DeviceOrientation` events do not provide positional data, which is a key feature of high-end VR hardware.
 * More can be assumed about the intended use case of `VRDisplay` data, so optimizations such as motion prediction can be applied.
 * `DeviceOrientation` events are typically not available on desktops.

That being said, however, for some simple VR devices (like Cardboard) `DeviceOriention` events provide enough data to create a basic polyfill of the WebVR API, as demonstrated by Boris Smus’ wonderful [webvr-polyfill project](https://github.com/borismus/webvr-polyfill). This provides an approximation of a native implementation that allows developers to experiment with the API when support isn’t provided by the browser. While useful for testing and compatibility a pure javascript implementation like that misses out the ability to take advantage of VR-specific optimizations available on some mobile devices, like Daydream ready phones or Samsung’s GearVR compatible lineup. A native implementation on mobile can provide a much better experience with lower latency, less jitter, and higher graphics performance than a `DeviceOriention` based one.

### WebSockets
A local websocket service could be set up to relay headset poses to the browser. Some early VR experiments with the browser tried this route, and some non-VR tracking devices (most notably [Leap Motion](https://www.leapmotion.com/)) have built their Javascript SDKs around this concept.
Unfortunately this has proven to be a high-latency route. A key element of a good VR experience is low latency. Ideally the movement of your head should result in an update on the display (referred to as motion-to-photons time) in 20ms or less. The browser’s rendering pipeline already makes hitting this goal difficult, and adding additional overhead for communication over WebSockets only exaggerates the problem. Additionally, using a method like this requires users to install a separate service, likely as a native app, on their machine which erodes away much of the benefit of having access to the hardware via the browser. It also falls down on mobile where there’s no clear way for users to install such a service.

### The Gamepad API
Some people have suggested that we try to expose VR headset data through the Gamepad API, which seems like it should provide enough flexibility through an unbounded number of potential axes. While it would be technically possible, there are a few properties of the API that make it poorly suited for this use.
 * Axes are normalized to always report data in a [-1, 1] range. That may work okay for orientation reporting, but when reporting position or acceleration you would have to choose an arbitrary mapping of the normalized range to a physical one. (1.0 == 2 meters or similar) But that forces the developers to make assumptions about the capabilities of VR hardware in the future and the mapping makes interpreting the data error prone and non-intuitive.
 * Axes are not explicitly associated with any given input, which means that it’s difficult for users to remember if axis 0 is a component of the devices’ position, orientation, acceleration, etc.
 * VR device capabilities can differ significantly, and the gamepad API as-is doesn’t provide a way to communicate what features a device may have or what it’s optical properties are.
 * Gamepad features like buttons have no clear meaning when describing a VR headset.

There is a related effort to expose 3DoF and 6DoF VR controllers through the Gamepad API by adding a `pose` attribute and some other related properties. But even though these additions would make the API more accommodating for headsets we feel that it’s best for developers to have a separation of concerns so that devices exposed by the Gamepad API can be reasonably assumed to be gamepad-like and devices exposed by the WebVR API can be reasonably assumed to be headset-like.

### These alternatives don’t account for display
It’s important to realize that all of the alternative solutions offer no method for displaying imagery on the headset itself, with the exception of Cardboard-like devices where you can simply render a full-screen split view. Even that doesn’t take into account how to communicate the projection or distortion necessary for an accurate image, though. Without a reliable display method the ability to query inputs from a headset is far less valuable.
