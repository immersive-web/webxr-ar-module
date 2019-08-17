# WebXR Augmented Reality Module Explained

## Functionality

### Immersive AR session mode

Interacting with an XR device is done through the `XRSession` interface, but before any XR-enabled page requests a session it should first query to determine if the type of XR content desired is supported by the current hardware and UA. If it is, the page can then advertise XR functionality to the user. (For example, by adding a button to the page that the user can click to start XR content.)

The `navigator.xr.supportsSession` function is used to check if the device supports the XR capabilities the application needs. It takes an "XR mode" describing the desired functionality and returns a promise which resolves if the device can successfully create an `XRSession` using that mode. The call rejects otherwise.

Querying for support this way is necessary because it allows the application to detect what XR modes are available prior to requesting an `XRSession`, which may engage the XR device sensors and begin presentation. This can incur significant power or performance overhead on some systems and may have side effects such as taking over the user's screen, launching a status tray or storefront, or terminating another application's access to XR hardware. Calling `navigator.xr.supportsSession` must not interfere with any running XR applications on the system or have any user-visible side effects.

The WebXR Device API defined 2 modes that can be requested and this module adds a third.

**Immersive AR**: Requested with the mode enum `'immersive-ar'`. Immersive AR content functions largely the same as immersive VR content, with the primary difference being that it guarantees that the users environment will be visible and aligned with the rendered content. This may be achieved with see-through displays, like HoloLens or Magic Leap, or video passthrough systems like ARCore and ARKit. Additionally, access to environmental data (such as hit testing) may be permitted. As with immersive VR, immersive AR sessions must be requested within a user activation event or another callback that has been explicitly indicated to allow immersive session requests.

### Checking session availability

UAs must reject the request for an AR session if the XR hardware device cannot support a mode where the user's environment is visible. Pages should be designed to robustly handle the inability to acquire AR sessions. `navigator.xr.supportsSession()` can be used if a page wants to test for AR session support before attempting to create the `XRSession`.

```js
function checkARSupport() {
  // Check to see if the UA can support an AR sessions.
  return navigator.xr.supportsSession('immersive-ar')
      .then(() => { console.log("AR content is supported!"); })
      .catch((reason) => { console.log("AR content is not supported: " + reason); });
}
```

### Creating a session

If an XR-enabled page wants to display Augmented Reality content instead of Virtual Reality, it can create an AR session by passing `'immersive-ar'` into `requestSession`. 

```js
function beginXRSession() {
  // requestSession must be called within a user gesture event
  // like click or touch when requesting an immersive session.
  navigator.xr.requestSession('immersive-ar')
      .then(onSessionStarted);
}
```

This provides a session that behaves much like the immersive VR sessions described above with a few key behavioral differences. The primary distinction between an "immersive-vr" and "immersive-ar" session is that the latter guarantees that the user's environment is visible and that rendered content will be aligned to the environment. The exact nature of the visibility is hardware-dependent, and communicated by the `XRSession`'s `environmentBlendMode` attribute. AR sessions will never report an `environmentBlendMode` of `opaque`. See [Handling non-opaque displays](#handling-non-opaque-displays) for more details.


The UA may choose to present the immersive AR session's content via any type of display, including dedicated XR hardware (for devices like HoloLens or Magic Leap) or 2D screens (for APIs like [ARKit](https://developer.apple.com/arkit/) and [ARCore](https://developers.google.com/ar/)). In all cases the session takes exclusive control of the display, hiding the rest of the page if necessary. On a phone screen, for example, this would mean that the session's content should be displayed in a mode that is distinct from standard page viewing, similar to the transition that happens when invoking the `requestFullscreen` API. The UA must also provide a way of exiting that mode and returning to the normal view of the page, at which point the immersive AR session must end.

### Handling non-opaque displays

Some devices which support the WebXR Device API may use displays that are not fully opaque, or otherwise show your surrounding environment in some capacity. To determine how the display will blend rendered content with the real world, check the `XRSession`'s `environmentBlendMode` attribute. It may currently be one of three values, and more may be added in the future if new display technology necessitates it:

  - `opaque`: The environment is not visible at all through this display. Transparent pixels in the `baseLayer` will appear black. This is the expected mode for most VR headsets. Alpha values will be ignored, with the compositor treating all alpha values as 1.0.
  - `additive`: The environment is visible through the display and pixels in the `baseLayer` will be shown additively against it on the device's primary displays. On these displays, black pixels will appear fully transparent, and there is typically no way to make a pixel fully opaque. Alpha values will be ignored, with the compositor treating all alpha values as 1.0. This is the expected mode for devices like HoloLens or Magic Leap.
  - `alpha-blend`: The environment is visible through the display and pixels in the `baseLayer` will be blended with it according to the alpha value of the pixel. Pixels with an alpha value of 1.0 will be fully opaque and pixels with an alpha value of 0.0 will be fully transparent. This is the expected mode for devices which use passthrough video to show the environment such as ARCore or ARKit enabled phones, as well as headsets that utilize passthrough video for AR like the Vive Pro.

When rendering content it's important to know how the content will appear on the display, as that may affect the techniques you use to render. For example, on an `additive` display is used that can only render additive light. This means that the color black appears as fully transparent and expensive graphical effects like shadows may not show up at all. Similarly, if the developer knows that the environment will be visible they may choose to not render an opaque background.

```js
function drawScene() {
  renderer.enableShadows(xrSession.environmentBlendMode != 'additive');

  // Only draw a background for the scene if the environment is not visible.
  if (xrSession.environmentBlendMode == 'opaque') {
    renderer.drawSkybox();
  }

  // Draw the reset of the scene.
}
```

## Appendix B: Proposed IDL

```webidl
//
// Session
//

enum XRSessionMode {
  "inline",
  "immersive-vr",
  "immersive-ar"
}

enum XREnvironmentBlendMode {
  "opaque",
  "additive",
  "alpha-blend",
};

partial interface XRSession {
  readonly attribute XREnvironmentBlendMode environmentBlendMode;
}
```
