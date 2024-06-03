# Bluefin DX Customized

A lightly customized build of [Bluefin DX](https://projectbluefin.io/) to suit my personal needs. Bluefin DX is a build of Fedora Atomic, with an opinionated configuration for developers. Since it is built on OCI images, you can layer your own changes on top, and use GitHub Actions to build the images for you. Since Bluefin is configured to automatically update, and Fedora Atomic has an immutable base, this means that this GitHub repo is the source of truth for my daily driver Linux install.

## Changes

- Installed `driverctl` to automatically disable my AverMedia Live Gamer HD 2, to work around a kernel bug that causes the card to reset every second if it is not being used. The `driverctl` rule is not yet applied in this image, but I plan on figuring that out
- Installed Waydroid (ported from [Bazzite](https://bazzite.gg/)) for Android apps
- Set my AMD GPU to use the 3D_FULL_SCREEN power profile, to work around a bug with power management with RDNA2 GPUs