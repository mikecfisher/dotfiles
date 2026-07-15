willowvoice)
    name="Willow Voice"
    type="dmg"
    appName="Willow Voice.app"
    expectedTeamID="B9LTMN6KAW"
    appNewVersion="$(curl -fsSL https://liulawrence45.github.io/stt-sparkle-update/appcast.xml | sed -n 's:.*<sparkle:shortVersionString>\([^<]*\)</sparkle:shortVersionString>.*:\1:p' | head -n 1)"
    downloadURL="$(curl -fsSL https://liulawrence45.github.io/stt-sparkle-update/appcast.xml | sed -n 's:.*<enclosure url="\([^"]*\)".*:\1:p' | head -n 1)"
    ;;
