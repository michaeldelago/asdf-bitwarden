source "$(dirname -- "$0")/constants.bash"

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
  local version="$1"

  local -r repository="$(get_repository "$version")"
  [[ "$version" == "latest" ]] && \
    versions=("$(get_versions "$repository")") && \
    version="$(get_latest_version "${versions[@]}")"

  local -r arch="$(get_arch)"
  printf "https://github.com/%s/releases/download/%s/%s-%s-%s.zip\n" \
    "$repository" "$version" "$toolname" "$arch" "${version/cli-v}"
}

get_repository () {
  case "$1" in 
    v1.*   )  echo "$old_repository" ;;
    cli-v* )  echo "$repository" ;;
    latest )  echo "$repository" ;;
    *      )  echo "can't map version to repository" && return 1
  esac
}

get_arch () {
  uname | tr '[:upper:]' '[:lower:]' | sed 's/darwin/macos/g'
}

get_versions() {
  local repo="$1"

  curl -s "${oauth_header[@]}" "https://api.github.com/repos/$repo/releases" | \
    grep "tag_name" | \
    cut -f 4 -d \" | \
    grep -E "^(cli-)?v" | \
    while read -r version; do
      echo "${version}"
    done | \
    tac
}

get_latest_version () {
  tail -n1 <<< "$1"
}