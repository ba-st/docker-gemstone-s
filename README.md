# Docker images for GemStone/S

**Unofficial** docker images for the GemStone/S 6.x object server.
This is a community project not endorsed by
[GemTalk](https://gemtalksystems.com).

*GemTalk, GemStone, GemBuilder, GemConnect, and the GemStone and GemTalk
logos are trademarks or registered trademarks of GemTalk Systems LLC.*

Based on [jgfoster/DockerForGemStone](https://github.com/jgfoster/DockerForGemStone).

## Contents

- [Supported versions](#supported-versions)
- [License key](#license-key)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [Building locally](#building-locally)

## Supported versions

| GemStone/S | Distribution | Published tag |
| ---------- | ------------ | ------------- |
| 6.7.2.1    | `x86_64`     | `6.7.2.1`     |

Images are published to the GitHub Container Registry:

```bash
docker pull ghcr.io/ba-st/gemstone-s:6.7.2.1
```

The base OS is `debian:13-slim`. Note that the GemStone/S 6.x tooling
(`startstone`, `startnetldi`, `topaz`, ...) is 32-bit even in the `x86_64`
distribution, so the image enables `i386` multiarch and installs the 32-bit
runtime libraries.

Older releases are not published, but can still be built from source: see
[Building locally](#building-locally). Versions below 6.7 use the `i686`
distribution.

## License key

The image does **not** ship a license key. GemStone looks for one at
`$GEMSTONE/sys/gemstone.key` (`/opt/gemstone/product/sys/gemstone.key`);
the distribution only provides `sys/example.key`. Provide your own key by
mounting it at that path, or by setting `KEYFILE` in the configuration file
described below.

## Quick start

```bash
docker run --detach \
  --name gemstone \
  --volume gemstone-data:/opt/gemstone/data \
  --volume /path/to/gemstone.key:/opt/gemstone/product/sys/gemstone.key:ro \
  --publish 50384:50384 \
  --publish 50385:50385 \
  ghcr.io/ba-st/gemstone-s:6.7.2.1
```

On the first start, if `/opt/gemstone/data/extent0.dbf` is missing, the
pristine extent shipped with the distribution is copied into place, so the
container starts with an empty repository.

Check that the services came up with:

```bash
docker exec gemstone gslist -cvl
```

## Configuration

### Environment variables

| Variable      | Default            | Description                        |
| ------------- | ------------------ | ---------------------------------- |
| `STONE`       | `gemserver<major>` | Stone name, e.g. `gemserver67`     |
| `STONE_PORT`  | `50385`            | Port registered for the stone      |
| `STONE_ARGS`  | *(empty)*          | Extra arguments for `startstone`   |
| `NETLDI`      | `netldi<major>`    | NetLDI name, e.g. `netldi67`       |
| `NETLDI_PORT` | `50384`            | Port registered for the NetLDI     |
| `NETLDI_ARGS` | *(empty)*          | Extra arguments for `startnetldi`  |

`STONE` and `NETLDI` are registered in `/etc/services` on the chosen ports
when the container starts.

### Volume

`/opt/gemstone/data` holds the extents and is declared as a volume. Mount it
to keep the repository across container recreations.

### Configuration files

Stone and system configuration live in `/opt/gemstone/conf/system.conf`, which
is also linked as `gemserver<major>.conf`, so the same file configures both.
`$GEMSTONE/data` is a symlink to that directory. Bind-mount over it to supply
your own configuration.

## Building locally

`local-build.sh` takes a GemStone/S version and derives the distribution
architecture from it:

```bash
./local-build.sh 6.7.2.1
```

This produces `gemstone:6.7.2.1`. The distribution is downloaded from
[GemTalk's download site](https://downloads.gemtalksystems.com/pub/GemStoneS/)
during the build, so only versions published there can be built.
