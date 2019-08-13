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


#### Rays
An `XRRay` object includes both an `origin` and `direction`, both given as `DOMPointReadOnly`s. The `origin` represents a 3D coordinate in space with a `w` component that must be 1, and the `direction` represents a normalized 3D directional vector with a `w` component that must be 0. The `XRRay` also defines a `matrix` which represents the transform from a ray originating at `[0, 0, 0]` and extending down the negative Z axis to the ray described by the `XRRay`'s `origin` and `direction`. This is useful for positioning graphical representations of the ray.


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
```
