#!/usr/bin/env bash
set -u

# Ultimate OnePlus / OxygenOS debloater
# Works by uninstalling packages for Android user 0 only:
#   pm uninstall -k --user 0 <package>
# This is reversible with:
#   cmd package install-existing --user 0 <package>

VERSION="1.0.0"
USER_ID="0"
DRY_RUN=0
YOLO=0
ASSUME_YES=0
NO_SUSPEND=0
LOG_DIR="./logs"

KEEP_PACKAGES=(
  com.android.chrome
  com.android.vending
  com.google.android.gms
  com.google.android.gsf
  com.google.android.googlequicksearchbox
  com.google.android.gm
  com.google.android.youtube
  com.google.android.apps.maps
  com.google.android.inputmethod.latin
  com.google.android.webview
)

REGULAR_BLOAT=(
  # OnePlus/OPlus/Oppo apps and services commonly safe to remove for user 0
  com.oplus.riderMode
  com.oplus.linker
  com.oplus.beaconlink
  com.redteamobile.roaming
  com.coloros.operationManual
  com.oplus.crashbox
  com.oplus.customize.coreapp
  com.coloros.colordirectservice
  com.coloros.sceneservice
  com.oppo.quicksearchbox
  com.oplus.aiwriter
  com.oplus.aimemory
  com.coloros.translate.engine
  com.coloros.translate
  com.android.hotwordenrollment.okgoogle
  com.android.hotwordenrollment.xgoogle
  com.heytap.pictorial
  com.heytap.cloud
  com.heytap.browser
  com.coloros.assistantscreen
  com.microsoft.appmanager
  com.oplus.securitykeyboard
  com.google.android.apps.wellbeing
  com.coloros.smartsidebar
  com.oplus.contentportal
  com.oplus.multiapp
  com.oplus.remotecontrol
  com.google.ar.lens
  com.google.android.projection.gearhead
  com.coloros.accessibilityassistant
  com.google.android.apps.walletnfcrel
  com.oneplus.oshare
  com.coloros.childrenspace
  com.oplus.phonemanager
  com.coloros.systemclone
  com.oplus.omoji
  com.google.android.apps.safetyhub
  com.google.android.gms.supervision
  com.oplus.ambient.livealert
  com.coloros.compass2
  com.coloros.video
  com.oplus.games
  com.coloros.floatassistant
  com.google.android.apps.photos
  com.google.android.apps.nbu.files
  com.nearme.instant.platform
  net.oneplus.weather
  com.coloros.weather.service
  com.oplus.themestore
  com.heytap.market
  com.heytap.market.overlay
  com.oplus.aiunit
  com.aiunit.aon
  com.oplus.aicall

  # Facebook/Meta preload
  com.facebook.appmanager
  com.facebook.katana
  com.facebook.services
  com.facebook.system

  # Extra obvious third-party/preload bloat
  com.netflix.mediaclient
  com.linkedin.android
)

ONEPLUS_APPS=(
  com.oneplus.account
  com.oneplus.backuprestore
  com.oneplus.brickmode
  com.oneplus.calculator
  com.oneplus.colorx
  com.oneplus.deskclock
  com.oneplus.filemanager
  com.oneplus.gallery
  com.oneplus.mall
  com.oneplus.membership
  com.oneplus.note
  com.oneplus.soundrecorder
  net.oneplus.forums
  net.oneplus.widget
  andes.oplus.documentsreader
  com.coloros.ocrscanner
  com.coloros.scenemode
  com.coloros.lockassistant
  com.coloros.activation
  com.coloros.bootreg
  com.heytap.accessory
  com.heytap.colorfulengine
  com.heytap.htms
  com.heytap.mcs
  com.heytap.mydevices
  com.oplus.apprecover
  com.oplus.callrecorder
  com.oplus.cast
  com.oplus.consumerIRApp
  com.oplus.engineercamera
  com.oplus.engineermode
  com.oplus.engineernetwork
  com.oplus.logkit
  com.oplus.melody
  com.oplus.nfcengineertest
  com.oplus.pay
  com.oplus.phonenoareainquire
  com.oplus.screenrecorder
  com.oplus.securepay
  com.oplus.upgradeguide
  com.oplus.wifibackuprestore
)

