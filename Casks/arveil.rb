cask "arveil" do
  version "0.1.0-beta.2,20"
  sha256 "7b5aa9a8a748573fee009d70724f5656b4e183f6e7b957a08e88229cd16d8ea7"

  # Arveil publishes its packages in its own releases; the tap keeps only this
  # recipe. The tag carries the public version and the file the build number.
  url "https://github.com/Ulzuhan/arveil/releases/download/clients-v#{version.csv.first}/arveil-#{version.csv.first.split("-").first}-#{version.csv.second}-macos-arm64.zip"
  name "Arveil"
  desc "Mensajería cifrada de extremo a extremo para tu familia, con tu propio servidor"
  homepage "https://arveil.kaicorplabs.com/"

  # Each Arveil client release bumps version and sha256 here.
  livecheck do
    skip "Updated with each clients-v* release of Arveil"
  end

  depends_on arch: :arm64
  depends_on macos: :monterey # macOS 12

  app "arveil.app"

  # No zap: Arveil keeps the encrypted profile, with the identity's keys and
  # history, in its sandbox container. Removing it would lose the identity.
  caveats <<~EOS
    Arveil is signed ad hoc, without an Apple Developer ID or notarization.
    The first time you open each version, macOS blocks it: open it, then use
    System Settings → Privacy & Security → "Open Anyway".

    Update with `brew upgrade --cask arveil`. Never uninstall Arveil to update
    it: uninstalling keeps your profile in
      ~/Library/Containers/io.github.ulzuhan.arveil
    and this cask never deletes it, not even with --zap, because it holds your
    identity. Delete it by hand only if you really mean to lose it.
  EOS
end
