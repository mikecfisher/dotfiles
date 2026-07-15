groof)
    name="Groof"
    type="zip"
    appName="Groof.app"
    expectedTeamID="2B7KR8BSYR"
    appNewVersion="$(curl -fsSL https://update.rekord.cloud/releases/groof/latest/appcast-aarch64.rss | sed -n 's:.*<sparkle:shortVersionString>\([^<]*\)</sparkle:shortVersionString>.*:\1:p' | head -n 1)"
    downloadURL="$(curl -fsSL https://update.rekord.cloud/releases/groof/latest/appcast-aarch64.rss | sed -n 's:.*<enclosure url="\([^"]*\)".*:\1:p' | head -n 1)"
    ;;
