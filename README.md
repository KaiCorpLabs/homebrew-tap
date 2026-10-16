# KaiCorpLabs Homebrew Tap

Tap de [Homebrew](https://brew.sh) para instalar y mantener actualizadas las apps
de macOS de **KaiCorpLabs** desde la terminal.

El **código fuente de cada app es privado**; aquí solo viven las *recetas* (casks)
y los binarios ya compilados que se distribuyen. Las apps se firman de forma
*ad-hoc* (no llevan Developer ID ni notarización), así que la primera vez que
abres cada versión hay que autorizarla en Gatekeeper. Pensado para uso propio y
para que gente de confianza pueda probarlas.

## Instalación

```sh
brew tap kaicorplabs/tap
brew trust kaicorplabs/tap          # una vez: taps de terceros requieren confianza
brew install --cask <cask>         # el de la tabla de abajo, p. ej. arveil
```

> **`brew trust`**: desde Homebrew 6, instalar desde un tap que no es oficial
> exige confiar en él una vez. Si lo omites verás *"Refusing to load cask … from
> untrusted tap"*. Basta hacerlo una vez por tap.

**Primera apertura (una vez por versión).** Como las apps van firmadas ad-hoc y
sin notarizar, macOS las bloquea al abrirlas. Autorízalas con cualquiera de estas:

- **GUI**: intenta abrir la app → *System Settings → Privacy & Security* → botón
  **"Open Anyway"** → vuelve a abrir.
- **Terminal**: `xattr -dr com.apple.quarantine /Applications/<App>.app` y ábrela.

> Nota: `--no-quarantine` de `brew` **no** quita este paso en las versiones
> actuales de Homebrew (no elimina la cuarentena del `.app` ya instalado). La
> única forma de eliminarlo del todo es notarizar las apps.

## Actualizar

```sh
brew update            # refresca las recetas del tap
brew upgrade --cask <cask>
# o actualiza todo lo instalado por brew:
brew upgrade
```

Las actualizaciones van por número de versión del cask: cuando se publica una
versión nueva, `brew upgrade` la detecta y la instala (sin notarización). Tras
actualizar, la primera apertura de la versión nueva vuelve a pedir "Open Anyway".

## Desinstalar

```sh
brew uninstall --cask <cask>          # elimina la app
brew uninstall --zap --cask <cask>    # además borra sus datos locales, si la receta lo define
```

## Apps disponibles

| Cask | App | Descripción | macOS mín. |
|------|-----|-------------|------------|
| `arveil` | Arveil | Mensajería cifrada de extremo a extremo para tu familia, con tu propio servidor | 12 (Monterey) |
| `openward` | OpenWard | Cliente SSH de código abierto con SFTP, túneles, paneles y snippets | 13 (Ventura) |

## Añadir una app nueva al tap

Sí, es la gracia del tap: cada app nueva es **un archivo `.rb` más** aquí y un
script de release en el repo de esa app. La guía completa está en
[`docs/ADDING-AN-APP.md`](docs/ADDING-AN-APP.md). Resumen:

1. Copia [`templates/cask.rb.tmpl`](templates/cask.rb.tmpl) a `Casks/<app>.rb` y
   rellena los campos estáticos (nombre, descripción, homepage, bundle, macOS).
2. En el repo de la app: copia `Scripts/release.sh` y `.github/workflows/release.yml`
   y ajusta `CASK_NAME`/`APP_NAME`; añade el secret `TAP_TOKEN`.
3. Sube la versión en su `version.env` y haz push: el CI publica el binario como
   *release* de este tap y bumpea `version` + `sha256` del cask solo.
4. Añade la fila a la tabla de arriba.

## Cómo está montado

- **Recetas** (`Casks/*.rb`): una por app. Definen versión, `sha256`, URL de
  descarga y dónde se instala.
- **Binarios**: se publican como *assets* de las *Releases* de **este mismo
  repo**, con etiquetas por app (`miapp-v0.1.0`, `otraapp-v2.3.0`, …). Así el
  fuente sigue privado pero el binario es descargable sin autenticación.
- **Publicación**: cada repo de app tiene un workflow que, al subir su versión,
  compila, sube el binario aquí y hace `git push` del bump del cask. `brew update`
  propaga el cambio a quien lo tenga instalado. El mismo trabajo se puede hacer a
  mano con `Scripts/release.sh`.

## Arveil

[Arveil](https://arveil.kaicorplabs.com/) es de código abierto y publica sus
paquetes en sus propias [releases](https://github.com/Ulzuhan/arveil/releases);
este tap solo guarda la receta, que apunta a ellas con su SHA-256.

```sh
brew tap kaicorplabs/tap
brew trust kaicorplabs/tap
brew install --cask arveil
```

- **Actualizar:** `brew upgrade --cask arveil`. No desinstales Arveil para
  actualizarlo.
- **Tu perfil no se borra nunca desde aquí.** Arveil guarda el perfil cifrado,
  con las claves de tu identidad y tu historial, en
  `~/Library/Containers/io.github.ulzuhan.arveil`. `brew uninstall` lo deja
  intacto y la receta no tiene `zap`, así que ni `--zap` lo toca. Bórralo a
  mano solo si de verdad quieres perder esa identidad; guarda antes tu kit.
- Como las demás apps del tap, va firmada ad-hoc y sin notarizar: la primera
  apertura de cada versión pide "Open Anyway".

## OpenWard

OpenWard es un cliente SSH de código abierto para escritorio. Mientras su
repositorio sea privado, cada versión de macOS se publica también como release
de este tap (`openward-v<versión>`), y la receta apunta ahí.

```sh
brew tap kaicorplabs/tap
brew trust kaicorplabs/tap
brew install --cask openward
```

- **Actualizar:** `brew upgrade --cask openward`. Las betas también llegan
  así.
- **Tus datos:** hosts, grupos, identidades, túneles, snippets y ajustes van en
  `~/Library/Application Support/dev.openward.OpenWard`, sin contraseñas ni
  claves privadas. `brew uninstall` los conserva y `--zap` los borra. Ninguno
  de los dos toca `~/.ssh`.
- Va firmada ad hoc y sin notarizar: la primera apertura de cada versión pide
  "Open Anyway".
