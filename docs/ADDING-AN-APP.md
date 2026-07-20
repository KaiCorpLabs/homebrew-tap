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

## Paso 2 — copiar el release script y el workflow al repo de la app

Del repo de DiskShelf, copia a tu repo de app:

- `Scripts/release.sh` — ajusta arriba `CASK_NAME` y `APP_NAME`.
- `.github/workflows/release.yml` — ajusta el bloque `env:` (`APP_NAME`,
  `CASK_NAME`, `TAP_SLUG`).

```sh
# en release.sh
CASK_NAME=${CASK_NAME:-miapp}
APP_NAME=${APP_NAME:-MiApp}
```

Si tu app no se empaqueta con un `Scripts/package_app.sh` equivalente, adapta la
sección "Build" de `release.sh` a como generes tú el `.app`.

### Secret `TAP_TOKEN` (una vez por repo de app)

El workflow escribe en **este** repo (el tap), que es otro repo, así que necesita
un token propio (el `GITHUB_TOKEN` por defecto solo puede con el repo de la app):

1. GitHub → Settings → Developer settings → **Fine-grained tokens** → *Generate*.
2. *Resource owner* **KaiCorpLabs**, *Repository access* solo `homebrew-tap`,
   *Permissions* → **Contents: Read and write**.
3. Guárdalo como secret del repo de la app:
   ```sh
   gh secret set TAP_TOKEN --repo KaiCorpLabs/mi-repo
   ```

El mismo token sirve para todas las apps si el fine-grained lo generas con acceso
al `homebrew-tap`.

## Paso 3 — publicar

Sube la versión en el `version.env` de la app y haz push a `main`:

```sh
# version.env
MARKETING_VERSION=0.1.0
BUILD_NUMBER=1
```

El workflow hace, en orden:

1. compila universal (arm64 + x86_64) y monta el `.app`;
2. lo comprime y calcula el `sha256`;
3. sube el zip como *release* `<cask>-v<version>` de **este tap**;
4. bumpea `version` + `sha256` en `Casks/<cask>.rb`;
5. crea la etiqueta y release `v<version>` en el repo de la app.

(El mismo trabajo, a mano desde tu Mac: `Scripts/release.sh`.)

A partir de ahí:

```sh
brew update
brew install --cask miapp    # primera vez (+ "Open Anyway" en Gatekeeper)
brew upgrade --cask miapp    # siguientes versiones
```

Como las apps van firmadas ad-hoc, la primera apertura de cada versión pide
autorizar en *System Settings → Privacy & Security → "Open Anyway"* (o
`xattr -dr com.apple.quarantine /Applications/MiApp.app`). Ver el
[README](../README.md).

## Paso 4 — documentar

Añade la fila de tu app a la tabla "Apps disponibles" del [README](../README.md).

## Publicar una versión nueva de una app existente

1. Sube `MARKETING_VERSION` (y `BUILD_NUMBER`) en el `version.env` de la app.
2. Commit y push a `main` → el workflow publica la versión.

No toques `sha256` a mano: lo recalcula el proceso. Un push sin subir la versión
no republica (una guarda comprueba si la etiqueta ya existe). Todo es idempotente:
si algo falla a medias, relanza (usa `gh release ... --clobber`).

## Notas

- **Gatekeeper**: las apps van firmadas ad-hoc, no notarizadas. La primera vez que
  se abre cada versión hay que autorizarla ("Open Anyway" o `xattr -dr
  com.apple.quarantine`). `--no-quarantine` de brew no lo evita. Ver el README.
- **Universal**: se compila para Intel y Apple Silicon para que corra en
  cualquier Mac. Si tu app solo va a correr en Apple Silicon, pon
  `ARCHES=arm64` antes de `release.sh` (o en el `env:` del workflow).
- **Firmar de verdad**: si algún día sacas la app fuera del círculo de confianza,
  el salto es firmar con Developer ID + notarizar en el paso de build; el cask, el
  script y el workflow no cambian, y desaparece el paso de "Open Anyway".
