{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, alsa-lib
, dbus
, fontconfig
, freetype
, libglvnd
, libappindicator-gtk3
, wayland
, libxkbcommon
, libX11
, libXext
, libXi
, libXrender
, libxtst
, zlib
}:

# AB Download Manager gak ada di nixpkgs, jadi di-package manual dari rilis binary
# resminya (jpackage app-image, udah bawa JRE sendiri di lib/runtime).
# Referensi struktur & runtime deps: AUR package "ab-download-manager-bin"
# https://aur.archlinux.org/packages/ab-download-manager-bin
stdenv.mkDerivation (finalAttrs: {
  pname = "ab-download-manager";
  version = "1.10.4";

  src = fetchurl {
    url = "https://github.com/amir1376/ab-download-manager/releases/download/v${finalAttrs.version}/ABDownloadManager_${finalAttrs.version}_linux_x64.tar.gz";
    hash = "sha256-X5O7qI5WuHKvVbuOGWXZAovkqIhhmwxJswQoEysfwWk=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    fontconfig
    freetype
    libglvnd
    libappindicator-gtk3
    wayland
    libxkbcommon
    libX11
    libXext
    libXi
    libXrender
    libxtst
    zlib
  ];

  # jangan di-strip, ini app-image hasil jpackage (native launcher + JRE bundel)
  dontStrip = true;

  desktopItems = [
    (makeDesktopItem {
      name = "com.abdownloadmanager.desktop";
      desktopName = "AB Download Manager";
      comment = "Manage and organize your download files better than before";
      genericName = "Download Manager";
      exec = "ABDownloadManager";
      icon = "ABDownloadManager";
      terminal = false;
      categories = [ "Network" "Utility" ];
      startupWMClass = "com-abdownloadmanager-desktop-AppKt";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/ab-download-manager $out/bin $out/share/pixmaps
    cp -r bin lib $out/opt/ab-download-manager/
    install -Dm644 $out/opt/ab-download-manager/lib/ABDownloadManager.png \
      $out/share/pixmaps/ABDownloadManager.png

    # SKIKO_RENDER_API=SOFTWARE = default upstream (AUR) buat hindarin crash/glitch
    # render OpenGL Compose Desktop di banyak setup Linux; masih bisa dioverride
    # user via env var karena pakai --set-default.
    # libfontconfig, libdbus & libappindicator di-dlopen runtime (bukan NEEDED
    # ELF), jadi autoPatchelfHook gak bisa nemuin walau udah di buildInputs ->
    # taro di LD_LIBRARY_PATH manual. Tanpa fontconfig: JVM error "Fontconfig
    # head is null". Tanpa dbus: crash pas load native theme lib nucleus.
    for exe in ABDownloadManager ABDownloadManagerCli ABDownloadManagerNativeMessagingHost; do
      makeWrapper $out/opt/ab-download-manager/bin/$exe $out/bin/$exe \
        --set-default SKIKO_RENDER_API SOFTWARE \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ fontconfig.lib dbus.lib libappindicator-gtk3 ]}"
    done

    runHook postInstall
  '';

  meta = {
    description = "Download manager (HTTP/HTTPS/FTP), multi-connection & resumable, mirip IDM";
    homepage = "https://abdownloadmanager.com/";
    changelog = "https://github.com/amir1376/ab-download-manager/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "ABDownloadManager";
    maintainers = [ ];
  };
})
