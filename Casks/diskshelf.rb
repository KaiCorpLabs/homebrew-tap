cask "diskshelf" do
  version "0.4.0"
  sha256 "14dac704f94203db6903b53fb5097361f657e6083046a619ab97e76d17c401e1"

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
