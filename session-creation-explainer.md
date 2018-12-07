# Session Creation and Configuration Explainer
**STATUS: Proposal**

One of the needs (so-called "breaking changes") we identified when renaming the spec to include XR was enabling detection of future features - extensions to WebXR. The most obvious and perhaps immediate example is AR capabilities.

The following proposal is based on exploration of these topics. While AR is a test case for the API shape and is used in examples, the intent is **not** to define any specific values outside the scope of WebXR Device API 1.0. Such values would be proposed alongside their respective features definitions but within the proposed framework.
# Background
## Querying Client Support
### Author Interests
Authors want to:
#### Provide "Enter VR" Buttons Only When the Client Supports It
This decision must be made passively without requiring user activation (aka user gesture) or potentially prompting the user. There will likely be equivalent buttons for AR - probably even for "magic window" use due to the likely need for user activation.

The author should be able to set appropriate expectations. Even if an AR application supports a fallback VR experience, the application likely wants to use appropriate language in such a button. For example, "view in your room" vs. "take a closer look in VR."
#### Ensure the Application Will Work (as Expected) Before it Starts
Some VR apps, for example, may really require 6 DoF or two controllers with five buttons and a trigger. Others might (have features that) require a front-facing camera or high resolution depth mesh. Neither authors nor users want the user to have the impression that they can experience an application and put on a headset only to find out that their hardware is not supported.

