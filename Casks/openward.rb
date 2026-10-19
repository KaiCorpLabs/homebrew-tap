# frozen_string_literal: true

cask "openward" do
  version "0.3.1-beta.5"
  sha256 "6c7ab4f58891b3bb8fbeff5981c6bfdee11ac1b09aad208f62a8828313c76202"

  # While the OpenWard repository is private, Homebrew cannot download its
  # releases, so each package is also a release of this tap
  # (openward-v<version>). When it goes public, point this at its own
  # releases, as Arveil does.
  url "https://github.com/KaiCorpLabs/homebrew-tap/releases/download/openward-v#{version}/OpenWard-#{version}-macos.dmg"
  name "OpenWard"
  desc "Cliente SSH de código abierto con SFTP, túneles, paneles y snippets"
  homepage "https://github.com/KaiCorpLabs/homebrew-tap#openward"

  # Each OpenWard release bumps version and sha256 here
  # (app/tool/release-tap.sh in its repository).
  livecheck do
    skip "Updated with each OpenWard release"
  end

  depends_on macos: :ventura # macOS 13

  app "OpenWard.app"

  # Hosts, groups, identities, tunnels and snippets, and the settings.
  # Nothing here touches ~/.ssh.
  zap trash: [
    "~/Library/Application Support/dev.openward.OpenWard",
    "~/Library/Caches/dev.openward.OpenWard",
    "~/Library/Preferences/dev.openward.OpenWard.plist",
    "~/Library/Saved Application State/dev.openward.OpenWard.savedState",
  ]

  caveats <<~EOS
    OpenWard va firmada ad hoc, sin Developer ID ni notarización. La primera
    vez que abres cada versión, macOS la bloquea: ábrela y luego ve a
    Ajustes del Sistema → Privacidad y seguridad → «Abrir igualmente».

    Actualiza con `brew upgrade --cask openward`. Tus hosts y ajustes siguen en
      ~/Library/Application Support/dev.openward.OpenWard
    `brew uninstall` los conserva; `--zap` los borra. Ninguno de los dos toca
    ~/.ssh.
  EOS
end
