cask "diskshelf" do
  version "0.3.0"
  sha256 "242963ba6fb8d3112bf8d3666d04e68650efa22988bd7bdde2b33c12c32fe7fb"

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
