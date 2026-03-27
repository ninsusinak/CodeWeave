# CodeWeave

Interactive code map generator.

## Installation

### From source tarball:
1. Extract: `tar xzf codeweave-VERSION-ARCH.tar.gz`
2. Copy to system: `sudo cp -r CodeWeave-ARCH /opt/codeweave`
3. Run: `codeweave`

### From .deb package:
```bash
sudo apt install ./codeweave_VERSION_ARCH.deb
codeweave
```

## System Requirements
- Glibc 2.31+ (Ubuntu 20.04+, Debian 11+)
- GTK 3.0+ or Wayland compatible environment
- No additional dependencies required

## Uninstall
```bash
sudo apt remove codeweave
```

## Building from source
See the BUILD_GUIDE.md for development instructions.
