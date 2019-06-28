# Privacy and security

The WebXR Device API enables developers to build content for AR and VR hardware that uses one or more sensors to infer information about the real world, and may then present information about the real world either to developers or directly to the end user. In such systems there are a wide range of input sensor types used (cameras, accelerometers, etc), and a variety of real-world data generated. This data is what allows web developers to author WebXR-based experiences. It also enables developers to infer information about users such as profiling them, fingerprinting their device, and input sniffing. Due to the nature of the Web, WebXR has a higher responsibility to protect users from malicious data usage than XR experiences delivered through closed ecosystem app stores.

### Sensitive information
In the context of XR, sensitive information includes, but is not limited to, user configurable data such as interpupillary distance (IPD) and sensor-based data such as poses. All `immersive` sessions will expose some amount of sensitive data, due to the user's pose being necessary to render anything. However, in some cases, the same sensitive information will also be exposed via `inline` sessions. 

# Protection types
WebXR must be structured to ensure end users are protected from developers gathering and using sensitive information inappropriately. The necessary protections will vary based on the sensitive data being guarded, and, in some cases, more than one protection is necessary to adequately address the potential threats exposed by specific sensitive information.

## Documents and origins
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
**TODO** Fill this in based on the information in [#638](https://github.com/immersive-web/webxr/pull/638) so that it adequately addresses [#393](https://github.com/immersive-web/webxr/issues/393) and [#485](https://github.com/immersive-web/webxr/issues/485).

# Appendix A: Proposed IDL
```webidl
// TODO: Add any necessary IDL
```