This becomes even more important for AR where the ability to render something in the real world is required, though many experiences could also be made to work in VR (see [Progressive AR Examples](#progressive-ar-examples)).
#### Minimize Development Effort and the Test Matrix
It is much easier to write and test an application for a specific hardware profile than it is to include fallbacks for other profiles and test various configurations.
### Concerns
However, the above must be balanced with the following concerns.
#### Fingerprinting
Each property of the client hardware that we expose has the potential to add one or more bits of information. This is especially important for data exposed passively, such as via methods that do not require user activation (aka user gesture) and/or do not have visible effects and cannot be put behind user consent/permission. For more information, see the Privacy Interest Group’s [Mitigating Browser Fingerprinting in Web draft](https://w3c.github.io/fingerprinting-guidance/).
#### Providing access to Content for as Many Users as Possible
Ideally, as many users/client devices as possible should be able to access web content. VR magic window is powerful - both for authors and users - because it makes WebXR-based VR content accessible to billions of devices even though the number of VR headsets is currently much smaller. Even if an experience is best with a two multi-button controllers connected to a powerful desktop computer, it should ideally still be accessible to a 3 DoF headset or even magic window on an older mobile device.

As noted earlier, this may not always be reasonably possible. However, the API should encourage this and/or make it the default expectation. (The so-called "pit of success" should be that most experiences are accessible in some way on all clients.)
##### Progressive AR Examples
For many AR scenarios, it is possible to provide at least some functionality on clients that are not AR-capable. This would have the same powerful effect as VR magic window.

For example, a 3D model (e.g., of furniture) could still be rendered in a flat display with the ability to rotate it as well as viewable in a VR headset with the ability to walk around it. Stickers _could_ be placed in a virtual world and mustaches could be placed on virtual characters, though these are much less interesting than the AR equivalent.

Even store or museum experiences could be made to work without AR, though the value is questionable and/or requires additional work to provide a virtual representation of the location. Thus, it may make sense to let the application decide whether and how to enable non-AR clients to access content, including whether to expose the underlying information via VR (using the same WebGL implementation) or by some other means.
## Creation / Initialization
It may be useful for implementations and/or platforms to know what features an application will use in order to:
* Select an appropriate XR implementation
  * For example, VR vs. AR.
* Only initialize those parts of the XR implementation that will be used
  * For example, to reduce power usage by not initializing functionality that will not be used.
* Customize the user consent check and/or prompt message or other UI treatments.
  * The privacy and/or security concerns may vary depending on the features being used.
## User Experience
### Initialization Failures for Attached Headsets
The most important thing is the user experience. For example, we don’t want a user to put on a headset only to find out their client is not supported.

In the current API design, if something in `xrDevice.requestSession({ immersive: true, ... })` fails, the user will be told to put on their headset and the app - and thus the user - may not know that the session could not be created until the user has put the headset on.

In some cases, there is not much we can do because determining capabilities, including device capabilities (i.e., pass-through camera on a desktop HMD) require starting the device runtime, which `SHOULD NOT` happen until `requestSession()` is called. In some cases, information (i.e., controller presence and capabilities) may not be available until the headset is donned, which is often the case for controller presence and capabilities. In addition, desktop SDKs try to allow fluidity in people turning devices on and off.

Thus, there may not be anything we can do in the spec to address this, at least for some capabilities. Options include pushing on OpenXR and other runtimes to provide more data without spinning up the runtime and/or donning the headset, not allowing certain things (e.g., controllers) to be requested/required, and [separating session creation from starting an immersive session ("presenting")](#additional-proposal-for-discussion-separate-session-creation-from-starting-presentation).
### User Activation Requirements
We have become accustomed to presentation to HMDs requiring a user activation (aka user gesture) while in-page "magic window" does not. However, AR sessions will require user activation, this will be a departure for in-page XR content (i.e., all smartphone AR experiences). Applications will want to provide smooth user experiences, and the spec should enable that.

Since real world understanding and camera/transparency will not be available when a page loads, applications will likely either want to display a poster image or provide a VR "magic window" preview. In both cases, they will likely need to display some sort of "Enter XR" button to invite the user to perform the necessary user activation. Once such activation is received, the application can create and switch to a non-immersive AR session. This should be similar to the process for switching to immersive sessions, though they both reference the same in-page `<canvas>` (see [issue #375](https://github.com/immersive-web/webxr/issues/375)).

Applications should be able to determine whether they need to wait for a user activation, just as they do for `video.play()`. However, even if the application has a user activation and can create an AR session, it may wish to wait for the user to click a button since requesting an AR session is likely to prompt the user for a permission. (**TODO**: File a spec issue.)
# Proposal: Separate capability detection from session configuration
This section contains a proposal that addresses many of the issues above. It is intended to be a baseline for discussion and hopefully something we can build on. There are some [Open Questions & Issues](#open-questions--issues) as well as [alternatives and extensions](#alternatives) that have their own advantages and disadvantages.
## Overview
This solution allows coarse capability detection while enabling finer-grained session and platform device configuration. The former are session **requirements** while the latter are **optional** requests. In other words, a query or request for the coarse capabilities will fail if they cannot be provided while the configuration options are wants or hints. Below, these are referred to below as **session requirement** and **session configuration options**, respectively.

Benefits include:
* Minimal fingerprinting increase
  * Since session creation requires user activation, may require permission, and/or may prompt the user in some configurations, it is less attractive as a fingerprinting mechanism than the silent but limited `supportsSession()`.
* Appropriate buttons can be displayed
* The application can express session configuration preferences
* Applications are encouraged to support all devices that support a coarse capability.
## Methods
While `supportsSession()` and `requestSession()` would continue to be used, they would accept different parameter types since they need to answer different questions. `requestSession()` would accept a **superset** of the properties that `supportsSession()` accepts. More on this below.

`supportsSession()` would:
* Be normatively **required** to not (`MUST NOT`) ever require user activation (aka user gesture).
  * This is critical to allow applications to display appropriate UI on page load.
  * See [Should `supportsSession()` Require User Activation?](#should-supportssession-require-user-activation)
* Be normatively **encouraged** to not (`SHOULD NOT`/`NOT RECOMMENDED`) require user interaction (i.e., responding to browser UI) to complete (fulfill or reject the promise).
  * In other words, there should be no prompts or permission requests.
  * This is critical to allow applications to display appropriate UI on page load without bothering the user. However, implementations MAY choose to require interaction if they feel it is necessary in certain cases. See [Should `supportsSession()` Normatively Prohibit Requiring User Interaction?](#should-supportssession-normatively-prohibit-requiring-user-interaction)
* Be normatively **encouraged** to not (`SHOULD NOT`/`NOT RECOMMENDED`) spin up the runtime. 
  * This is especially important for current desktop runtimes, which often display store UI when this happens.
* Resolve (success) only if the user agent thinks there is a good chance the session can support the specified coarse capabilities and reject otherwise. See [What Level of Confidence Should `supportsSession()` provide?](#what-level-of-confidence-should-supportssession-provide)

`requestSession()` would:
* Be required/allowed (depending on the options) to require user interaction, such as prompts or permissions.
* Potentially require user activation (aka user gesture).
  * For platform predictability, the spec could provide recommendations and/or normative requirements for various property combinations.
* Resolve (success) if and only if the user agent can create a session that supports the specified coarse capabilities and reject otherwise.
* Configure the session to support the optional capabilities to the best of its ability.
  * This `MAY` include user interaction if necessary.

When calling `requestSession()`, the application is effectively saying "I would like these capabilities and am willing to ask the user for them and use more power (and maybe even sacrifice performance) to have access to them. The application is also committing to abide by any associated requirements (i.e., if an option can improve performance but places restrictions on what the application can do).


As mentioned above, the options accepted by `supportsSession()` should be a **subset** of those accepted by `requestSession()`. For developer ergonomics, we should reuse the type passed to the former in the latter. Probably the simplest way to do that is to use the same first parameter for both methods and add a second parameter to `requestSession()`. Another option that might be simpler for developers to use would be to have `requestSession()` accept an object that inherits from the one accepted by `supportsSession()`. However, this might ultimately be confusing and lead to developers passing the same values to both and expecting `supportsSession()` to consider the additional options.

For example (name bikeshedding aside):
```javascript
supportsSession(XRSessionRequiredOptions requiredOptions);
requestSession(XRSessionRequiredOptions requiredOptions, XRSessionConfiguration requestedConfiguration);
```

We need to decide on whether the parameter types should be [Interfaces or Dictionaries](#extensibility-interface-vs-dictionary)
## Session Options
In general, flags or values that may have one or more of the following effects on some clients should be session options:
* Affect which physical device and/or runtime is used for a session
* Affect how the physical device and/or runtime is configured and is something that may not be configurable during session use
* Affect whether/which user permissions are required and/or prompts are displayed

Individual session options fall into two categories:
1. They represent - and enable selection of - distinct hardware modes, such as immersive (formerly "presentation") vs. inline (i.e., "magic window") .
2. They represent additive features, such as real world integration and understanding capabilities.

The second category only allows applications to specify additional features they would like to use. Applications cannot require that an additive option is _not_ present or enabled. For example, a created session may have AR properties and capabilities even if AR wasn't explicitly requested. In particular, applications cannot say they do _not_ want a translucent display, which is often associated with AR HMDs. (Applications should ensure they are render appropriately  on such displays by checking the `XREnvironmentBlendMode`.)

The other side of this contract is that implementations `SHOULD NOT` prompt the user for permissions for functionality that the application did not request nor should it spend resources enabling that functionality if possible. Implementations `MUST NOT` provide access to unrequested capabilities, such as via `XRSession` methods, as this could lead to applications relying on such behavior.

When specifying such options, care should be taken to ensure that the default value and implementation specification will not result in unexpectedly breaking applications that don’t request the option. For example, implementations should not enable foveated rendering or performance optimizations that may negatively affect the correctness of an application unless the application explicitly opts-in to that behavior.

While we could design the API to allow such exclusion, it complicates the API (i.e., adding tri-state values) and could encourage development patterns that unnecessarily exclude certain classes of devices.
### Capability & Feature Detection
With this proposal, there are three levels of capability/feature detection:
1. **Session requirement(s)**
1. **Session configuration options**
1. Standard feature detection

**TODO:** Expand on the first two, including the use of an interface and `XRSession` property for the first two.

Even if a requirement and option are successfully met or a feature does not require a session option, it may be possible that an API or individual feature is not (currently) available. Thus, applications may need to use standard feature detection mechanisms after the session is created. Such mechanisms should be clearly specified in the specification for the corresponding feature.
### Possible Session Options
The options defined in the first version of WebXR Device API (this repo) will continue to be limited, but we can think ahead to how the options might be used to test this proposal as well as make progress for other efforts, such as [Hit-test](https://github.com/immersive-web/hit-test).
#### Immersive vs. Not
This one is straightforward and well-known. This is the only one that will be in the initial version of the spec. It is a **session requirement**. Applications will likely want to check both states to determine whether they can display inline content and whether to display an "Enter XR" button.
#### Real World Integration (aka AR) [future]
There is a fuzzy collection of features that people categorize as "AR." This includes the ability to see the real world (e.g., translucent display or pass-through camera) and various ways of getting information about the physical environment. The API should allow detection of the fundamental capability without exposing too much information or enabling narrow requests that will lead to devices being excluded.

**Proposal**
There should be a coarse **session requirement** for the ability to understand and integrate the real world into the scene.

Note that the purpose of this option is whether the application needs the ability to interact with the real world, not about how things are rendered or appear. We can bikeshed on the name. "AR" Seems too ambiguous and overloaded, especially since it implies _not_ VR, which is not the case.

A positive response would mean:
* The real world will be displayed behind the scene (for pixels that are not fully opaque). (This is entirely handled by the user agent / hardware and does not _require_ the application to composite a video frame.
* The session supports some form or real world understanding and/or ability to place virtual objects in the real world.

The specific details should be worked out in other repos. However, one could imagine [Hit-test](https://github.com/immersive-web/hit-test) being the minimum set of capabilities.

**Additional "AR" capabilities**
With this minimum set of capabilities, many/most imperative "AR" use cases are _possible_. However, other capabilities may be added (via incubation) and applications will want to know whether they can use them. For example, plane detection or access to camera pixel data (see below). These capabilities may be requested and detected via **session configuration option** and/or normal feature detection mechanisms.
#### Plane Detection [future]
Plane detection is a progressive enhancement on top of [Hit-test](https://github.com/immersive-web/hit-test). It provides a nicer and more accurate way to detect planes, but it can also be polyfilled on top of hit-test. Therefore, it is optional and _not_ a session requirement.

On the surface, plane detection seems like it would be just another feature that could be detected via normal feature detection mechanisms. However, plane detection is a selectable option for multiple AR runtimes to avoid using the associated higher additional power for applications that are not using it.

Thus, it is likely that plane detection would be a **session configuration option** to allow the user agent to configure the runtime as necessary. We will need to separately evaluate whether all such capabilities should have such an option.
#### Forward-Facing Camera Pixel Data [future]
While the user agent is responsible for rendering the real world, some applications may want access to the (aligned) camera pixel data to do computer vision or create visual effects. This capability could be requested via a **session configuration option**. Requests containing this option would only be valid if the coarse "AR" capability is also requested.

Like other **session configuration options**, session requests containing this option would always succeed if the coarse **session requirement(s)** can be met. In other words, this is something that an app can request but not depend on. This has the benefit of encouraging applications to treat pixel data as a progressive enhancement. The downside is that applications that entirely rely on computer vision (i.e., place hats on people) cannot fail until the session is created. On the other hand, perhaps this is polyfillable to a rough extent and/or the app could support alternate models (i.e., manual placement of hats).
## Application Usage
### Detecting Session Configuration
Applications will want to know the configuration of the session that was created. This is an issue because a) unrecognized options may be ignored (see [Extensibility: Interface vs. Dictionary](#extensibility-interface-vs-dictionary)) and b) **session configuration options** are not guaranteed to be supported. (b) is not an issue for **session requirements** since a resolved promise indicates that these requirements have been met.

The best way to address both (a) and (b) is probably to add a read-only **session configuration options** member containing the _actual_ configuration to the `XRSession` object when it is created. Applications can then check the values when the promise is resolved or later and adjust logic as appropriate.
### Application Flow
The following is how an application that supports (and prefers in order) immersive AR, "smartphone AR," immersive VR, and "magic window" VR.
1. Determine whether each of those session types are supported and display appropriate UI
1. On an appropriate user activation (e.g., click on an "Enter XR" button), run the following steps.
1. If immersive AR sessions are supported, request an immersive AR session with appropriate **session configuration options**. If that succeeds, jump to the last step.
1. If non-immersive AR sessions are supported, request a non-immersive AR session with appropriate **session configuration options**. If that succeeds, jump to the last step.
1. immersive VR sessions are supported, request an immersive VR session with appropriate **session configuration options**. If that succeeds, jump to the last step.
1. If non-immersive VR sessions are supported, request a non-immersive VR session with appropriate **session configuration options**. If that succeeds, jump to the last step.
1. Report that the client is not supported.
1. When the first of these requests is resolved, [detect session configuration](#detecting-session-configuration) and initialize the experience.

One issue if the fallbacks is that the user activation may have been consumed by the first session request and not available for the next session request when the initial promise is rejected. This is especially important if [`supportsSession()` does not provide much confidence](#what-level-of-confidence-should-supportssession-provide) in whether `requestSession()` will succeed. See [How Should the User Activation Requirement be Handled in the Fallback Case?](#how-should-the-user-activation-requirement-be-handled-in-the-fallback-case)
## Example
The following example is for illustrative purposes only. The option names and values are not concrete parts of this proposal, and the values used in various configurations may not be realistic. This example is also not robust against inaccurate `supportsSession()` responses, denied permissions, etc.

```javascript
// Prefer immersive AR.
let sessionRequirements = {immersive: true, worldIntegration: true};
let sessionConfig = { foveated: true, planes: true, pixelData: true };
xrDevice.supportsSession(sessionRequirements).then(
  function() {
    // Display Enter (immersive) AR button.
  }
).catch(
  function(error) {
    // The first fallback is "inline AR" (aka smartphone AR).
    sessionRequirements = {mode: 'inline', worldIntegration: true};
    sessionConfig = { planes: true, pixelData: true };
    xrDevice.supportsSession(sessionRequirements).then(
      function() {
        // Display Start (inline) AR button.
      }
    );
  }
).catch(
  function(error) {
    // There is a limited VR fallback, so try immersive VR.
    sessionRequirements = {immersive: true, worldIntegration: false};
    sessionConfig = { foveated: true };
    xrDevice.supportsSession(sessionRequirements).then(
      function() {
        // Display Enter VR button.
      }
    );
  }
).catch(
  function(error) {
    // Finally, try "magic window" VR.
    sessionRequirements = {mode: 'inline', worldIntegration: false};
    sessionConfig = { };    xrDevice.supportsSession(sessionRequirements).then(
      function() {
        // Request VR "magic window" session, which does not
        // (generally) require user activation.
        // Note: The application could also choose to do this in all cases.
        startXrSession();
      }
    );
  }
).catch(
  function(error) {
    // Display "Your client is unsupported."
);

function startXrSession() {
  xrDevice.requestSession(sessionRequirements, sessionConfig);
}

function onXRButtonClicked() {
  startXrSession();
}
```
# Open Questions & Issues
## Extensibility: Interface vs. Dictionary
We’ll need to decide whether the options parameter(s) should be interface(s) and/or dictionary(ies). Interfaces allow feature detection by simply checking for the presence of a member on the interface, but passing an object with an unrecognized member (i.e., one added in a future version) will cause the method to throw an exception. Dictionaries ignore unrecognized members when converting from script to WebIDL, so it is not possible for the user agent to indicate an unrecognized parameter.

Given the different intents for the two parameters, it may make sense for **session requirements** to be in interface (throw on unrecognized members) and **session configuration options** to be a dictionary (ignore unrecognized members).
## Support for Deferred Sessions
Navigation and other types of "deferred sessions" ([pull request #256](https://github.com/immersive-web/webxr/pull/256)) will likely result in an `XRSession` object just like `requestSession()`. Regardless of whether we use the `requestSession()` method, the mechanism should probably support the same set of options.

Applications will probably need to be permissive/adaptive somehow, so a single set of **session requirements** may not be sufficient. For example, a page needs to be able to adapt to whether the headset has AR capabilities or not. In other words, a single `requestSession({deferred: true, ...})` call may not be sufficient. We should include this consideration and this proposal in discussion of those capabilities. Similarly, if we think this proposal cannot support deferred sessions, we should explore those concerns here.
## Should VR be the Baseline?
In this document and similar discussion, we assume that VR is the baseline or default and that developers should request AR or other features. This is likely influenced by the order in which devices have come to market and that the features have been incubated. We should make sure this makes sense from an API perspective.
## Help Developers Support as Many Users as Possible
The community should investigate and publish application models and best practices to help developers build applications that work regardless of the modality.
## Coordination of Session Options
As the main spec moves forward and additional features incubate at various paces, it may become difficult for developers and implementers to keep track of all the possible options in various implementations and phases of incubation and standardization. Therefore, it may be useful to maintain a list of all known options regardless of their maturity.

As an example, Feature Policy [non-normatively references](https://wicg.github.io/feature-policy/#features) this [companion document](https://github.com/WICG/feature-policy/blob/master/features.md). The W3C has also proposed [Repositories](https://www.w3.org/wiki/Repositories) as a solution to such use cases. (We may even want to maintain a list of all extension specs to the version of the WebXR Device API specification that is being maintained by the Working Group regardless of whether they have a corresponding session option. See [Should All Extensions to WebXR Device API Have a Corresponding Session Option?](#should-all-extensions-to-webxr-device-api-have-a-corresponding-session-option))
## Should All Extensions to WebXR Device API Have a Corresponding Session Option?
In the proposal, not all features are required to have a session option. For example, [Hit-test](https://github.com/immersive-web/hit-test) would not, though it may be implied by the "AR" option. On the other hand, [Plane Detection](#plane-detection-future) would have a session option because some implementations may benefit from knowing whether to enable this feature for the session.

We could, however, require that all such extensions to the core WebXR Device API to require a session option. The primary reason to do this is that some future implementation may benefit from this signal. A minor benefit is that this would be an easy way to ensure [coordination](#coordination-of-session-options), though this can also be done without requiring a session option.

Disadvantages of this approach include that it could be a burden on developers that want to use a set of commonly available features and that this would become redundant if/when extensions are added to the core WebXR Device API by the Working Group.
## What Level of Confidence Should `supportsSession()` provide?
In [Methods](#methods), implementations are encouraged to resolve the promise returned by `supportsSession()` only when they think there is a good chance the session can support the specified coarse capabilities. We need to decide how much confidence the user agent should have and how much developers should rely on this signal.

If implementations are over-optimistic, users may be led to think they can enter an experience - and [even put on a headset](#initialization-failures-for-attached-headsets) - when the experience is not actually supported on their client. If implementations are more conservative, users could be prevented from using experiences their system actually supports.

For immersive VR, smartphone-based VR systems already stress this as the implementation has no way of knowing whether the user actually has the headset nearby. The failure mode of clicking a button seems pretty reasonable, though, as the user can just exit the platform’s prompt to put the phone in a headset.

On desktop, accuracy for immersive VR should be high as current desktop VR SDKs can report whether a device is detected without starting the runtime. However, more advanced information, such as whether the connected device supports AR (i.e., has a pass-through camera) is not available without starting the runtime. Thus, for immersive AR, it seems likely that implementations will either need to spin up the runtime or the responses provided to applications will be very inaccurate. In the near term, most desktop HMDs will not support immersive AR, but implementations might choose to report success to avoid blocking experiences for users that do have such HMDs.

If the level of confidence implementations can provide for AR capabilities is so low, then perhaps we should consider not exposing much more than whether the application should display an enter XR button. This would be unfortunate for non-immersive AR since implementations should have the same confidence as they do for non-immersive VR. One option to address that would be to have an enum of modes (non-immersive-vr, immersive-vr, non-immersive-ar). Both of these options would be unfortunate for AR HMDs that know for sure they can support immersive AR.

Perhaps the best option is to work with the major SDK owners, some of which are in this group, to provide this data without requiring the runtime to spin up. Long-term, though, it may be most important whether OpenXR can provide this.

Even if the SDKs could provide this information, obtaining it (or even the presence of devices) is not free on all implementations. Implementations may need to load the SDK and make a call. In Chrome’s case, this will involve starting a process. Thus, if we want to provide developers with accurate information, it is important that developers avoid misuse of this API. For example, developers should only call it when they actually need to know whether to display UI and not every time a library or the home page is loaded. (Things like this happen!) Calls to this API are not free like other feature detection mechanisms.
## Should `supportsSession()` Require User Activation?
This question seems simple since requiring a user activation (aka user gesture) would break the "Enter XR" button use case. However, if accurately responding to this call requires calling or even spinning up a third-party runtime, as discussed in the previous section, there could be security and/or privacy concerns with allowing any document or frame to call it.
## Should `supportsSession()` Normatively Prohibit Requiring User Interaction?
In [Methods](#methods), implementations are encouraged to resolve or reject the promise returned by `supportsSession()` without involving the user in any way with the intent being that applications can display appropriate UI on page load and without bothering the user. However,  it is permissible for implementations to require user interaction if they feel this is appropriate. This is intended to allow user agents to make decisions about fingerprinting, privacy impacts, etc.

The question is whether this encouragement should be a requirement, effectively removing agency from implementations. The argument for doing so is that developers should be able to rely on consistent behavior and are likely to assume this method is silent regardless of what the spec says.

Even if we chose MUST now, the standard could always be changed, and it might be better to standardize on a new behavior if/when that becomes necessary rather than leave open the potential for unexpected behavior now. In addition, we can always allow for different behavior for individual **session requirements** if/when they are added.

Note that the proposal currently prohibits requiring user activation (aka user gesture). We could also discuss this, but the thinking is that no applications will be designed to handle this and the real privacy issues can be sufficiently mitigated by the allowed user interaction.
## Should Orthogonal and Additive Session Requirements be Differentiated?
[Session Options](#session-options) says individual options should either select between orthogonal modes or additive features. It could be confusing if these are mixed in the same structure.

Do developers need to be aware of this difference? If so, (how) should we make it obvious which type each option falls under?
## How Should the User Activation Requirement be Handled in the Fallback Case?
As noted in [Application Flow](#application-flow), the user activation token used for one call to `requestSession()` may not be available when that request fails. Thus, any fallback attempts to request alternate session configuration may fail due to a user activation requirement. How can we change the API or what normative requirements can we make to avoid this?

One option might be to remember that there was a user activation in the `XRDevice` until a session is successfully created, possibly with some timeout.
## Should `supportsSession()` Consider Permissions and Similar Factors?
No matter the [accuracy of the `supportsSession()` logic](#what-level-of-confidence-should-supportssession-provide), `requestSession()` may fail due to declined permissions and similar factors. While implementations cannot know how a user will respond when no permission response is persisted, it does know if a permission has been blocked. Should `supportsSession()` consider this in its response?
## Do developers need the ability to choose different options if one is not supported?
In the proposal, applications request **session configuration options** all at once and will get a session configured with as many of those options as possible. However, there is no indication of priority from the application or even a specification of how implementations should prioritize them. For example, if one option is incompatible with another, the user cannot indicate which they prefer and implementation might choose differently. The latter is a platform predictability issue that will probably need to be addressed.

In addition, developers might want one set of options if feature _foo_ is available and another set if it is not. For example, maybe options in the first set consume more power but are only useful to the application if _foo_ is available.

Is it worth complicating the API to support preferences and/or sets of options?
# Alternatives
The following are potential alternative solutions. Some may be compatible with the proposal and/or each other. Many are inspired by the [Open Questions & Issues](#open-questions--issues).
## Use the Same Type for Both Methods
This was the original design. The primary advantage is that this might be simpler for developers. Disadvantages include that the API must either expose very few options or risk increasing fingerprinting entropy and the likelihood that developers target specific form factors.
## Configuration Method
We could allow applications to call a method with name-value pairs to request specific configurations. This has the advantage of avoiding a large dictionary and directly reporting the result of each requested part of the configuration. Applications may even be able to make different choices depending on the results of earlier calls. There are two variants of this.
### Initialization Only
In this variant, the configuration method could only be called before the session is used. As such a method can only be called after the `XRSession` is created and some implementations may not be able to change the configuration, we might need to add a separate `XRSession.Start()` method to be called when configuration is complete. See also [Additional Proposal for Discussion: Separate Session Creation From Starting Presentation](#additional-proposal-for-discussion-separate-session-creation-from-starting-presentation).
### Support In-Session Changes
In this variant, configuration changes can be requested while the session is running (i.e., presenting). This could be useful for allowing applications to request options that might require/consume resources only when the application need them and release them when they are no longer needed.

As an example, an application that needs [Plane Detection](#plane-detection-future) for some features or use cases could only request this functionality when 

Disadvantages include that platforms may not support such mid-session changes, especially seamlessly, and that this would complicate implementations and applications. We could always add this to the API if it turns out to be useful.
## Support Seamless Transitioning Between Sessions
Another variant of the above alternative would be to allow the application to create sessions with different properties and seamlessly transition between them. It seems likely that implementing such seamless transitions between immersive configurations would be difficult on some platforms. (See also [issue #375](https://github.com/immersive-web/webxr/issues/375), which explores similar issues but need not be seamless.)
## Expose Separate Levels of Capability Detection
Perhaps the biggest open technical issue is how to silently provide [accurate responses from `supportsSession()`](#what-level-of-confidence-should-supportssession-provide) (so applications can display appropriate "Enter XR" buttons) without the implementation having to start additional processes and/or spin up the runtime, especially since [`supportsSession()` does not require user activation](#should-supportssession-require-user-activation). At the same time, we do not want applications to have to request a session in order to get an accurate response since that can involve permission prompts and other UI. Currently, creating an immersive session also [starts presentation](#additional-proposal-for-discussion-separate-session-creation-from-starting-presentation).

We could separate the levels of confidence into separate methods. For example, one method could provide simple answers about whether it is even possible that the client supports a configuration while a second method would query the runtime to get more confidence. In the first method, the implementation might respond positively to a request for immersive AR if a runtime that supports such devices is installed even though there is a good chance such a device is not connected. If necessary, the implementation of the second method might start a process or even spin up the runtime if necessary to accurately answer the question. The expectation for the second method would be near perfect consistency with `requestSession()` (except for the impact of [permission requirements](#should-supportssession-consider-permissions-and-similar-factors) and similar factors).

However, would developers use both these methods and do so correctly? Would developers only use the second method because it is accurate? Would they only use the first method because the second is so close to `requestSession()`?
## Separate Session Creation from Starting a Session
In both the current and proposed model, creation of a session as initiated by `requestSession()` is an indication from the application that it intends to use a session and that the implementation can start using resources, requesting, permissions, etc. Currently, it also means that the application wants to start using that sessions, including [starting presentation](#additional-proposal-for-discussion-separate-session-creation-from-starting-presentation).

We might be able to address some of the [Open Questions & Issues](#open-questions--issues) and address problems related to [Initialization Failures for Attached Headsets](#initialization-failures-for-attached-headsets) by allowing applications to create a session, indicating that they are okay with user-visible effects, without starting that session.

This might have the same effect as [Exposing Separate Levels of Capability Detection](#expose-separate-levels-of-capability-detection) and would be consistent with the idea of adding `XRSession.Start()` mentioned in [Configuration Method](#configuration-method). However, it might not be appropriate for an application to request/create a session just to determine whether it should display an "Enter XR" button.
## Move Capability Detection to `requestDevice()`
We could move simple capability detection to `requestDevice()` and have applications use that to determine whether to, for example, display an "Enter XR" button.  `supportsSession()` would then provide a [high-confidence](#what-level-of-confidence-should-supportssession-provide) response. This would be similar to [Exposing Separate Levels of Capability Detection](#expose-separate-levels-of-capability-detection) and could be solved in other ways such as [separating session creation from starting a session](#additional-proposal-for-discussion-separate-session-creation-from-starting-presentation).

Most importantly, it would significantly affect the `XRDevice` abstraction. While this would significantly complicate it and `requestDevice()` from what we have today, it would also move us in a direction that would make more sense if the API was ever to support exposing multiple devices at the same time.

Perhaps the biggest problem this creates is for transitioning between non-immersive to immersive sessions. Currently, there is a single `XRDevice` instance on which different types of sessions are requested. If we moved to this model, applications may need to create sessions on different `XRDevice` instances when switching between these modes. Similar issues may apply to switching between even inline VR and inline AR modes.

We would likely have to figure out how to represent whether capabilities are on the same physical device (i.e. display) - and deal with the privacy considerations of doing so.
## User Agent Determines Whether to Display a Button
The primary use case for `supportsSession()` is for applications to be able to display an appropriate button for entering immersive VR, initiating AR, etc. We could make the implementation responsible for determining whether to display such a button - and which type of button. For example, via CSS properties. We could even make the implementation responsible for displaying the button (i.e., over the <canvas>).

In theory, this could help with fingerprinting since the individual properties cannot be queries. However, that is unlikely to be true since applications could check the CSS properties and maybe even whether part of the page is obscured. It would also take a capability from developers and bake things into the user agent, which should be avoided if possible.
## Provide No or Limited Capability Detection
In this case, applications would have no indication of capabilities until `requestSession()` is called. In one variant, limited information such as the presence of a device, would be exposed.

The primary drawback is that applications would likely always need to provide a generic "Enter XR" button. There could, for example, be no differentiation for VR or AR. (This would be unfortunate since the ecosystem is exploring different icons to represent the experience.) In the variant with limited information, the application would at least know whether it should display _no_ button.
# Additional Proposal for Discussion: Separate Session Creation From Starting Presentation
As noted in [Initialization Failures for Attached Headsets](#initialization-failures-for-attached-headsets), applications may not be able to detect limitations or the lack of features they consider required until after the user has (started to) put on a headset.

We could address this, as well as other issues mentioned earlier, by separating creating a session, which includes spinning up the runtime and enables definitively checking all capabilities, from starting a session, especially presentation. For example, we could add a `Start()` method to `XRSession`.

At a high level, this would result in the following flow:
1. The application calls `XRDevice.supportsSession()` to decide whether to display an "Enter XR" button.
1. The user clicks the "Enter XR" button.
1. The application calls `XRDevice.requestSession()` to start the process of presenting, committing to user-visible behavior, including spinning up the runtime, permission prompts, etc.
1. If the above promise is rejected, the application displays an error in the "flat" UI and aborts this flow.
1. When the above promise resolves, the application calls `XRSession.Start() to start presenting.
1. The implementation tells the user to put on the headset.
1. The user puts the headset on and enters the experience.

This last three steps can only fail if something goes wrong with the runtime or application’s rendering logic. The capabilities were checked and the user granted permission as part of the `XRDevice.requestSession()` call.

# Appendix: Capabilities
The following is an (incomplete) list of capabilities that applications might want to request or detect. The purpose is only to stimulate thought and discussion. Some of these may be candidates to be exposed as options while others may not. It seems very unlikely that any of these would become **session requirements**.

**General:**
* Headset: 3 vs. 6 DoF
  * This may be useful, for example, to determine whether to use cameras to get 6-DoF vs. a lower-power sensor-based 3-DoF implementation.
* Magic "window": 0 vs. 3 vs. 6 DoF
* Opacity details
* Foveated rendering
* Controllers
  * Number
  * Number of buttons
  * Trigger?
  * Haptics
* Trackables
* Haptics

**"AR":**
* [Plane Detection](#plane-detection-future)
* Mesh support
* Occlusion
* [Forward-Facing Camera Pixel Data](forward-facing-camera-pixel-data-future)
* Illumination estimation
* Image-based anchors
* Cloud anchors
* Distance accuracy (example use cases: virtual tape measure, furniture shopping)
* Geospatial alignment
* Geolocation accuracy (example use case: Call Before You Dig application)
