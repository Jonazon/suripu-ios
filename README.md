# Sense iOS App

## Development

* [Activity/Bug Tracker](https://trello.com/b/5zO3TPUz/sense-ios)

* [Build Release Checklist](https://hello.hackpad.com/iOS-Release-Checklist-6xtI96xm7kx)

### Branching

We are using [git flow](http://nvie.com/posts/a-successful-git-branching-model/).

All new code is added to branches forked from the `develop` branch, which is where everyday action happens. When releases are immiment, develop is merged into `master` and tagged with the latest version.

### Code Style

We are using a modified version of [WebKit style](http://www.webkit.org/coding/coding-style.html), detailed in the [style specification file](https://github.com/hello/suripu-ios/blob/develop/.clang-format). Notable differences are "attach" (same line) style for braces and a space in pointers.
