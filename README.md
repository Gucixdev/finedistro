# finedistro

Void Linux with **dinit** instead of runit, **elogind** + **dbus**, and everything else from this tree: finedesktop as the
session, our nnn, the dotfiles. Void because its init is a plain choice of one package set; glibc by default, `LIBC=musl` for musl.

Nothing here is an installer yet: it builds a root filesystem directory you can chroot into, put on a disk or boot in qemu.

| Path | What |
|---|---|
| `packages/` | package lists (`base`, `desktop`, `apps`), one name per line |
| `dinit.d/` | the service tree for `/etc/dinit.d`: `boot` waits for everything in `boot.d/` (udev, dbus, elogind, turnstiled, iwd, netman (our ../netman instead of NetworkManager), bluetoothd, tty1...). Services shared with the dotfiles are relative symlinks into `../.dotfiles`, not copies |
| `overlay/` | files copied over the rootfs: hostname, `profile.d/finedesktop.sh` (the tty1 login starts the desktop; tty1 is kmscon, with mouse, tty2 a plain agetty), Firefox `policies.json` |
| `uutils` | `./uutils ROOT`: the Rust coreutils (uutils, one multi-call `/usr/bin/coreutils`, every tool a symlink) replace GNU's C ones; Void has no package, so it is built with cargo; `UUTILS_VERSION` pins it |
| `check` | every package exists in Void's repo and `dinit-check` accepts the tree with `packages/base` installed (podman + network) |
| `build` | `out/rootfs`: packages, overlay, dinit.d, our `../nnn` and `../finedesktop/finedesktop-rs` compiled inside the image's libc |

```sh
./check           # fast
./build           # minutes, a few GB in out/
LIBC=musl ./build
```

## Boot order

`early-fs` -> `remount-root` -> `mountall`, `udev`, `modules`, `sysctl`, `hostname`, `loopback` -> `dbus-pre` -> `dbus` -> `elogind`
-> `turnstiled` (per-user dinit, for pipewire and wireplumber in `~/.config/dinit.d/`) and `tty1` (agetty; its login shell
runs `finedesktop-session`).

## Not done

- Never booted. `check` proves the service graph and the package names, not a boot. Next: a qemu disk image with a bootloader (limine is in the repo) and a kernel + initramfs; Void's `dinit` package does not ship the stage-1/3 glue, so `early-fs` and friends come from the dotfiles tree.
- No per-user services yet (pipewire, wireplumber, bluetooth applet): they go in `~/.config/dinit.d/` through turnstile.
- qlogin is meant to replace the tty login later.
- The finedesktop session wrapper still has `/data/flatpak` paths.
