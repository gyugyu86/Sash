# Homebrew cask template for Sash.
#
# This is the source-of-truth template. At release time, copy it into the tap
# repo (e.g. gyugyu86/homebrew-tap → Casks/sash.rb) so users can run:
#   brew install --cask gyugyu86/tap/sash
#
# Before publishing, fill in:
#   - version: the released version (must match the git tag, e.g. 1.0.0)
#   - sha256:  shasum -a 256 Sash-<version>.zip
#   - url:     the GitHub Release asset URL (auto-derived from version below)
cask "sash" do
  version "1.0"
  sha256 "219c496d343b6573d89290c28da3340f8587e5ba216cec6b5a48f393ca50fdab"

  url "https://github.com/gyugyu86/Sash/releases/download/v#{version}/Sash-#{version}.zip"
  name "Sash"
  desc "Keyboard-first window manager"
  homepage "https://github.com/gyugyu86/Sash"

  depends_on macos: ">= :sonoma"

  app "Sash.app"

  zap trash: [
    "~/Library/Preferences/io.github.gyugyu86.Sash.plist",
  ]
end
