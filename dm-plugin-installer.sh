#! /bin/bash
URL="$1"
PLUGIN_ROOT=/usr/lib/enigma2/python/Plugins/Extensions/
VERSION=0.0.1

echo Dreambox Github Plugin Installer v"$VERSION"

if [ ! -d "$PLUGIN_ROOT" ]; then
	echo "This does not look like a dreambox environment. Aborting."
	exit 1
fi

if [ -z "$URL" ]; then
	echo "USAGE: $0 <<GITHUB_DOWNLOAD_URL>>"
	exit 1
fi

PLUGIN_NAME=$(sed -E "s/.*github\.com\/[^/]+\/([^/]+).*\.zip/\1/" <<< "$URL")
PLUGIN_FOLDER="$PLUGIN_NAME"

if [ "$URL" = "$PLUGIN_NAME" ]; then
	echo
	echo "No proper GITHUB download url provided. Aborting."
	exit 1
fi

echo -n Check for existing plugin...
EXISTING_PLUGIN=$(ls "$PLUGIN_ROOT" | grep -i "$PLUGIN_NAME")
if [ ! -z "$EXISTING_PLUGIN" ]; then
	echo
        while true; do
		read -N1 -p "Plugin in folder $EXISTING_PLUGIN already exists. Shall we replace the existing plugin? [yN] " yn
		case $yn in
			[Yy]* ) echo; echo "Existing plugin will be moved to /tmp/$PLUGIN_FOLDER_previous_version."; rm -rf /tmp/"$PLUGIN_FOLDER"_previous_version; mv "$PLUGIN_ROOT""$EXISTING_PLUGIN" /tmp/"$PLUGIN_FOLDER"_previous_version; break;;
			* ) echo; echo "Aborting."; exit 1;;
		esac
	done
fi
echo done.

echo Installing "$PLUGIN_NAME"...

ZIP=$(mktemp /tmp/plugin-installer-"$PLUGIN_FOLDER".XXXXXX)
echo -n "    Downloading from github to file $ZIP..."
curl -sL "$URL" > "$ZIP"
echo done.

TEMPFOLDER=$(mktemp -d /tmp/plugin-installer-"$PLUGIN_FOLDER".XXXXXX)
echo -n "    Extracting files to temporary folder $TEMPFOLDER..."
unzip -qd "$TEMPFOLDER" "$ZIP"
echo done.

echo -n "    Move plugin to plugin directory..."
SUBPATH=$(ls "$TEMPFOLDER")
mv "$TEMPFOLDER"/"$SUBPATH" "$PLUGIN_ROOT""$PLUGIN_FOLDER"
echo done.

echo -n "    Cleaning up downloaded files and folders..."
rm "$ZIP"
rm -rf "$TEMPFOLDER"
echo done.

echo Installation done.

echo
echo Restart of enigma2 is required.
read -N1 -p "Restart enigma2 now? [yN] " yn
case $yn in
	[Yy]* ) echo; echo -n "Restarting enigma2..."; systemctl restart enigma2; echo done.;;
	* ) echo; echo "Remember to restart enigma2 to activate new plugin.";;
esac

