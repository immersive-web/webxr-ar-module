# Security and Privacy Questionnaire

This document answers the [W3C Security and Privacy
Questionnaire](https://www.w3.org/TR/security-privacy-questionnaire/) for the
WebXR Augmented Reality Module specification.

**What information might this feature expose to Web sites or other parties,
and for what purposes is that exposure necessary?**

This API doesn't give any new information to web sites compared to the WebXR
specification it is extending. It allows web sites to start a XR session as
"immersive-ar" which blends the real world behind the XR scene. The web sites
does not have access to the real world information (camera) and can only affect
how the blending is done.

**Is this specification exposing the minimum amount of information necessary to
power the feature?**

N/A (not exposing new information)

**How does this specification deal with personal information or
personally-identifiable information or information derived thereof?**

It's not exposing any PII or other informationn.

**How does this specification deal with sensitive information?**

It's not exposing any sensitive information.

**Does this specification introduce new state for an origin that persists
across browsing sessions?**

No.

**What information from the underlying platform, e.g. configuration data, is
exposed by this specification to an origin?**

No new information is exposed to an origin.

**Does this specification allow an origin access to sensors on a user’s
device**

No new sensor data is exposed compared to the WebXR specification that this
specification is extending. For reference, various sensor information are
exposed to web sites as part of WebXR.

**What data does this specification expose to an origin? Please also document
what data is identical to data exposed by other features, in the same or
different contexts.**

No new data is exposed to an origin. All exposed data comes from the core
specification that this specification is extending.

**Does this specification enable new script execution/loading mechanisms?**

No.

**Does this specification allow an origin to access other devices?**

No. Though, the WebXR specification allows to display the XR scene to a
different device (VR or AR headsets) which users of this specification may
benefit from. However, this is part of the core WebXR specification and isn't
changed as part of this specification. Some devices may however only be
accessible for "immersive-ar" instead of the "immersive-vr" mode that was
supported in WebXR originally.

**Does this specification allow an origin some measure of control over a user
agent’s native UI?**

No.

**What temporary identifiers might this this specification create or expose to
the web?**

None. However, WebXR exposes information such as sensors that could be used to
identify someone across multiple XR sessions. This isn't changed with this
specification.

**How does this specification distinguish between behavior in first-party and
third-party contexts?**

It doesn't make any difference but WebXR is disabled by default for third-party
contexts and can be enabled via a Feature Policy.

**How does this specification work in the context of a user agent’s Private
Browsing or "incognito" mode?**

This specification does not mandate a difference in behaviour.

**Does this specification have a "Security Considerations" and "Privacy
Considerations" section?**

Yes. It is WIP as of answering this questionnaire.

**Does this specification allow downgrading default security characteristics?**

No.

**What should this questionnaire have asked?**

N/A
