---
name: aem-build-deploy
description: Build and deploy this multi-site AEM platform — the build.sh module targets, Maven profiles, local AEM defaults (localhost:4502 admin/admin), third-party JAR install, and CI helper scripts. Use when building, deploying, or troubleshooting a build for any module (ta/common/react/business-events/corporate/aussiespecialist/acl/config).
---

# Build & Deploy (Tourism Australia)

Multi-module Maven (Java 11, Maven 3.6.3) targeting a local AEM author at `localhost:4502` (admin/admin by default). Project version `12.33.0-SNAPSHOT`. `./build.sh` is the recommended entry point — it wraps Maven reactor commands (`mvn -am -pl :<artifact> ...`) and posts packages to `http://localhost:4502/crx/packmgr/service.jsp`.

## build.sh targets (recommended)

```bash
./build.sh all-install            # build + install ALL modules via the `deployable` container package
./build.sh ta-install             # australia.com   (:ta-ui, includes FE)
./build.sh common-install         # shared components (:tourismaustralia-common-ui)
./build.sh react-install          # React UI package (:tourismaustralia-react-ui)
./build.sh be-install             # business-events (:tourismaustralia-business-events-ui)
./build.sh corp-install           # corporate       (:corporate-ui)
./build.sh aussiespecialist-install   # ASP          (:aussiespecialist-ui)
./build.sh assets-install         # shared assets   (:assets-ui)
./build.sh config-install         # OSGi/run-mode config (:common-config)
./build.sh i18n-install           # i18n dictionaries (:common-i18n)
./build.sh acl-install            # ACLs            (:common-acl)
./build.sh content-install        # content package (:tourismaustralia-content)
./build.sh spring-install         # spring UI       (:tourismaustralia-spring-ui)
```

- Every `*-install` has a matching `*-package` target that builds the package without installing (e.g. `ta-package`).
- Most `*-install` targets skip tests (`-Dmaven.test.skip=true`) for speed.
- `dispatcher-install` packages the dispatcher config only (no install).
- Frontend-only: `./build.sh fe` (gulp build), `./build.sh fe-watch`.
- Deprecated aliases (`aus`, `asp`, `common`, `config`, …) still work but print a deprecation notice — prefer the `-install` names.

## Maven profiles (when invoking mvn directly)

Activated by `-D<prop>` flags (the build.sh targets set the equivalent skip-flags for you):

| Profile | Flag | Effect |
|---|---|---|
| `local` | `-Dlocal` | Target localhost:4502 author, admin/admin; enable CRX + bundle-status checks |
| `autoInstallPackage` | (with `-Plocal`) | Install content package |
| `autoInstallBundle` | `-PautoInstallBundle` | Install **bundle only** — fast path for Java-only changes |
| `aus.com` / `common` / `aussiespecialist` / `be` / `corp` | `-Daus.com`, `-Dcommon`, … | Activate that module |
| `config` / `i18n` / `acl` | `-Dconfig`, `-Di18n`, `-Dacl` | Activate config/i18n/acl modules |
| `all` / `all-author` / `all-publish` | `-Dall`, … | Build every module |
| `activate` | `-Dactivate` | Activate packages on author after install |
| `ci` | `-Dci` | Use `${host}/${port}/${user}/${password}` from CLI/env |
| `analysis` | `-Danalysis` | Enable JaCoCo coverage reporting |

Examples:
```bash
mvn clean install -Plocal -PautoInstallPackage          # full package deploy
mvn clean install -Plocal -PautoInstallBundle           # Java code only (no package rebuild)
mvn clean install -Danalysis                            # with coverage
mvn test                                                # unit tests
mvn checkstyle:check                                    # Java style
```

## Local AEM defaults

Defined in root `pom.xml`: `host=localhost port=4502 user=admin password=admin` (`cq.*` mirrors). Override for remote with `-Pci -Dhost=… -Dport=… -Duser=… -Dpassword=…`.

## Third-party JARs (one-time setup)

Required before first build — both JARs ship in the repo at `tourismaustralia/core/src/main/resources/lib/`:

```bash
mvn install:install-file -Dfile=tourismaustralia/core/src/main/resources/lib/QRCode.jar \
  -DgroupId=com.swetake.util -DartifactId=Qrcode -Dversion=1.0.0 -Dpackaging=jar -DgeneratePom=true

mvn install:install-file -Dfile=tourismaustralia/core/src/main/resources/lib/brightcove-services-6.0.0.jar \
  -DgroupId=com.coresecure.brightcove -DartifactId=wrapper -Dversion=6.0.0 -Dpackaging=jar -DgeneratePom=true
```

The `deployable` module embeds them into `/apps/tathirdpartylibraries/install`.

## Frontend

Primary FE module: `tourismaustralia-react/` (Node ≥ 20.11.0, Yarn). The Maven build auto-downloads Node 20.11.0 (frontend-maven-plugin) and runs webpack during the package build, so `./build.sh ta-install`/`react-install` build the FE too. For an inner dev loop use `yarn sync` (see the `aem-react-component` skill).

## CI helper scripts (`scripts/ci-cd/`)

| Script | Args | Purpose |
|---|---|---|
| `check-aem-status.sh` | `<HOST_URL> <PASSWORD>` | Poll `/system/console/bundles.json` until no bundle is Resolved/Installed |
| `restart-aem.sh` | — | `systemctl stop/start aem` (needs sudo) |
| `wait-author-startup.sh` | — | Tail author `stdout.log` for "Startup completed" |
| `deploy.sh` | `<target> <TARGET_URL> <SERVICE_URL> <PASSWORD>` | CI deploy orchestrator (mirrors build.sh) |
| `flush-dispatcher-cache.sh`, `restart-bundles.sh`, `deploy-*-dispatcher.sh` | — | Dispatcher cache flush / bundle restart / dispatcher deploys |

## Troubleshooting

- **Bundle inactive** → `/system/console/bundles` (Resolved/Installed = unsatisfied refs or missing third-party JAR).
- **Build fails on missing artifact** → run the third-party JAR install commands above.
- **Java-only change** → `-PautoInstallBundle` (or `*-package` + manual install) skips the slower package rebuild.
- **FE build issues** → confirm Node ≥ 20.11.0.
- **AEM unreachable** → verify author is up on `localhost:4502`; use `check-aem-status.sh`.
