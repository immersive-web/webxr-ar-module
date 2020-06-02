# WebXR Augmented Reality Module

[![Build Status](https://travis-ci.org/immersive-web/webxr-ar-module.svg?branch=master)](https://travis-ci.org/immersive-web/webxr-ar-module)

The [WebXR Augmented Reality Module][21] extends the WebXR Device API to expose the ability to create a basic augmented reality (AR) session. This module is a product of the [Immersive Web Working Group][17].

## Taking Part

1. Read the [code of conduct][18]
2. See if your issue is being discussed in the [issues][21], or if your idea is being discussed in the [proposals repo][19].
3. We will be publishing the minutes from working group's bi-weekly calls.
4. You can also join the working group to participate in these discussions.

## Specifications
This repo is for the design of the [WebXR Augmented Reality Module][21] which extends the WebXR Device API to allow developers to create basic augmented reality sessions on compatible XR hardware.

### Related specifications
* [WebXR Device API - Level 1][1]: Main specification for JavaScript API for accessing VR and AR devices, including sensors and head-mounted displays.


## Relevant Links

* [Immersive Web Community Group][3]
* [Immersive Web Early Adopters Guide][16]
* [Immersive Web Working Group Charter][4]


## Communication

* [Immersive Web Working Group][17]
* [Immersive Web Community Group][3]
* [GitHub issues list: `webxr-ar-module`][22]
* [`public-immersive-web` mailing list][20]

## Maintainers

To generate the spec document (`index.html`) from the `index.bs` [Bikeshed][10] document:

```sh
make
```


## Tests

For normative changes, a corresponding
[web-platform-tests][11] PR is highly appreciated. Typically,
both PRs will be merged at the same time. Note that a test change that contradicts the spec should
not be merged before the corresponding spec change. If testing is not practical, please explain why
and if appropriate [file a web-platform-tests issue][12]
to follow up later. Add the `type:untestable` or `type:missing-coverage` label as appropriate.


## License

Per the [`LICENSE.md`](LICENSE.md) file:

> All documents in this Repository are licensed by contributors under the  [W3C Software and Document License](https://www.w3.org/Consortium/Legal/copyright-software).

<!-- Links -->
[1]: https://immersive-web.github.io/webxr/
[2]: https://immersive-web.github.io/webvr/
[3]: https://www.w3.org/community/webvr/
[4]: https://www.w3.org/2020/05/immersive-web-wg-charter.html
[5]: https://w3c.github.io/gamepad/
[6]: https://w3c.github.io/gamepad/extensions.html
[7]: https://lists.w3.org/Archives/Public/public-webvr/
[10]: https://github.com/tabatkins/bikeshed
[11]: https://github.com/web-platform-tests/wpt
[12]: https://github.com/web-platform-tests/wpt/issues/new
[13]: http://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
[14]: https://www.w3.org/community/about/agreements/cla/
[15]: https://www.w3.org/Consortium/Legal/2008/03-bsd-license.html
[16]: https://immersive-web.github.io/webxr-reference/
[17]: https://w3.org/immersive-web
[18]: https://immersive-web.github.io/homepage/code-of-conduct.html
[19]: https://github.com/immersive-web/proposals
[20]: https://lists.w3.org/Archives/Public/public-immersive-web-wg/
[21]: https://immersive-web.github.io/webxr-ar-module
[22]: https://github.com/immersive-web/webxr-ar-module/issues
