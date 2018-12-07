# Introduction
Since [immersive](https://immersive-web.github.io/webxr/#immersive-session) WebXR sessions (formerly known as "VR presentation") give complete control to the application to draw whatever it wants via WebGL, the user agent has no clear way to protect the user or restrict the content once it provides an immersive session. Thus, user agents must be particularly careful about when and under what conditions they allow applications to create immersive sessions. So far, that means requiring a user activation/gesture when calling `requestSession()`.

Among other things, this means that applications cannot request immersive sessions during page load. Most importantly, they cannot request such sessions when navigated to from _another_ immersive session on a different page, as would be required to enable seamless transitions between immersive WebXR experiences.

While there is a strong desire in the community to enable such seamless experiences, there are some important considerations for user security and safety. This document describes some of these considerations and proposes mechanisms and guidance to help ensure applications work correctly regardless of the decisions and mitigations made by a user agent.

In addition to transitions between pages, there may be scenarios where it is desirable to "automatically" enter an immersive experience even if the previous page was not in an immersive mode or - more likely - there was no previous page. This document addresses these scenarios as well.

## Definitions and Scope
For the purposes of this document, "automatic" creation of an immersive session refers to letting pages create WebXR Device API immersive sessions on page load without an explicit user activation (aka user gesture). While this has generally been discussed in the context of VR, it could also apply to immersive AR sessions as those also have full control of the display.

# User Scenarios
The following is a non-exhaustive list of possible scenarios where the question of whether to "automatically" enter an immersive experience (without user activation) may be relevant. Most are relevant both when the user is in a headset and when they are not, though some are more relevant when in a headset.
1. Navigation to a WebXR-enabled page. Either:
   1. The user clicks a link on a "2D page."
   1. The app navigates (e.g., sets `window.location`). Either:
      1. While in an immersive session
         * Note: This is currently the only way to navigate in an immersive WebXR experience. While the user can "click" something in a WebGL-generated scene, the user agent cannot determine intent and generally even associate that click with the navigation.
      1. While on a "2D page"
1. User navigates forward/backward via history (or is navigated, such as by the [History](https://developer.mozilla.org/en-US/docs/Web/API/History) interface) to a page that had an active immersive session before the user navigated away.
   * Note this is unlikely directly from an immersive session, though a user agent menu could be brought up over the immersive experience.
1. User selects a background/unfocused document (i.e., "tab") that had an active immersive session when the user switched away.
   * Note this is unlikely directly from an immersive session, though a user agent menu could be brought up over the immersive experience.
1. User opens a WebXR-enabled page from a bookmark.
1. User opens a WebXR-enabled page from a PWA icon.
1. User opens a WebXR-enabled page via a native launcher or other "deep-link" mechanism.
1. A native app opens a WebXR-enabled page (i.e., via an "intent").

# Concerns & Considerations

## Potential Threats
* Spoofing: Similar to the concerns about fullscreen, an immersive application could imitate browser or OS/platform UI in an attempt to obtain information or privileged access from the user.
* Spam: Obnoxious immersive ads could be displayed without the user having made any decision or having the opportunity to evaluate the page.
* Malicious actions: Users could be "rickrolled" or otherwise presented with intentionally disorienting or nauseating content.
* Well-intentioned but undesirable content: Even content from good actors may not be desirable for all users or audiences.

## Navigation & User Expectations
When the user is navigated to a new page, they need an opportunity to evaluate the page, its URL, especially the origin, and whether they want to interact with it (and thus allow it to use certain APIs). If a page was to start rendering an immersive experience as soon as it loads, the user would not have such an opportunity.

In addition, users have expectations (even if subconsciously) about how the platform works. Among these is that entering a URL or clicking a link or otherwise being navigated will not result in immersion or (requests for) other special capabilities. See also [Comparison to Other Web APIs](#comparison-to-other-web-apis). Related, many user agents provide an indication of the target URL, such as when hovering over a link, but implementations have no way to provide this within an immersive experience.

### Conflation with User Agent-Mediated Experiences
Should immersive APIs that allow more user agent mediation (i.e., “declarative API”) be added to the web platform, it may be difficult for users to distinguish these experiences, for which the user agent provides some protections, from WebXR experiences.
## Same-Origin vs. Cross-Origin Navigation
For navigation scenarios (#1 above), it may be relevant whether the target URL has the same origin as the existing page. Specifically, since the user has already interacted with the origin, it may be reasonable for implementations to be more permissive in such cases.

However, allowing one but not the other would lead to an [Inconsistent User Experience](#inconsistent-user-experience).

**TODO:** Should this be a MAY, SHOULD, or MUST in the specification?

## Comparison to Other Web APIs
We are not aware of any other web platform API that requires user activation that is granted general exceptions on navigation.

Fullscreen, which is the closest comparison to WebXRimmersive sessions, exits fullscreen when navigating. Although the spoofing threat is perhaps similar, immersive sessions are considerably more powerful and have a higher potential for user harm due to their immersive nature.

The bar for overcoming this precedent would be quite high and likely require mitigations.

The closest exception is Chrome’s current media autoplay policy, which allows user activation on one page to apply to the new page when both sides of the navigation have the same eTLD+1. See [Same-Origin vs. Cross-Origin Navigation](#same-origin-vs-cross-origin-navigation).

## Inconsistent User Experience
If "automatic" creation of immersive sessions is allowed in some scenarios (e.g., same origin navigation) but not others (e.g., navigation to a different origin), consistency - and, therefore, both usability and the user’s certainty in which mode they are in - may be undermined.

Note that any such signal that varies by user, site, or engagement with a site adds inconsistency to the platform and - more importantly - the user experience. This could also disadvantage smaller and/or newer sites.

## Implication of User Engagement or Consent
It’s possible that having an active immersive session would be used as an indication of user engagement or consent to provide additional capabilities to the application. For example, exposing details about controllers that could be used for fingerprinting.

If applications can sometimes “automatically” create such a session, such an indication is weakened, specification language becomes more complex, and the rules may be more confusing for developers (i.e., users report that the controllers work when the session starts in some cases but not others).

## Bypass Mechanism May Be Exposed to Web Applications Too
While it may seem reasonable to allow a native app to open a WebXR-enabled page (i.e., via an "intent") and have it "automatically" enter an immersive experience, browsers - and apps hosting web views - are also native apps. Thus, implementations must not allow this if the platform (not just one specific user agent implementation) allows web applications to trigger such actions or intents as it would bypass the other precautions put in place.

As Android allows web applications to use intents, intents should not be allowed to "automatically" enter an immersive experience without some additional level of protection to prevent (pages within) arbitrary browsers, WebViews, or other user agents from triggering this behavior. This concern may also exist on other platforms.

## Privacy

### Exposing State About the Client or Previous Page
Varying the behavior based on client state (e.g., is the UA displaying multiple tabs) or the state of the previous page (e.g., whether the previous page had an active immersive session) leaks state about the user and user’s behavior that is not otherwise available to applications.

This may be acceptable for same-origin transitions, since the application could have already known the state. However, this is not acceptable for cross-origin transitions, including history and background documents.

## Seamless Transitions
Ideally, navigating between "pages" would be completely fluid with no loading screen, fadeout, or other delays. Because of the way the web works, there is almost guaranteed to be some delay as the user agent fetches the next page. This is going to be even more noticeable when the user is immersed in an environment and can see nothing but the screen. While preloading, such as using a Service Worker could avoid some network latency, the page must still be loaded.

In addition to ensuring a safe experience, we may want to explore best practices for authors and implementations as well as APIs that facilitate reasonably seamless transitions between pages with immersive sessions. This may involve hints or other mechanism. As such solutions may interact with other specifications and/or be significantly more complex than the process of requesting an immersive session, they are likely out of scope for the initial solution.

# Normatively-Prohibited Scenarios
Implementations MUST NOT permit "automatic" creation of an immersive session:
* When an insecure origin is involved. In navigation cases, the previous and new origins must be secure. (This is somewhat redundant since WebXR Device API is only available on secure origins, but it is worth noting.)
* If the requesting page is loaded through a redirect.
  * If there is a redirect, the referring page or the user who, for example, bookmarked a page, has less certainty about the application that will be providing the immersive experience. While those actors may have "trusted" the target at some point and the page _could_ have changed without adding a redirect, abstracting the URL adds additional reason for user scrutiny.
  * There may be nuances here, but let’s start with this.

# Possible Mitigations
Implementers SHOULD consider the risks and concerns described in this document (and eventually in the specification) and MUST comply with any normative rules, such as [Normatively-Prohibited Scenarios](#normatively-prohibited-scenarios). Implementations MAY allow other scenarios as they see fit for their users and properties of the implementation. Implementers MAY wish to use some of the following mitigations.

We may also wish to add normative text related to some of these.

## Signals
User agents MAY use signals, especially from the user, to determine that it is safe and/or reasonable to allow a page to create an immersive session without user activation. The following is a non-exhaustive list of possible signals.

* Indication of previous user intent, such as engagement with the page or its origin. Examples include:
  * Bookmark
  * "Installation" of a PWA.
  * The user has visited the origin before or with some frequency
* Crowdsourcing or other server-based data
* Other heuristics
* Positive user response to a prompt/permission request (potentially persisted)
* User setting to allow specific origin(s)

## Visual Mitigations
User agents MAY allow an immersive session to be created but somehow take steps to protect the user or allow them to cancel the session or navigation before giving the application full control of the display. For example:
* Display an interstitial, preview, or similar mechanism that gives the user a clear signal of the new origin and opportunity to abort the navigation.
* Start the immersive session blurred until the user shows some intent and/or has the opportunity to process information about the new origin.

## Page Had Been Immersive
This mainly applies to the history and background document scenarios.

If the page was in an immersive mode when the user (was) navigated or switched away, it seems reasonable to allow it to resume an immersive experience when the user returns.

However, it should be noted that this is inconsistent with fullscreen behavior. Also, it is possible that the user had navigated or switched away from a page because they disapproved of the page’s content. It would be inappropriate to put the user into an immersive experience in such cases, and it is difficult to think of a way to differentiate these cases from normal user flows.

# Guidance for Application Authors
Tl;dr: Applications should not assume they can successfully request an immersive session when loaded (or focused), but they should use whatever mechanism would allow them to request such a session if the user agent allows it unless they do not want to automatically enter an immersive experience upon navigation.

User agents will make different decisions about the scenarios and conditions under which such sessions are allowed to be created, possibly even allowing the user to choose, so applications must not assume that an action will result in a seamless VR-to-VR transition or otherwise allow "automatic" creation of an immersive session.

The user agent is always in control and makes the ultimate decision. There is no condition or action that an application can take that guarantees "automatic" creation of an immersive session will be allowed. However, an application can ensure that an immersive session is _not_ created on navigation by not using the mechanism(s).

Applications that include immersive experience(s)  should always provide users an explicit mechanism for initiating it, even when "automatic" creation of an immersive session is allowed. This ensures that users can re-enter the immersive experience after exiting and allows users who did not trigger the automatic session creation to experience the content as well.

## A Better Solution for Same-Origin Navigation
As noted in [Seamless Transitions](#seamless-transitions), it may not be possible to provide a seamless transition between immersive sessions. The need to re-create graphics contexts and resources on each page will, without assistance from the UA, guarantee that there is some period during the navigation where no page-provided content is shown. If more seamelss transitions are desired, developers should consider using a [single-page application (SPA)](https://en.wikipedia.org/wiki/Single-page_application) where possible (same origin navigations) rather than actual navigations. This can ensure that navigations to same-origin "pages" remain in an immersive experience in _all_ implementations.

# Possible Normative Text
The following are some examples of normative text that we could choose to include in the normative text of the specification. This is mainly to facilitate discussion, though we could collect proposals here.
* Implementations MAY allow creation of an immersive session without user activation when the navigation is a result of a significant user action [or initiated from a native mechanism]. Examples include opening a bookmark, opening an installed web app (e.g., PWA), or launching a WebXR application from a native launcher.
* Implementations MAY allow creation of an immersive session without user activation when the navigation is to a previously-visited page in the same browsing session and the user is already in a headset. Examples include going back or forward in history or returning to a background application (e.g., a background "tab").
* Implementations MUST NOT allow creation of an immersive session without user activation when {the user has navigated from a page that did not have|the navigation occurred outside} an active immersive session.
