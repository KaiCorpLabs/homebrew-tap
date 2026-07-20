# KaiCorpLabs Homebrew Tap

Tap de [Homebrew](https://brew.sh) para instalar y mantener actualizadas las apps
de macOS de **KaiCorpLabs** desde la terminal.

El **código fuente de cada app es privado**; aquí solo viven las *recetas* (casks)
y los binarios ya compilados que se distribuyen. Las apps se firman de forma
*ad-hoc* (no llevan Developer ID ni notarización), así que se instalan con
`--no-quarantine` para que macOS no las bloquee. Pensado para uso propio y para
que gente de confianza pueda probarlas.

## Instalación

```sh
brew tap kaicorplabs/tap
brew trust kaicorplabs/tap          # taps de terceros requieren confianza explícita
brew install --cask --no-quarantine diskshelf
```

> **`brew trust`**: desde Homebrew 6, instalar desde un tap que no es oficial
> exige confiar en él una vez. Si lo omites verás *"Refusing to load cask … from
> untrusted tap"*. Basta hacerlo una vez por tap.

Para no tener que escribir `--no-quarantine` en cada instalación, añádelo una vez
a tu shell:

```sh
echo 'export HOMEBREW_CASK_OPTS="--no-quarantine"' >> ~/.zshrc
exec zsh
# a partir de aquí basta con:
brew install --cask diskshelf
```

> **¿Por qué `--no-quarantine`?** Al descargar una app, macOS le pone el atributo
> `com.apple.quarantine` y Gatekeeper bloquea las apps sin notarizar. Instalar sin
> cuarentena evita ese bloqueo sin tener que desactivar Gatekeeper en todo el
> sistema (`spctl --master-disable`). Las apps van firmadas ad-hoc, que es el
> mínimo que macOS exige para ejecutar en Apple Silicon.

## Actualizar

```sh
brew update            # refresca las recetas del tap
brew upgrade --cask diskshelf
# o actualiza todo lo instalado por brew:
brew upgrade
```

Las actualizaciones van por número de versión del cask: cuando se publica una
versión nueva, `brew upgrade` la detecta y la instala. No hace falta notarización
para que esto funcione.

## Desinstalar

```sh
brew uninstall --cask diskshelf          # elimina la app
brew uninstall --zap --cask diskshelf    # además borra sus datos locales
```

## Apps disponibles

| Cask | App | Descripción | macOS mín. |
|------|-----|-------------|------------|
| `diskshelf` | DiskShelf | Cataloga discos externos y encuentra sus archivos aunque estén desconectados | 14 (Sonoma) |

## Añadir una app nueva al tap

Sí, es la gracia del tap: cada app nueva es **un archivo `.rb` más** aquí y un
script de release en el repo de esa app. La guía completa está en
[`docs/ADDING-AN-APP.md`](docs/ADDING-AN-APP.md). Resumen:

1. Copia [`templates/cask.rb.tmpl`](templates/cask.rb.tmpl) a `Casks/<app>.rb` y
   rellena los campos estáticos (nombre, descripción, homepage, bundle, macOS).
2. Copia `Scripts/release.sh` al repo de la app y ajusta `CASK_NAME`/`APP_NAME`.
3. Ejecuta `Scripts/release.sh` en el repo de la app: compila universal, empaqueta,
   sube el binario como *release* de este tap y actualiza `version` + `sha256` del
   cask automáticamente.
4. Añade la fila a la tabla de arriba.

## Cómo está montado

- **Recetas** (`Casks/*.rb`): una por app. Definen versión, `sha256`, URL de
  descarga y dónde se instala.
- **Binarios**: se publican como *assets* de las *Releases* de **este mismo
  repo**, con etiquetas por app (`diskshelf-v0.1.0`, `otraapp-v2.3.0`, …). Así el
  fuente sigue privado pero el binario es descargable sin autenticación.
- **Actualización**: `Scripts/release.sh` (en el repo de cada app) hace bump del
  cask y `git push` aquí; `brew update` propaga el cambio a quien lo tenga
  instalado.
