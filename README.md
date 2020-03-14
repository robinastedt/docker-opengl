# Docker - Mesa 3D OpenGL Software Rendering (Gallium) - LLVMpipe, and OpenSWR Drivers

## About

Docker container bundled with the Mesa 3D Gallium Drivers: [LLVMpipe][mesa-llvm] & [OpenSWR][openswr], enabling OpenGL support inside a Docker container **without the need for a GPU**.

Modified to run ubuntu instead of alpine, and not very lightweight anymore. Reason for the fork is to generate a factorio maps webpage from my VPS without GPU support. Might contain installation of packages that are not needed for general purpose.

Forked from: https://github.com/utensils/docker-opengl

## Features

- Ubuntu 18.04
- LLVMpipe Driver (Mesa 19.0.8)
- OpenSWR Driver (Mesa 19.0.8)
- OSMesa Interface (Mesa 19.0.8)
- softpipe - Reference Gallium software driver
- swrast - Legacy Mesa software rasterizer
- Xvfb - X Virtual Frame Buffer

## Docker Images

| Image                       | Description             |
| --------------------------- | ----------------------- |
| `robinastedt/opengl:latest` | Latest/Dev Mesa version |
| `robinastedt/opengl:stable` | Stable Mesa version     |
| `robinastedt/opengl:19.0.8` | Mesa version **19.0.8** |
| `robinastedt/opengl:18.3.6` | Mesa version **18.3.6** |
| `robinastedt/opengl:18.2.8` | Mesa version **18.2.8** |

## Building

This image can be built using the supplied `Makefile`

Make default image (latest):
```shell
make
```

Make stable image:
```shell
make stable
```

Make all images:
```shell
make all
```

## Usage

This image is intended to be used as a base image to extend from. One good example of this is the [Envisaged][Envisaged] project which allows for quick and easy Gource visualizations from within a Docker container.

Extending from this image.

```Dockerfile
FROM robinastedt/opengl:19.0.8
COPY ./MyAppOpenGLApp /AnywhereMyHeartDesires
RUN apk add --update my-deps...
```

## Environment Variables

The following environment variables are present to modify rendering options.

### High level settings

| Variable                | Default Value  | Description                                                    |
| ----------------------- | -------------- | -------------------------------------------------------------- |
| `XVFB_WHD`              | `1920x1080x24` | Xvfb demensions and bit depth.                                 |
| `DISPLAY`               | `:99`          | X Display number.                                              |
| `LIBGL_ALWAYS_SOFTWARE` | `1`            | Forces Mesa 3D to always use software rendering.               |
| `GALLIUM_DRIVER`        | `llvmpipe`     | Sets OpenGL Driver `llvmpipe`, `swr`, `softpipe`, and `swrast` |

### Lower level settings / tweaks

| Variable         | Default Value | Description                                                                                                                                                              |
| ---------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `LP_NO_RAST`     | `false`       | LLVMpipe - If set LLVMpipe will no-op rasterization                                                                                                                      |
| `LP_DEBUG`       | `""`          | LLVMpipe - A comma-separated list of debug options is accepted                                                                                                           |
| `LP_PERF`        | `""`          | LLVMpipe - A comma-separated list of options to selectively no-op various parts of the driver.                                                                           |
| `LP_NUM_THREADS` | `""`          | LLVMpipe - An integer indicating how many threads to use for rendering. Zero (`0`) turns off threading completely. The default value is the number of CPU cores present. |

[openswr]: http://openswr.org/
[mesa-llvm]: https://www.mesa3d.org/llvmpipe.html
[Envisaged]: https://github.com/utensils/Envisaged
