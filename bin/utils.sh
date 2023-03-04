source "$(dirname -- "$0")/constants.sh"

download () {
  local -r download_url="$1"
  local -r download_path="$2"

  echo "Downloading ${toolname} version ${ASDF_INSTALL_VERSION} from ${download_url}"
  if ! curl -fsL "${download_url}" -o "${download_path}"; then
    echo "Error: ${toolname} version ${ASDF_INSTALL_VERSION} not found" >&2
    exit 1
  fi
}

get_download_url () {
  local -r repository="$1"
  local -r version="$2"
  local -r arch="$(get_arch)"
  printf "https://github.com/%s/releases/download/%s/%s-%s-%s.zip\n" \
    "$repository" "$version" "$toolname" "$arch" "${version/cli-v}"
}

get_arch () {
  uname | tr '[:upper:]' '[:lower:]' | sed 's/darwin/macos/g'
}
