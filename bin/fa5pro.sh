#!/bin/sh

silent=false
prompt=""
local=false

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/.."

usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }

while getopts ":sp:l:" arg; do
    case ${arg} in
        s) # Whether to fail silently on font issues (for CI).
            silent=true
            ;;
        p) # Custom prompt to show to the user.
            prompt=" (${OPTARG})"
            ;;
        l)
            local=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ $(npm config get @fortawesome:registry) == "undefined" ] && [ $silent == false ]
then
  echo >&2 "Fonts not set up! Please enter your FA5 Pro Key"
  read -p "Key${prompt}: " fa5_key
  if [ -z ${fa5_key} ]
  then
    echo "No key set. Skipping."
    exit 0
  fi
  npm config set "@fortawesome:registry" https://npm.fontawesome.com/
  npm config set "//npm.fontawesome.com/:_authToken" $fa5_key
fi

download() {
  echo >&2 "Found @fortawesome npm configuration. Installing fonts"
  echo >&2 "Creating temporary folder"
  TEMP_DIR=$(mktemp -d -t rnvi)
  echo >&2 "Created folder $TEMP_DIR"
  pushd ${TEMP_DIR}

  echo >&2 "Downloading Font Awesome 5 Pro"

  ARCHIVE=$(npm pack @fortawesome/fontawesome-pro --silent) || { echo >&2 "Unable to download fonts. Make sure your @fortawesome scope is configured correctly"; exit 0; }
  tar -xzf ${ARCHIVE}
  mv package pro

  popd

  echo >&2 "Copying font files"

  cp ${TEMP_DIR}/pro/webfonts/fa-brands-400.ttf ${DIR}/build/vendor/react-native-vector-icons/Fonts/FontAwesome5_Pro_Brands.ttf &&
  cp ${TEMP_DIR}/pro/webfonts/fa-light-300.ttf ${DIR}/build/vendor/react-native-vector-icons/Fonts/FontAwesome5_Pro_Light.ttf &&
  cp ${TEMP_DIR}/pro/webfonts/fa-regular-400.ttf ${DIR}/build/vendor/react-native-vector-icons/Fonts/FontAwesome5_Pro_Regular.ttf &&
  cp ${TEMP_DIR}/pro/webfonts/fa-solid-900.ttf ${DIR}/build/vendor/react-native-vector-icons/Fonts/FontAwesome5_Pro_Solid.ttf ||
  return 1
}

get_local() {
  cp ${1}/webfonts/fa-brands-400.ttf ${DIR}/build/vendor/react-native-vector-icons/Fonts/FontAwesome5_Pro_Brands.ttf &&
  cp ${1}/webfonts/fa-light-300.ttf ${DIR}/build/vendor/react-native-vector-icons/Fonts/FontAwesome5_Pro_Light.ttf &&
  cp ${1}/webfonts/fa-regular-400.ttf ${DIR}/build/vendor/react-native-vector-icons/Fonts/FontAwesome5_Pro_Regular.ttf &&
  cp ${1}/webfonts/fa-solid-900.ttf ${DIR}/build/vendor/react-native-vector-icons/Fonts/FontAwesome5_Pro_Solid.ttf
}

if [ $local == false ]
then
  download
else
  get_local $local
fi

if [ $? -ne 0 ];
then
  echo >&2 "That didn't work. Check for errors above."
  exit 1
else
  echo >&1 "Done!"
fi


