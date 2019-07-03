# Privacy and security

The WebXR Device API enables developers to build content for AR and VR hardware that uses one or more sensors to infer information about the real world, and may then present information about the real world either to developers or directly to the end user. In such systems there are a wide range of input sensor types used (cameras, accelerometers, etc), and a variety of real-world data generated. This data is what allows web developers to author WebXR-based experiences. It also enables developers to infer information about users such as profiling them, fingerprinting their device, and input sniffing. Due to the nature of the Web, WebXR has a higher responsibility to protect users from malicious data usage than XR experiences delivered through closed ecosystem app stores.

### Sensitive information
In the context of XR, sensitive information includes, but is not limited to, user configurable data such as interpupillary distance (IPD) and sensor-based data such as poses. All `immersive` sessions will expose some amount of sensitive data, due to the user's pose being necessary to render anything. However, in some cases, the same sensitive information will also be exposed via `inline` sessions. 

# Protection types
WebXR must be structured to ensure end users are protected from developers gathering and using sensitive information inappropriately. The necessary protections will vary based on the sensitive data being guarded, and, in some cases, more than one protection is necessary to adequately address the potential threats exposed by specific sensitive information.

## Trustworthy documents and origins
When sensitive information can be exposed, the requesting document must be:
* [Responsible](https://html.spec.whatwg.org/multipage/webappapis.html#responsible-document)
* Of a [secure context](https://w3c.github.io/webappsec-secure-contexts/#secure-contexts)
* The [currently focused area](https://html.spec.whatwg.org/multipage/interaction.html#currently-focused-area-of-a-top-level-browsing-context)
* Of the [same origin-domain](https://html.spec.whatwg.org/multipage/origin.html#same-origin-domain) as the [active document](https://html.spec.whatwg.org/multipage/browsers.html#active-document)
* Of an origin not blocked by [feature policy](#feature-policy)
* **TODO** Address the outcome of [#732](https://github.com/immersive-web/webxr/issues/732)

### Focus and visibility
**TODO** Fill this in with what is agreed upon in [#724](https://github.com/immersive-web/webxr/issues/724) and [#696](https://github.com/immersive-web/webxr/issues/696).

### Feature policy
**TODO** Fill this in with what is agreed upon in [#308](https://github.com/immersive-web/webxr/issues/308), [#729](https://github.com/immersive-web/webxr/issues/729), [#730](https://github.com/immersive-web/webxr/issues/730), and [#731](https://github.com/immersive-web/webxr/issues/731).

#### Underlying sensors feature policy
In addition to the WebXR specific feature policy, feature policies for underlying sensors must also be respected if a site could isolate and extract sensor data that would otherwise be blocked by those feature policies. WebXR must not be a 'back door' for accessing data that is otherwise prevented.

## Trusted UI
**TODO** Fill this in with what is agreed upon in [#718](https://github.com/immersive-web/webxr/issues/718) and [#719](https://github.com/immersive-web/webxr/issues/719).

## User intention
It is often necessary to be sure of user intent before exposing sensitive information or allowing actions with a significant effect on the user's experience. This intent may be communicated or observed in a number of ways.

### User activation
[User activation](https://html.spec.whatwg.org/multipage/interaction.html#activation) is defined within the HTML spec as an action the user can take which can result in certain types of HTML elements becoming activated. For example, a button becomes activated when a user clicks it with a mouse. The concept of user activation differentiates user-caused events from injected events to prevent pages from spoofing user actions. Within a WebXR session, `XRInputSource.select`is also considered to be triggered by user activation.  For more information, see [Input events](input-explainer.md#input-events).

### Implied consent
A User Agent may use implied consent based, for example, on the install status of a web application or frequency and recency of visits. Given the sensitivity of XR data, caution is strongly advised when relying on implicit signals. 

### Explicit consent
It is often useful to get explicit consent from the user before exposing sensitive information. When gathering explicit user consent, User Agents present an explanation of what is being requested and provide users the option to decline. Requests for user consent can be presented in many visual forms based on the features being protected and User Agent choice. While often associated with the [Permissions API](https://www.w3.org/TR/permissions/), the concept of user consent does not have exact overlap. If sensitive data is protected by explicit consent and will be used during an `XRSession`, and consent has not already been obtained, it is strongly recommended that User Agents display the associated consent prompt prior to the session being created.

### Duration of consent
It is recommended that once explicit consent is granted for a specific [origin](https://html.spec.whatwg.org/multipage/origin.html) that this consent persist until the [browsing context](https://html.spec.whatwg.org/multipage/browsers.html#browsing-context) has ended. User agents may choose to lengthen or shorten this consent duration based upon implicit or explicit signals of user intent, but implementations are advised to exercise caution when deviating from this recommendation, particularly when relying on implicit signals.

### Querying consent status
**TODO** Fill this in with what is agreed upon in [#722](https://github.com/immersive-web/webxr/issues/722) and [#725](https://github.com/immersive-web/webxr/issues/725).

## Data adjustments
In some cases, security and privacy threats can be mitigated through throttling, quantizing, rounding, limiting, or otherwise adjusting the data reported from the WebXR APIs. This may sometimes be necessary to avoid fingerprinting, even in situations when user intent has been established.  However, data adjustment mitigations can only be used in situations which would not result in user discomfort.

### Throttling
Throttling is when sensitive data is reported at a lower frequency than otherwise possible. This mitigation has the potential to reduce a site's ability to infer user intent, location, or perform user profiling. However, when not used appropriately throttling runs a significant risk of causing user discomfort. In addition, under many circumstances it may be inadequate to provide a complete mitigation.  For example, 2D touch input data snooping has been proven possible at frequencies as [low as 20Hz](https://arxiv.org/pdf/1602.04115.pdf) via accelerometer data.

### Rounding, quantization, and fuzzing
Rounding, quantization, and fuzzing are three categories of mitigations that modify the raw data that would otherwise be returned to the developer. Rounding decreases the precision of data by reducing the number of digits used to express it. Quantization constrains continuous data to instead report a discrete subset of values. Fuzzing is the introduction of slight, random errors into the the data. Collectively, these mitigations are useful in WebXR to avoid fingerprinting, and are especially useful when doing so does not cause noticeable impact on user comfort.

### Limiting
Limiting is when data is reported only when it is within a specific range. For example, it is possible to comfortably limit reporting positional pose data when a user has moved beyond a specific distance away from an approved location. Care should be taken to ensure that the user experience is not negatively affected when employing this mitigation. It is often desireable to avoid a 'hard stop' at the at the end of a range as this may cause disruptive user experiences.

# Protected functionality
The sensitive information exposed via WebXR can be divided into categories that share threat profiles and necessary protections against those threats.

## Immersiveness
Users must be in control of when immersive sessions are created because the creation causes invasive changes on a user's machine. For example, starting an immersive session will engage the XR device sensors, take over access to the device's display, and begin presentation which may terminate another application's access to the XR hardware. It may also incur significant power or performance overhead on some systems or trigger the launching of a status tray or storefront.

Developers indicate the desire to create an immersive session by passing `immersive-vr` or `immersive-ar` into `xr.requestSession()`. 

```js
// VR button click handler
function onVRClick() {
  xr.requestSession('immersive-vr').then(onVRSessionCreated);
}

//AR button click handler
function onARClick() {
  xr.requestSession('immersive-ar').then(onARSessionCreated);
}
```

In response, the UA must ensure that:
* The function was invoked in response to a [user activation](#user-activation) event
* The request originates from a [trustworthy document and origin](#trustworthy-documents-and-origins)
* The request originates from a document that is [visible and has focus](#visibility-and-focus)
* The request originates from a document allowed to use the WebXR [feature policy](#feature-policy) as well as the [underlying sensors' feature policies](#underlying-sensors-feature-policies)
* User intention is well understood, either via [explicit consent](#explicit-consent) or [implied consent](#implied-consent)

If these requirements are not met, the promise returned from `requestSession()` must reject.

## Poses
### XRPose
When based on sensor data, calls to `XRFrame.getPose()` will expose sensitive information that may be misused in a number of ways, including input sniffing, gaze tracking, or fingerprinting.

Developers indicate the desire for `XRPose` data by calling `XRFrame.getPose()`.

```js
function onSessionRafCallback(XRFrame frame) {
    let motionControllerPose = frame.getPose(xrSession.inputSources[0], xrReferenceSpace);
}
```

For every call to `XRFrame.getPose()`, the UA must ensure that:
* User intention is well understood, either via [explicit consent](#explicit-consent) or [implied consent](#implied-consent); alternatively, in cases where the user experience is not negatively affected, [data adjustments](#data-adjustments) may be applied to prevent the fingerprinting of underlying sensor data
* The request originates from the document which owns the `XRFrame`'s `XRSession`
* The document is [visible and has focus](#visibility-and-focus)
* The `XRSession.visibility` is set to `visible` 
* **TODO** address issues [#696](https://github.com/immersive-web/webxr/issues/696) and [#724](https://github.com/immersive-web/webxr/issues/724)

### XRViewerPose
The primary difference between `XRViewerPose` and `XRPose` is the inclusion of `XRView` information. More than one view may be present for a number of reasons. One example is a headset, which will generally have two views, but may have more to accommodate greater than 180 degree field of views. Another example is a CAVE system. In all cases, when more than one view is present and the physical relationship between these views is configurable by the user, the relationship between these views is considered sensitive information as it can be used to fingerprint or profile the user.

Developers indicate the desire for `XRViewerPose` data by calling `XRFrame.getViewerPose()`.

```js
function onSessionRafCallback(XRFrame frame) {
    let viewerPose = frame.getViewerPose(xrReferenceSpace);
}
```

In addition to meeting the [`XRPose`](#xrpose) requirements, every call to `XRFrame.getViewerPose()` which will return more than one `XRView` must additionally ensure that:
* User intention is well understood, either via [explicit consent](#explicit-consent) or [implied consent](#implied-consent)
* If `XRView` data is affected by settings that may vary from device to device, such as static interpupillary distance, variations in screen geometry, or user-configured interpupillary distance, then the XRView data must be anonymized to prevent fingerprinting. Specific approaches to this are at the discretion of the user agent.
* If `XRView` data is affected by a user-configured interpupillary distance, then it is strongly recommended that the UA required explicit consent during the creation of the `XRReferenceSpace` passed into `XRFrame.getViewerPose()`.

## Reference spaces
### Unbounded reference spaces
Unbounded reference spaces reveal the largest amount of spatial data and may result in user profiling and fingerprinting. For example, this data may enable determining user’s specific geographic location or to perform gait analysis.

Developers indicate the desire for unbounded viewer tracking at the time of session creation by adding `unbounded` to either `XRSessionInit.requiredFeatures` or `XRSessionInit.optionalFeatures`. 

```js
function onARClick() {
  xr.requestSession('immersive-ar', { requiredFeatures: ['unbounded'] } )
  .then(onARSessionCreated);
}
```

In response the UA must ensure that:
* The document is allowed to use all the policy-controlled features associated with the sensor types used to track the native origin of an unbounded reference space
* User intention is well understood, either via [explicit consent](#explicit-consent) or [implied consent](#implied-consent)
* The XR device is capable of unbounded tracking

If these requirements are not met and `unbounded` is listed in `XRSessionInit.requiredFeatures` then the promise returned from `requestSession()` must be rejected. Otherwise, the promise may be fulfilled but future calls to `XRSession.requestReferenceSpace()` must fail when passed `unbounded`.

Once a session is created, developers may attempt to create an unbounded reference space by passing `unbounded` into `XRSession.requestReferenceSpace()`.

```js
let xrReferenceSpace;
function onSessionCreated(session) {
  session.requestReferenceSpace('unbounded')
  .then((referenceSpace) => { xrReferenceSpace = referenceSpace; })
  .catch( (e) => { /* handle gracefully */ } );
}
```

### Bounded reference spaces
Bounded reference spaces, when sufficiently constrained in size, do not enable developers to determine geographic location. However, because the floor level is established and users are able to walk around, it may be possible for a site to infer the user’s height or perform gait analysis, allowing user profiling and fingerprinting. In addition, it may be possible perform fingerprinting using the bounds reported by a bounded reference space.

Developers indicate the desire for bounded viewer tracking at the time of session creation by adding `bounded-floor` to either `XRSessionInit.requiredFeatures` or `XRSessionInit.optionalFeatures`. 

```js
function onVRClick() {
  xr.requestSession('immersive-vr', { requiredFeatures: ['bounded-floor'] } )
  .then(onVRSessionCreated);
}

xr.requestSession('inline', { optionalFeatures: ['bounded-floor'] } )
  .then(onInlineSessionCreated);
}
```

In response, the UA must ensure that:
* The document is allowed to use all the policy-controlled features associated with the sensor types used to track the native origin of a bounded reference space
* User intention is well understood, either via [explicit consent](#explicit-consent) or [implied consent](#implied-consent)
* The device is capable of bounded tracking

If these requirements are not met and `bounded-floor` is listed in `XRSessionInit.requiredFeatures` then the promise returned from `requestSession()` must be rejected. Otherwise, the promise may be fulfilled but future calls to `XRSession.requestReferenceSpace()` must fail when passed `bounded-floor`.

Once a session is created, developers may attempt to create a bounded reference space by passing `bounded-floor` into `XRSession.requestReferenceSpace()`.

```js
let xrReferenceSpace;
function onSessionCreated(session) {
  session.requestReferenceSpace('bounded-floor')
  .then((referenceSpace) => { xrReferenceSpace = referenceSpace; })
  .catch( (e) => { /* handle gracefully */ } );
}
```

In response, the UA must ensure that: 
* Bounded reference spaces are allowed to be created based on the restrictions above
* Any group of `local`, `local-floor`, and `bounded-floor` reference spaces that are capable of being related to one another must share a common native origin; this restriction does not apply when `unbounded` reference spaces are also able to be created
* `XRBoundedReferenceSpace.boundsGeometry` must be [limited](#limiting) to a reasonable distance from the reference space's native origin; the suggested default distance is 15 meters in each direction
* Each point in the `XRBoundedReferenceSpace.boundsGeometry` must be [rounded](#rounding) sufficiently to prevent fingerprinting while still ensuring the rounded bounds geometry fits inside the original shape. Rounding to the nearest 5cm is suggested.
* If the floor level is based on sensor data or is set to a non-default emulated value, the `y` value of the native origin must be [rounded](#rounding) sufficiently to prevent fingerprinting of lower-order bits; rounding to the nearest 1cm is suggested
* All `XRPose` and `XRViewerPose` 6DoF pose data computed using a `bounded-floor` reference space must be [limited](#limiting) to a reasonable distance beyond the `boundsGeometry` in all directions; the suggested distance is 1 meter beyond the bounds in all directions

If these requirements are not met, the promise returned from `XRSession.requestReferenceSpace()` must be rejected.

### Local-floor spaces
On devices which support 6DoF tracking, `local-floor` reference spaces may be used to perform gait analysis, allowing user profiling and fingerprinting. In addition, because the `local-floor` reference spaces provide an established floor level, it may be possible for a site to infer the user’s height, allowing user profiling and fingerprinting.  

Developers indicate the desire for `local-floor` viewer tracking at the time of session creation by adding `local-floor` to either `XRSessionInit.requiredFeatures` or `XRSessionInit.optionalFeatures`.

```js
function onVRClick() {
  xr.requestSession('immersive-vr', { requiredFeatures: ['local-floor'] } )
  .then(onVRSessionCreated);
}
```

In response, the UA must ensure that:
* The document is allowed to use all the policy-controlled features associated with the sensor types used to track the native origin of a `local-floor` reference space
* User intention is well understood, either via [explicit consent](#explicit-consent) or [implied consent](#implied-consent)
* The device is capable of `local-floor` tracking

If these requirements are not met and `local-floor` is listed in `XRSessionInit.requiredFeatures` then the promise returned from `requestSession()` must be rejected. Otherwise, the promise may be fulfilled but future calls to `XRSession.requestReferenceSpace()` must fail when passed `local-floor`.

Once a session is created, developers may attempt to create `local-floor` reference spaces by passing `local-floor` into `XRSession.requestReferenceSpace()`.

```js
let xrReferenceSpace;
function onSessionCreated(session) {
  session.requestReferenceSpace('local-floor')
  .then((referenceSpace) => { xrReferenceSpace = referenceSpace; })
  .catch( (e) => { /* handle gracefully */ } );
}
```

In response, the UA must ensure that: 
* `local-floor` reference spaces are allowed to be created based on the restrictions above
* Any group of `local`, `local-floor`, and `bounded-floor` reference spaces that are capable of being related to one another must share a common native origin; this restriction does not apply when `unbounded` reference spaces are also permitted to be created
* If the floor level is based on sensor data or is set to a non-default emulated value, the `y` value of the native origin must be [rounded](#rounding) sufficiently to prevent fingerprinting of lower-order bits; rounding to the nearest 1cm is suggested
* All `XRPose` and `XRViewerPose` 6DoF pose data computed using a `local-floor` reference space is [limited](#limiting) to a reasonable distance from the reference space's native origin; the suggested default distance is 15 meters in each direction

If these requirements are not met, the promise returned from `XRSession.requestReferenceSpace()` must be rejected.

### Local reference spaces
On devices which support 6DoF tracking, `local` reference spaces may be used to perform gait analysis, allowing user profiling and fingerprinting.

When creating an `immersive-vr` or `immersive-ar` session, developers do not need to explicitly request the desire for `local` viewer tracking. However, this desire must be indicated when creating an `inline` session by adding `local` to either `XRSessionInit.requiredFeatures` or `XRSessionInit.optionalFeatures`. 

```js
xr.requestSession('inline', { optionalFeatures: ['local'] } )
  .then(onInlineSessionCreated);
}

function onVRClick() {
  xr.requestSession('immersive-vr')
  .then(onVRSessionCreated);
}
```

In response, the UA must ensure that:
* The document is allowed to use all the policy-controlled features associated with the sensor types used to track the native origin of a `local` reference space
* If the session mode is `inline`, user intention is well understood, either via [explicit consent](#explicit-consent) or [implied consent](#implied-consent)
* The device is capable of `local` tracking

If the session is `immersive-ar` or `immersive-vr` and these requirements are not met then the promise returned from `requestSession()` must be rejected.  If the session is `inline` and has `local` listed in `XRSessionInit.requiredFeatures` then the promise returned from `requestSession()` must also be rejected. Otherwise, the promise may be fulfilled but future calls to `XRSession.requestReferenceSpace()` must fail when passed `local`.

Once a session is created, developers may attempt to create local reference spaces by passing either `local` into `XRSession.requestReferenceSpace()`.

```js
let xrReferenceSpace;
function onSessionCreated(session) {
  session.requestReferenceSpace('local')
  .then((referenceSpace) => { xrReferenceSpace = referenceSpace; })
  .catch( (e) => { /* handle gracefully */ } );
}
```

In response, the UA must ensure that: 
* `local` reference spaces are allowed to be created based on the restrictions above
* Any group of `local`, `local-floor`, and `bounded-floor` reference spaces that are capable of being related to one another must share a common native origin; this restriction does not apply when `unbounded` reference spaces are also permitted to be created
* All `XRPose` and `XRViewerPose` 6DoF pose data computed using a `local` reference space is [limited](#limiting) to a reasonable distance from the reference space's native origin; the suggested default distance is 15 meters in each direction

If these requirements are not met, the promise returned from `XRSession.requestReferenceSpace()` must be rejected.