cask "diskshelf" do
  version "0.2.0"
  sha256 "119a8b2804a27cf83836b9152dda024a861758e087f16c7e658b5f086fb3355f"

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
