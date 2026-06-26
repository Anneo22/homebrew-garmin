class Garminbridge < Formula
  desc "Reliable Garmin-to-Mac bridge: voice notes and activities, automatically"
  homepage "https://github.com/Anneo22/garminbridge"
  url "https://github.com/Anneo22/garminbridge/archive/refs/tags/v0.2.2.tar.gz"
  sha256 "789b01f1651d9fee456f5237422deea7ff079c2194a6efd5dc5515ae3546dd5e"
  license "MIT"

  depends_on "gphoto2"
  depends_on :macos
  depends_on "terminal-notifier"

  def install
    system "swiftc", "-O", "src/garmin-usb-watcher.swift", "-o", "bin/garmin-usb-watcher"

    (buildpath/"GarminBridge.app/Contents/MacOS").mkpath
    system "swiftc", "-O", "src/garmin-voice-menubar.swift",
                     "-o", "GarminBridge.app/Contents/MacOS/garmin-voice-menubar"
    (buildpath/"GarminBridge.app/Contents/Info.plist").write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0"><dict>
        <key>CFBundleName</key><string>GarminBridge</string>
        <key>CFBundleIdentifier</key><string>com.garminvoice.menubar</string>
        <key>CFBundleExecutable</key><string>garmin-voice-menubar</string>
        <key>CFBundlePackageType</key><string>APPL</string>
        <key>CFBundleShortVersionString</key><string>1.0</string>
        <key>LSUIElement</key><true/>
      </dict></plist>
    XML

    libexec.install Dir["*"]
    (bin/"garminbridge").write_env_script "#{libexec}/bin/garmin-voice", {}
    (bin/"garmin-voice").write_env_script "#{libexec}/bin/garmin-voice", {} # legacy alias
    (bin/"garminbridge-setup").write <<~SH
      #!/bin/bash
      exec "#{libexec}/install.sh" "$@"
    SH
  end

  def caveats
    <<~EOS
      One-time setup (installs the on-connect agent and menu-bar app):
        garminbridge-setup

      Daily control:
        garminbridge status | pause | resume | sync | activities
    EOS
  end

  test do
    assert_match "pause", shell_output("#{bin}/garminbridge help")
  end
end