ONEPLUS_AI=(
  com.oplus.aiunit
  com.oplus.overlay.aicore
  com.oplus.android.overlay.aifunction.cicletosearch
  com.oplus.android.overlay.aifunction.common
  com.google.android.aicore
  com.oplus.deepthinker
  com.oplus.obrain
  com.oplus.smartengine
  com.oplus.metis
  com.oplus.appsense
  com.oplus.cosa
  com.oplus.pscanvas
  com.oplus.pantanal.ums
  com.oplus.tai.borderpresearch
  com.oplus.sense.netprediction
  com.oplus.sense.netscore
)

GOOGLE_OPTIONAL=(
  # Keeps Chrome, Google app/Search, Gmail, YouTube, Maps, Play Store/Services, Gboard, WebView.
  com.google.ambient.streaming
  com.google.android.accessibility.switchaccess
  com.google.android.adservices.api
  com.google.android.apps.adm
  com.google.android.apps.bard
  com.google.android.apps.chromecast.app
  com.google.android.apps.docs
  com.google.android.apps.nbu.paisa.user
  com.google.android.apps.restore
  com.google.android.apps.setupwizard.searchselector
  com.google.android.apps.subscriptions.red
  com.google.android.apps.tachyon
  com.google.android.apps.work.clouddpc
  com.google.android.apps.youtube.music
  com.google.android.as
  com.google.android.as.oss
  com.google.android.calendar
  com.google.android.contactkeys
  com.google.android.contacts
  com.google.android.devicelockcontroller
  com.google.android.federatedcompute
  com.google.android.feedback
  com.google.android.gms.location.history
  com.google.android.mosey
  com.google.android.odad
  com.google.android.ondevicepersonalization.services
  com.google.android.overlay.gmsconfig.asi
  com.google.android.overlay.gmsconfig.odad
  com.google.android.overlay.gmsconfig.personalsafety
  com.google.android.overlay.gmsconfig.searchselector
  com.google.android.partnersetup
  com.google.android.printservice.recommendation
  com.google.android.safetycore
  com.google.android.tts
  com.google.android.videos
  com.google.ar.core
  com.google.mainline.adservices
  com.google.mainline.telemetry
)

PHONE_SMS=(
  com.android.contacts
  com.google.android.apps.messaging
)

HEALTH=(
  com.fitbit.FitbitMobile
)

SETUP_SUPPORT=(
  com.google.android.setupwizard
  com.google.android.apps.setupwizard.searchselector
  com.google.android.overlay.gmsconfig.searchselector
  com.google.android.partnersetup
  com.google.android.onetimeinitializer
  com.google.android.apps.restore
  com.android.managedprovisioning
)

EXTRA_OPTIONAL=(
  com.instagram.android
  com.android.musicfx
  com.android.bookmarkprovider
  com.android.providers.partnerbookmarks
  com.android.avatarpicker
  com.android.email.partnerprovider
)

ACCESSIBILITY_OPTIONAL=(
  com.google.android.marvin.talkback
)

RESTORE_PACKAGES=()
LOG_FILE=""
RESTORE_FILE=""

