cask "diskshelf" do
  version "0.1.0"
  sha256 "24c343d6a09e0cf0512b061df7c3f8caefb89ef1c9a99225a43c2c1a382bf2c6"

  url "https://github.com/KaiCorpLabs/homebrew-tap/releases/download/diskshelf-v#{version}/DiskShelf-#{version}.zip",
      verified: "github.com/KaiCorpLabs/homebrew-tap/"
  name "DiskShelf"
  desc "Cataloga discos externos y encuentra sus archivos aunque estén desconectados"
  homepage "https://github.com/KaiCorpLabs/diskshelf"

  # Los binarios se publican como releases de este tap con etiquetas por app.
  # Las actualizaciones se propagan por `brew update` (bump de version+sha256),
  # no dependen de livecheck; esto es solo para `brew livecheck`.
  livecheck do
    url "https://github.com/KaiCorpLabs/homebrew-tap.git"
    regex(/^diskshelf[-_]v?(\d+(?:\.\d+)+)$/i)
    strategy :git
  end

  depends_on macos: :sonoma # macOS 14 o posterior

  app "DiskShelf.app"

  zap trash: [
    "~/Library/Application Support/DiskShelf",
  ]
end
