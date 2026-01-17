#!/bin/bash
rm -rf ~/.var/app/com.spotify.Client/cache/spotify/Singleton*
flatpak run com.spotify.Client