usage() {
  cat <<EOF
Ultimate OnePlus / OxygenOS debloater v$VERSION

Usage:
  ./debloat.sh [options]

Options:
  --dry-run       Print actions without changing the phone.
  --yes           Skip confirmation for regular debloat. Critical prompts remain.
  --yolo          Do everything we did in the reference session: aggressive OnePlus,
                  AI, Google optional, Phone/SMS, Fitbit, Android Setup disable,
                  Airtel/SIM Toolkit hide, AMOLED/blur tweaks. No prompts.
  --no-suspend    If uninstall fails, do not try disable/suspend fallback.
  --user ID       Android user ID. Default: 0.
  --log-dir DIR   Directory for logs and restore script. Default: ./logs.
  -h, --help      Show this help.

Examples:
  ./debloat.sh
  ./debloat.sh --dry-run
  ./debloat.sh --yolo
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --yes|-y) ASSUME_YES=1 ;;
    --yolo) YOLO=1; ASSUME_YES=1 ;;
    --no-suspend) NO_SUSPEND=1 ;;
    --user) USER_ID="${2:-}"; shift ;;
    --log-dir) LOG_DIR="${2:-}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

say() { printf '%s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] %q ' "$@"; printf '\n'
  else
    "$@"
  fi
}

adb_shell() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] adb shell'; printf ' %q' "$@"; printf '\n'
  else
    adb shell "$@"
  fi
}

