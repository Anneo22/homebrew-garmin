class GarminVoiceExport < Formula
  desc "Import Garmin watch voice notes to your Mac, automatically"
  homepage "https://github.com/Anneo22/garmin-voice-export"
  url "https://github.com/Anneo22/garmin-voice-export/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "2b06375ef1101420c263dc7e893292375cf239641b3b257cc40bc0e4edd3cb64"
  license "MIT"

  depends_on "gphoto2"
  depends_on "terminal-notifier"
  depends_on :macos

  def install
    system "swiftc", "-O", "src/garmin-usb-watcher.swift", "-o", "bin/garmin-usb-watcher"

    (buildpath/"GarminVoiceMemos.app/Contents/MacOS").mkpath
    system "swiftc", "-O", "src/garmin-voice-menubar.swift",
                     "-o", "GarminVoiceMemos.app/Contents/MacOS/garmin-voice-menubar"
    (buildpath/"GarminVoiceMemos.app/Contents/Info.plist").write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0"><dict>
        <key>CFBundleName</key><string>Garmin Voice Memos</string>
        <key>CFBundleIdentifier</key><string>com.garminvoice.menubar</string>
        <key>CFBundleExecutable</key><string>garmin-voice-menubar</string>
        <key>CFBundlePackageType</key><string>APPL</string>
        <key>CFBundleShortVersionString</key><string>1.0</string>
        <key>LSUIElement</key><true/>
      </dict></plist>
    XML

    libexec.install Dir["*"]
    (bin/"garmin-voice").write_env_script "#{libexec}/bin/garmin-voice", {}
    (bin/"garmin-voice-setup").write <<~SH
      #!/bin/bash
      exec "#{libexec}/install.sh" "$@"
    SH
  end

  def caveats
    <<~EOS
      One-time setup (installs the on-connect agent and menu-bar app):
        garmin-voice-setup

      Daily control:
        garmin-voice status | pause | resume | sync
    EOS
  end

  test do
    assert_match "pause", shell_output("#{bin}/garmin-voice help")
  end
end
