# Cosmos

A lightly customized build of [Aurora DX](https://getaurora.dev/) to suit my personal needs. Aurora DX is a build of Fedora Atomic, with an opinionated configuration for developers. Since it is built on OCI images, you can layer your own changes on top, and use GitHub Actions to build the images for you. Since Aurora is configured to automatically update, and Fedora Atomic has an immutable base, this means that this GitHub repo is the source of truth for my daily driver Linux install.

## Changes

- Applied rules to automatically disable my AverMedia Live Gamer HD 2 to work around a bug, and added scripts to enable/disable at runtime
- Installed Waydroid (ported from [Bazzite](https://bazzite.gg/)) for Android apps, specifically Apple Music
- Set my AMD GPU to use the 3D_FULL_SCREEN power profile, to work around a bug with power management with RDNA2 GPUs
