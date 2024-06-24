# vim: set ft=make :

alias configure-waydroid := setup-waydroid

# Launch Waydroid configuration helper
setup-waydroid ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    IMAGE_NAME=$(jq -r '."image-name"' < $IMAGE_INFO)
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-waydroid <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'init' to select Initialize Waydroid"
      echo "  Use 'play' to select Play Store Certification"
      echo "  Use 'reset' to select Reset Waydroid"
      echo "  Use 'fix' to run the config fixer manually"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Waydroid Setup${normal}"
      OPTION=$(Choose "Initialize Waydroid" "Play Store Certification" "Reset Waydroid (also removes waydroid-related files from user folder)" "Fix Config")
    fi
    if [[ "${OPTION,,}" =~ ^init ]]; then
      sudo systemctl enable --now waydroid-container
      sudo waydroid init -s GAPPS -c 'https://ota.waydro.id/system' -v 'https://ota.waydro.id/vendor' -f
    elif [[ "${OPTION,,}" =~ ^play ]]; then
      echo "Grabbing Play Store certification ID"
      echo "Place the following numerical string into https://www.google.com/android/uncertified and then wait before restarting Waydroid"
      sudo waydroid shell env ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"
    elif [[ "${OPTION,,}" =~ ^reset ]]; then
      echo "Resetting Waydroid"
      sudo systemctl disable --now waydroid-container
      bash -c 'sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid'
      echo "Waydroid has been reset"
    elif [[ "${OPTION,,}" =~ ^fix ]]; then
      echo "Fixing Waydroid config"
      sudo /usr/libexec/waydroid-config-fix
    fi
