#!/bin/bash

#Copied from a github gist (I do not find the gist anymore to give props, if you find it let me know, i will update this comment) and improved

declare -a fonts=(
    JetBrainsMono
    Meslo
    ProggyClean
    RobotoMono
    SourceCodePro
)

version='2.3.3'
fonts_dir="${HOME}/.local/share/fonts"

if [[ ! -d "$fonts_dir" ]]; then
    mkdir -p "$fonts_dir"
fi

for font in "${fonts[@]}"; do
    zip_file="${font}.zip"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
    echo "Downloading $download_url"
    wget "$download_url"
    unzip -o -d "$fonts_dir" "$zip_file" "*.ttf"
    rm "$zip_file"
done

find "$fonts_dir" -name '*Windows Compatible*' -delete

fc-cache -fv