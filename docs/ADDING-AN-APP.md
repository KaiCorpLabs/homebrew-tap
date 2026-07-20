# Añadir una app nueva al tap

Objetivo: que instalar una app nueva sea `brew install --cask <app>` desde este
tap, y publicarla sea un solo comando desde el repo de la app.

El modelo: **el fuente vive en un repo privado; el binario y la receta viven
aquí (público)**. Nadie ve tu código, pero cualquiera con el tap puede instalar.

## Requisitos de la app

Tu repo de app necesita producir un `.app` empaquetado. En DiskShelf eso lo hace
`Scripts/package_app.sh` (SwiftPM → bundle → firma ad-hoc). Cualquier app que
genere un `<AppName>.app` sirve; solo hay que adaptarle el `release.sh`.

Convenciones que dan por hecho las plantillas y `release.sh`:

| Cosa | Convención |
|------|-----------|
| Token del cask | minúsculas, sin espacios (`diskshelf`) |
| Etiqueta de la release | `<cask>-v<version>` (`diskshelf-v0.1.0`) |
| Nombre del asset | `<AppName>-<version>.zip` (`DiskShelf-0.1.0.zip`) |
| Contenido del zip | `<AppName>.app` en la raíz (usa `ditto -c -k --keepParent`) |
| Versión | en `version.env` del repo de la app (`MARKETING_VERSION`) |

## Paso 1 — crear la receta

Desde una copia local de este tap:

```sh
cp templates/cask.rb.tmpl Casks/miapp.rb
```

Edita `Casks/miapp.rb` y sustituye los `{{...}}`:

- `{{CASK}}` → token en minúsculas, p. ej. `miapp` (¡en dos sitios: `cask "..."` y el regex de livecheck!)
- `{{APP_NAME}}` → nombre del `.app`, p. ej. `MiApp`
- `{{DESC}}` → descripción corta (sin punto final, en minúscula inicial; es la convención de Homebrew)
- `{{REPO}}` → nombre del repo privado de la app en KaiCorpLabs
- `depends_on macos:` → versión mínima real de la app
- rutas de `zap` → dónde guarda datos la app en `~/Library`

Deja `version "0.0.0"` y el `sha256` de ceros tal cual; el primer release los
rellena. Haz commit y push del cask.

## Paso 2 — copiar el release script al repo de la app

Copia `Scripts/release.sh` (el de DiskShelf) al repo de tu app y ajusta arriba:

```sh
CASK_NAME=${CASK_NAME:-miapp}
APP_NAME=${APP_NAME:-MiApp}
```

Si tu app no se empaqueta con un `Scripts/package_app.sh` equivalente, adapta la
sección "Build" del script a como generes tú el `.app`.

## Paso 3 — publicar

En el repo de la app:

```sh
Scripts/release.sh
```

Eso hace, en orden:

1. compila universal (arm64 + x86_64) y monta el `.app`;
2. lo comprime en `dist/<AppName>-<version>.zip`;
3. calcula el `sha256`;
4. sube el zip como *release* `<cask>-v<version>` de **este tap**;
5. clona el tap, hace bump de `version` + `sha256` en `Casks/<cask>.rb` y `push`.

A partir de ahí:

```sh
brew update
brew install --cask --no-quarantine miapp   # primera vez
brew upgrade --cask miapp                    # siguientes versiones
```

## Paso 4 — documentar

Añade la fila de tu app a la tabla "Apps disponibles" del [README](../README.md).

## Publicar una versión nueva de una app existente

1. Sube `MARKETING_VERSION` (y `BUILD_NUMBER`) en el `version.env` de la app.
2. Commit del cambio de versión.
3. `Scripts/release.sh`.

No toques `sha256` a mano: lo recalcula el script. Si algo va mal a mitad, el
script es idempotente — vuelve a ejecutarlo (usa `gh release ... --clobber`).

## Notas

- **`--no-quarantine`**: las apps van firmadas ad-hoc, no notarizadas. Sin ese
  flag, Gatekeeper las bloquea la primera vez. Ver el README.
- **Universal**: se compila para Intel y Apple Silicon para que corra en
  cualquier Mac. Si tu app solo va a correr en Apple Silicon, pon
  `ARCHES=arm64` antes de `release.sh`.
- **Firmar de verdad**: si algún día sacas la app fuera del círculo de confianza,
  el salto es firmar con Developer ID + notarizar en el paso de build; el cask no
  cambia. A partir de ahí puedes quitar el `--no-quarantine`.
