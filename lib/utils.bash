#!/usr/bin/env bash

set -euo pipefail

get_arch() {
	local arch
	case "$(uname -m)" in
	x86_64 | amd64) arch="x86_64" ;;
	aarch64 | arm64) arch="aarch64" ;;
	*) fail "Arch '$(uname -m)' not supported!" ;;
	esac

	echo -n $arch
}

get_platform() {
	local platform
	case "$(uname | tr '[:upper:]' '[:lower:]')" in
	darwin) platform="apple-darwin" ;;
	linux) platform="pc-linux" ;;
	windows) platform="pc-win32" ;;
	*) fail "Platform '$(uname)' not supported!" ;;
	esac

	echo -n $platform
}

case "$(get_arch)-$(get_platform)" in
aarch64-pc-linux | aarch64-apple-darwin) GH_REPO="https://github.com/VirtusLab/coursier-m1" ;;
*) GH_REPO="https://github.com/coursier/coursier" ;;
esac

TOOL_NAME="coursier"
TOOL_TEST="coursier --help"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

list_github_tags() {
	list_all_github_tags_coursier_m1() {
		git ls-remote --tags --refs "https://github.com/VirtusLab/coursier-m1"
	}

	list_all_github_tags_coursier() {
		git ls-remote --tags --refs "https://github.com/coursier/coursier"
	}

	list_github_tags_aarch64_1() {
		SHA_2_1_16="b96b68d692405f2abf1c836d63966d3f26009eb8"
		list_all_github_tags_coursier_m1 | awk -v sha="$SHA_2_1_16" '
			$1 == sha {found=1}
			!found
		'
	}

	list_github_tags_aarch64_2() {
		SHA_2_1_16="2a16e40d1c14095f3d5831beb312ff6818482458"
		list_all_github_tags_coursier | awk -v sha="$SHA_2_1_16" '
			$1 == sha {found=1}
			found
		'
	}

	case "$(get_arch)-$(get_platform)" in
  aarch64-pc-linux | aarch64-apple-darwin)
  	list_github_tags_aarch64_1 |
			grep -o 'refs/tags/.*' | cut -d/ -f3- |
			sed 's/^v//'
  	list_github_tags_aarch64_2 |
			grep -o 'refs/tags/.*' | cut -d/ -f3- |
			sed 's/^v//'
  	;;
  *)
		list_all_github_tags_coursier |
			grep -o 'refs/tags/.*' | cut -d/ -f3- |
			sed 's/^v//'
  	;;
  esac
}

sort_versions() {
	grep -E '^[0-9]+' |
		sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n |
		awk '{print $2}'
}

list_all_versions() {
	# Change this function if coursier has other means of determining installable versions.
	list_github_tags
}

download_release() {
	get_repo() {
		case "$(get_arch)-$(get_platform)" in
      aarch64-pc-linux | aarch64-apple-darwin)
      	major=$(echo "$1" | cut -d '.' -f 1)
      	minor=$(echo "$1" | cut -d '.' -f 2)
      	patch=$(echo "$1" | cut -d '.' -f 3 | cut -d '-' -f 1)
      	if [ "$major" -ge 2 ] && [ "$minor" -ge 1 ] && [ "$patch" -ge 16 ]; then
					echo "https://github.com/coursier/coursier"
				else
					echo "https://github.com/VirtusLab/coursier-m1"
				fi
				;;
      *)
      	echo "https://github.com/coursier/coursier"
      	;;
      esac
	}

	local version filename url
	version="$1"
	filename="$2"

	url="$(get_repo "$version")/releases/download/v${version}/cs-$(get_arch)-$(get_platform)"

	echo "* Downloading $TOOL_NAME release $version..."
	if [ "$(get_platform)" == "pc-win32" ]; then
		url="${url}.zip"
		curl -fLo "${filename}" "${url}" || fail "Could not download ${url}"
		tar -xf "${filename}" || fail "Could not unzip ${filename}"
	else
		url="${url}.gz"
		curl "${curl_opts[@]}" "${url}" | gzip -d >"${filename}" || fail "Could not download ${url}"
	fi
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="$3"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path/bin"
		cp -r "$ASDF_DOWNLOAD_PATH/$TOOL_NAME" "$install_path/bin/$TOOL_NAME"

		# TODO: Asert coursier executable exists.
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
