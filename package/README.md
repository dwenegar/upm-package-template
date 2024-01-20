# @DISPLAY_NAME@

[![Docs](https://img.shields.io/github/workflow/status/@GH_USER@/@GH_REPO@/Docs?label=Docs)](https://@GH_USER@.github.io/@GH_REPO@/)
[![License](https://img.shields.io/github/license/@GH_USER@/@GH_REPO@?label=License)](LICENSE.md)
[![Version](https://img.shields.io/github/v/tag/@GH_USER@/@GH_REPO@?label=Version&logo=semver&sort=semver)](CHANGELOG.md)

This is the @NAME@ package's README file.

## Prerequisites

*TBD*

## Usage

*TBD*

## Installing the Package

Open `Packages/manifest.json` with your favorite text editor.
Add the following line to the dependencies block:

```json
{
  "dependencies": {
    "@NAME@": "https://github.com/@GH_USER@/@GH_REPO@.git#upm"
  }
}
```

## Tests

The package can optionally be set as testable.
In practice this means that tests in the package will be visible in the Unity Test Runner.

Open `Packages/manifest.json` with your favorite text editor.
Add the following line after the dependencies block:

```json
{
  "dependencies": { ... },
  "testables": [
    "@NAME@"
  ]
}
```

## Configuration

*TBD*

## Versioning

`@NAME@` is versioned according to [Semantic Versioning](https://semver.org/).

## License

`@NAME@` is distributed under the [BSD-2-Clause license](LICENSE.txt).
