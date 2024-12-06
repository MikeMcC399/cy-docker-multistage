# ONBUILD executed in grandchild

## Observed Behavior

If a `docker build` is executed using the Docker image [cypress/factory](https://github.com/cypress-io/cypress-docker-images/tree/master/factory) in a two-stage `Dockerfile` build, with the recommended

```Dockerfile
# syntax=docker/dockerfile:1
```

from [Custom Dockerfile syntax](https://docs.docker.com/build/buildkit/frontend/) then the `ONBUILD RUN` instructions from `cypress/factory` are executed correctly in the first build stage, and fail in the second build stage. The `ONBUILD` instructions can only be executed once, since they clean up after themselves and they delete resources which are no longer supposed to be necessary.

[cypress/factory](https://github.com/cypress-io/cypress-docker-images/tree/master/factory) is built with [factory/factory.Dockerfile](https://github.com/cypress-io/cypress-docker-images/blob/master/factory/factory.Dockerfile) and this includes:

```Dockerfile
# Global Cleanup
ONBUILD RUN apt-get purge -y --auto-remove \
    curl \
    bzip2 \
    gnupg \
    dirmngr\
  && rm -rf /usr/share/doc \
  && rm -rf /var/lib/apt/lists/* \
  # Remove cypress install scripts
  && rm -rf /opt/installScripts
```

This is a regression in `docker/dockerfile:1.11.0` and above:

| `docker/dockerfile` version | Result  |
| --------------------------- | ------- |
| undefined                   | success |
| `1`                         | fail    |
| `1.10.0`                    | success |
| `1.11.0`                    | fail    |
| `1.11.1`                    | fail    |
| `1.12.0`                    | fail    |

## Expected Behavior

The set of `ONBUILD` instructions from an existing Docker file should only be used in the first stage of a multi-stage build, not in the second or any following stages.

## Steps to reproduce

On Ubuntu `24.04.1` LTS, Node.js `v22.12.0` LTS, [Docker Desktop 4.36.0](https://docs.docker.com/desktop/release-notes)

```shell
git clone https://github.com/MikeMcC399/cy-docker-multistage
cd cy-docker-multistage
npm ci
docker build . -f Dockerfile.1 -t cy-test
```

using `Dockerfile.1`:

```Dockerfile
# syntax=docker/dockerfile:1
FROM cypress/factory AS first

COPY . /opt/app
WORKDIR /opt/app
RUN npm install cypress --save-dev
RUN npx cypress install

FROM first AS second

RUN apt-get update
RUN apt-get install chromium -y
```

## Logs

```text
$ docker build . -f Dockerfile.1 -t cy-test
[+] Building 94.7s (20/28)                                                                                                                                                                         docker:default
 => [internal] load build definition from Dockerfile.1                                                                                                                                                       0.1s
 => => transferring dockerfile: 267B                                                                                                                                                                         0.0s
 => resolve image config for docker-image://docker.io/docker/dockerfile:1                                                                                                                                    1.8s
 => docker-image://docker.io/docker/dockerfile:1@sha256:db1ff77fb637a5955317c7a3a62540196396d565f3dd5742e76dddbb6d75c4c5                                                                                     2.3s
 => => resolve docker.io/docker/dockerfile:1@sha256:db1ff77fb637a5955317c7a3a62540196396d565f3dd5742e76dddbb6d75c4c5                                                                                         0.0s
 => => sha256:61782c2b067b8aa6d6a5a44dda352a26cc0bcb2dcf01b45b6eea6fca5a518bba 850B / 850B                                                                                                                   0.0s
 => => sha256:b968edff90bd031526591b03dfbc60323746c2d57ae359d0bff26f2e971b0094 1.26kB / 1.26kB                                                                                                               0.0s
 => => sha256:dae058f2fffd4fce12a0791304a7160b8e92593dd7bb824d0c2aa12f346f9f2b 12.78MB / 12.78MB                                                                                                             2.0s
 => => sha256:db1ff77fb637a5955317c7a3a62540196396d565f3dd5742e76dddbb6d75c4c5 8.40kB / 8.40kB                                                                                                               0.0s
 => => extracting sha256:dae058f2fffd4fce12a0791304a7160b8e92593dd7bb824d0c2aa12f346f9f2b                                                                                                                    0.1s
 => [internal] load build definition from Dockerfile.1                                                                                                                                                       0.0s
 => [internal] load metadata for docker.io/cypress/factory:latest                                                                                                                                            1.3s
 => [internal] load .dockerignore                                                                                                                                                                            0.1s
 => => transferring context: 2B                                                                                                                                                                              0.0s
 => [first 1/5] FROM docker.io/cypress/factory:latest@sha256:ece75e68a6ef4b92c296b1bee68c4c7fcec7e30a2b0aff1394c7b6092aabd450                                                                               31.6s
 => => resolve docker.io/cypress/factory:latest@sha256:ece75e68a6ef4b92c296b1bee68c4c7fcec7e30a2b0aff1394c7b6092aabd450                                                                                      0.0s
 => => sha256:bc0965b23a04fe7f2d9fb20f597008fcf89891de1c705ffc1c80483a1f098e4f 28.23MB / 28.23MB                                                                                                             4.2s
 => => sha256:7e0a9cd7b743bea5b7e3c15257e5a44693f6b7adcfdd21b42349842ca82e5fec 163.09MB / 163.09MB                                                                                                          22.2s
 => => sha256:3dac0345d6caafaef6a8d9e008355a1ce7c6f48919891b30c8042ce22675f903 4.66kB / 4.66kB                                                                                                               0.8s
 => => sha256:ece75e68a6ef4b92c296b1bee68c4c7fcec7e30a2b0aff1394c7b6092aabd450 683B / 683B                                                                                                                   0.0s
 => => sha256:7ba1dee0d47c173e3b04bd88b44062d513adb02b022b63ffe8b181815e68d044 899B / 899B                                                                                                                   0.0s
 => => sha256:2a6063523a72719fcd3ff210bf3f88d5b722caa38e79dffb5015261e775b2b26 3.09kB / 3.09kB                                                                                                               0.0s
 => => extracting sha256:bc0965b23a04fe7f2d9fb20f597008fcf89891de1c705ffc1c80483a1f098e4f                                                                                                                    2.2s
 => => extracting sha256:7e0a9cd7b743bea5b7e3c15257e5a44693f6b7adcfdd21b42349842ca82e5fec                                                                                                                    8.9s
 => => extracting sha256:3dac0345d6caafaef6a8d9e008355a1ce7c6f48919891b30c8042ce22675f903                                                                                                                    0.0s
 => [internal] load build context                                                                                                                                                                            1.1s
 => => transferring context: 26.98MB                                                                                                                                                                         1.0s
 => [first  2/20] ONBUILD RUN bash /opt/installScripts/node/install-node-version.sh 22.12.0                                                                                                                 16.5s
 => [first  3/20] ONBUILD RUN node /opt/installScripts/yarn/install-yarn-version.js ${YARN_VERSION}                                                                                                          0.4s
 => [first  4/20] ONBUILD RUN node /opt/installScripts/chrome/install-chrome-version.js ${CHROME_VERSION}                                                                                                    0.4s
 => [first  5/20] ONBUILD RUN node /opt/installScripts/edge/install-edge-version.js ${EDGE_VERSION}                                                                                                          0.5s
 => [first  6/20] ONBUILD RUN node /opt/installScripts/firefox/install-firefox-version.js ${FIREFOX_VERSION}                                                                                                 0.5s
 => [first  7/20] ONBUILD RUN node /opt/installScripts/cypress/install-cypress-version.js ${CYPRESS_VERSION}                                                                                                 0.6s
 => [first  8/20] ONBUILD RUN apt-get purge -y --auto-remove     curl     bzip2     gnupg     dirmngr  && rm -rf /usr/share/doc   && rm -rf /var/lib/apt/lists/*   && rm -rf /opt/installScripts             1.6s
 => [first  9/20] COPY . /opt/app                                                                                                                                                                            0.6s
 => [first 10/20] WORKDIR /opt/app                                                                                                                                                                           0.0s
 => [first 11/20] RUN npm install cypress --save-dev                                                                                                                                                         1.6s
 => [first 12/20] RUN npx cypress install                                                                                                                                                                   34.1s
 => ERROR [second  1/17] ONBUILD RUN bash /opt/installScripts/node/install-node-version.sh 22.12.0                                                                                                           0.3s
------
 > [second  1/17] ONBUILD RUN bash /opt/installScripts/node/install-node-version.sh 22.12.0:
0.289 bash: /opt/installScripts/node/install-node-version.sh: No such file or directory
------
Dockerfile.1:9
--------------------
   7 |     RUN npx cypress install
   8 |
   9 | >>> FROM first AS second
  10 |
  11 |     RUN apt-get update
--------------------
ERROR: failed to solve: process "/bin/sh -c bash /opt/installScripts/node/install-node-version.sh ${APPLIED_FACTORY_DEFAULT_NODE_VERSION}" did not complete successfully: exit code: 127
```

## Workaround

Pin syntax to `1.10.0` in `Dockerfile.1.10.0`:

```Dockerfile
# syntax=docker/dockerfile:1.10.0
```

To test workaround, as above, except:

```shell
docker build . -f Dockerfile.1.10.0 -t cy-test  # pin to older version
npm test                                        # run Cypress test
```