confirm() {
  local prompt="$1"
  if [[ "$YOLO" -eq 1 || "$ASSUME_YES" -eq 1 ]]; then
    return 0
  fi
  printf '%s [y/N]: ' "$prompt"
  read -r ans
  case "$ans" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

critical() {
  local prompt="$1"
  if [[ "$YOLO" -eq 1 ]]; then
    say "[yolo] $prompt -> yes"
    return 0
  fi
  printf '\nCRITICAL: %s [y/N]: ' "$prompt"
  read -r ans
  case "$ans" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

require_adb() {
  command -v adb >/dev/null 2>&1 || { echo "adb not found. Install Android platform-tools." >&2; exit 1; }
  if [[ "$DRY_RUN" -eq 1 ]]; then
    say "Dry run: not waiting for a device."
    return 0
  fi
  say "Waiting for device..."
  adb wait-for-device
  local devices
  devices=$(adb devices | awk 'NR>1 && $2=="device" {print $1}')
  if [[ -z "$devices" ]]; then
    echo "No authorized ADB device found." >&2
    exit 1
  fi
}

setup_files() {
  mkdir -p "$LOG_DIR"
  local ts
  ts=$(date +%Y%m%d_%H%M%S)
  LOG_FILE="$LOG_DIR/debloat_$ts.log"
  RESTORE_FILE="$LOG_DIR/restore_$ts.sh"
  cat > "$RESTORE_FILE" <<EOF
#!/usr/bin/env bash
set -u
USER_ID="${USER_ID}"
packages=(
EOF
  chmod +x "$RESTORE_FILE"
}

finish_restore_file() {
  {
    printf ')\n'
    cat <<'EOF'
for p in "${packages[@]}"; do
  [[ -z "$p" ]] && continue
  echo "Restoring $p"
  adb shell cmd package install-existing --user "$USER_ID" "$p" || true
  adb shell pm enable --user "$USER_ID" "$p" || true
  adb shell pm unsuspend --user "$USER_ID" "$p" || true
done

# Restore Android Setup if it was disabled.
adb shell cmd package install-existing --user "$USER_ID" com.google.android.setupwizard || true
adb shell pm enable --user "$USER_ID" com.google.android.setupwizard || true
adb shell pm unsuspend --user "$USER_ID" com.google.android.setupwizard || true

# Restore Airtel/SIM Toolkit if it was hidden.
adb shell cmd package install-existing --user "$USER_ID" com.android.stk || true
adb shell pm enable --user "$USER_ID" com.android.stk || true

# Re-enable Live Caption volume button if desired:
# adb shell settings put secure odi_captions_volume_ui_enabled 1
EOF
  } >> "$RESTORE_FILE"
}

remember_restore() {
  local p="$1"
  RESTORE_PACKAGES+=("$p")
  printf '%s\n' "$p" >> "$RESTORE_FILE"
}

is_installed_for_user() {
  local p="$1"
  adb shell cmd package list packages --user "$USER_ID" "$p" 2>/dev/null | grep -q "package:$p"
}

remove_package() {
  local p="$1"
  [[ -z "$p" ]] && return 0
  say "Removing $p"
  remember_restore "$p"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    say "[dry-run] adb shell pm uninstall -k --user $USER_ID $p"
    return 0
  fi

  local out
  out=$(adb shell pm uninstall -k --user "$USER_ID" "$p" 2>&1 | tr -d '\r' || true)
  printf '%s : %s\n' "$p" "$out" | tee -a "$LOG_FILE"

  if [[ "$out" != *"Success"* && "$NO_SUSPEND" -ne 1 ]]; then
    if is_installed_for_user "$p"; then
      say "  uninstall resisted; trying disable-user + suspend"
      adb shell pm disable-user --user "$USER_ID" "$p" 2>&1 | tr -d '\r' | tee -a "$LOG_FILE" || true
      adb shell pm suspend --user "$USER_ID" "$p" 2>&1 | tr -d '\r' | tee -a "$LOG_FILE" || true
    fi
  fi
}

remove_group() {
  local title="$1"; shift
  say ""
  say "== $title =="
  local p
  for p in "$@"; do
    remove_package "$p"
  done
}

restore_setup_support() {
  say ""
  say "== Restoring Setup Wizard support packages before final setup decision =="
  local p
  for p in "${SETUP_SUPPORT[@]}"; do
    remember_restore "$p"
    adb_shell cmd package install-existing --user "$USER_ID" "$p" || true
    adb_shell pm enable --user "$USER_ID" "$p" || true
    adb_shell pm unsuspend --user "$USER_ID" "$p" || true
  done
  adb_shell settings put secure user_setup_complete 1 || true
  adb_shell settings put global device_provisioned 1 || true
  adb_shell settings put secure setup_wizard_has_run 1 || true
  adb_shell settings put secure setup_wizard_promo_complete 1 || true
}

disable_setup_wizard() {
  say ""
  say "== Disabling Android Setup / Setup Wizard =="
  restore_setup_support
  adb_shell am force-stop com.google.android.setupwizard || true
  adb_shell pm disable-user --user "$USER_ID" com.google.android.setupwizard || true
}

hide_sim_toolkit() {
  say ""
  say "== Hiding Airtel Services / SIM Toolkit =="
  remember_restore com.android.stk
  adb_shell pm disable-user --user "$USER_ID" com.android.stk || true
}

hide_live_caption_button() {
  say ""
  say "== Hiding Live Caption volume button =="
  adb_shell settings put secure odi_captions_volume_ui_enabled 0 || true
  adb_shell settings put secure odi_captions_enabled 0 || true
  adb_shell settings put secure accessibility_captioning_enabled 0 || true
}

apply_dark_blur_tweaks() {
  say ""
  say "== Applying darkest safe non-root SystemUI tweaks =="
  adb_shell cmd uimode night yes || true
  adb_shell settings put secure ui_night_mode 2 || true
  adb_shell settings put global dark_mode_state 1 || true
  adb_shell settings put secure oplus_customize_settings_dark_wallpaper 1 || true
  adb_shell settings put system DarkMode_BackgroundMaxL 0.0 || true
  adb_shell settings put system DarkMode_DialogBgMaxL 0.0 || true
  adb_shell settings put system system_material_blur_enable 0 || true
  adb_shell settings put system animationBlurrySwitch 0 || true
  adb_shell settings put global disable_window_blurs 1 || true
  adb_shell settings put global blurs_disabled 1 || true
  if [[ "$DRY_RUN" -eq 1 ]]; then
    say '[dry-run] adb shell settings put secure theme_customization_overlay_packages <monochrome black JSON>'
  else
    adb shell 'settings put secure theme_customization_overlay_packages "{\"android.theme.customization.color_source\":\"preset\",\"android.theme.customization.theme_style\":\"MONOCHROMATIC\",\"android.theme.customization.system_palette\":\"ff000000\",\"android.theme.customization.accent_color\":\"ff5f6368\"}"' || true
  fi
}

print_device() {
  say ""
  if [[ "$DRY_RUN" -eq 1 ]]; then
    say "Connected device: skipped in dry run"
    return 0
  fi
  say "Connected device:"
  adb shell getprop ro.product.model | tr -d '\r' | sed 's/^/  Model: /'
  adb shell getprop ro.build.version.release | tr -d '\r' | sed 's/^/  Android: /'
  adb shell getprop ro.build.version.oplusrom 2>/dev/null | tr -d '\r' | sed 's/^/  OOS: /'
}

main() {
  require_adb
  setup_files
  exec > >(tee -a "$LOG_FILE") 2>&1

  say "Ultimate OnePlus / OxygenOS debloater v$VERSION"
  print_device
  say ""
  warn "This modifies Android user $USER_ID only, but can remove important app UIs. Read README first."
  say "Log: $LOG_FILE"
  say "Restore script: $RESTORE_FILE"

  if ! confirm "Run regular debloat now?"; then
    say "Aborted."
    finish_restore_file
    exit 0
  fi

  hide_live_caption_button
  remove_group "Regular bloat" "${REGULAR_BLOAT[@]}"
  remove_group "OnePlus/OPlus AI and prediction services" "${ONEPLUS_AI[@]}"

  if [[ "$YOLO" -eq 1 ]] || critical "Remove OnePlus stock apps too? Includes OnePlus Clock, Gallery, File Manager, Recorder, Account, Clone Phone/Backup, Zen Space."; then
    remove_group "OnePlus stock apps" "${ONEPLUS_APPS[@]}"
  fi

  if [[ "$YOLO" -eq 1 ]] || critical "Remove optional Google apps/services? Keeps Chrome, Google app, Gmail, YouTube, Maps, Play Store/Services, Gboard, WebView."; then
    remove_group "Optional Google apps/services" "${GOOGLE_OPTIONAL[@]}"
  fi

  if [[ "$YOLO" -eq 1 ]] || critical "Remove default Phone and Messages UIs? Only say yes if you installed replacements."; then
    remove_group "Phone/SMS apps" "${PHONE_SMS[@]}"
  fi

  if [[ "$YOLO" -eq 1 ]] || critical "Remove Fitbit app? Health Connect itself is kept."; then
    remove_group "Health extras" "${HEALTH[@]}"
  fi

  if [[ "$YOLO" -eq 1 ]] || critical "Disable Android Setup / Setup Wizard after marking setup complete?"; then
    disable_setup_wizard
  else
    restore_setup_support
  fi

  if [[ "$YOLO" -eq 1 ]] || critical "Hide Airtel Services / SIM Toolkit icon? This disables the SIM Toolkit app, not calls/data/SMS."; then
    hide_sim_toolkit
  fi

  if [[ "$YOLO" -eq 1 ]] || critical "Remove accessibility extras like TalkBack/Switch Access? Only yes if you do not rely on accessibility services."; then
    remove_group "Accessibility extras" "${ACCESSIBILITY_OPTIONAL[@]}"
  fi

  if [[ "$YOLO" -eq 1 ]] || critical "Remove extra optional apps/providers? Includes Instagram if installed, MusicFX, bookmarks, avatar picker."; then
    remove_group "Extra optional apps" "${EXTRA_OPTIONAL[@]}"
  fi

  if [[ "$YOLO" -eq 1 ]] || critical "Apply AMOLED-ish dark mode and disable OxygenOS blur flags? Non-root best effort; not guaranteed to make QS pure black."; then
    apply_dark_blur_tweaks
  fi

  finish_restore_file
  say ""
  say "Done. Reboot recommended: adb reboot"
  say "Log: $LOG_FILE"
  say "Restore: $RESTORE_FILE"
}

main "$@"
