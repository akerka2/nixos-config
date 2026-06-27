{ config, lib, pkgs, ... }:

# Создаем пакет nix из репозитория темы для plymouth Catppuccin
let
  myCatppuccinPlymouth = pkgs.stdenv.mkDerivation {
     pname = "catppuccin-plymouth-custom";
     version = "1.0";
     
     # === 1. Скачать github repo ===
     src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "plymouth";
        rev = "main";
        sha256 = "14grk7sscas8knwzpkl28wsqhk1f85415i1h46n1r6wrgnavi4nw";
     };
     
     # === 2. Установка файлов ===
     installPhase = ''
        mkdir -p $out/share/plymouth/themes
        cp -r themes/* $out/share/plymouth/themes
        
        # Fix hardcoded /usr/share path in all .plymouth files
        for f in $out/share/plymouth/themes/*/*.plymouth; do
          substituteInPlace "$f" \
            --replace "/usr/share/plymouth/themes" "$out/share/plymouth/themes"
        done
     '';
  };
in

{
  boot.loader.systemd-boot.enable = true; # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3; # Limit number of kernels
  boot.loader.systemd-boot.consoleMode = "max"; # maximal resolution during boot-time
  boot.loader.timeout = 6; # Skip boot menu
  boot.initrd.systemd.enable = true; # Use initrd - little os between loader and switch-root
  boot.initrd.verbose = false; # Silences the initrd-stage messages
  boot.consoleLogLevel = 3; # Set kernel boot-time verbose level. 3-errors, 4-warnings
  boot.kernelParams = [
    "quiet"
    "splash"
    "intremap=on"
    "boot.shell_on_fall"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
    ];
  boot.plymouth.enable = true; # Use plymout for bootscreen
  boot.plymouth.themePackages = [ myCatppuccinPlymouth ]; # Bundle theme-package into initrd
  boot.plymouth.theme = "catppuccin-mocha";
  boot.plymouth.logo = pkgs.runCommand "empty.png" { buildInputs = [ pkgs.imagemagick ]; } ''
    convert -size 1x1 xc:transparent $out
  ''; # Create empty png to supress nix-logo injection
        
  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jerusalem";
 
  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  
  services.syncthing = {
    enable = true;
    user = "akerka";
    dataDir = "/home/akerka/Clouds/Syncthing";
    configDir = "/home/akerka/.config/syncthing";
    openDefaultPorts = true;  # opens port 22000 in firewall
  };
  
  # Set keyboard layouts
  services.xserver = {
    xkb = {
      layout = "us,ru";
      options = "grp:alt_shift_toggle";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.akerka = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "video" "render"]; # wheel enables ‘sudo’ for the user. docker, video and render needed by Docker
    hashedPassword = "$6$wNwTFr2lCALC4NbF$jDsQGztIeRC1Pe9GZhDdqWKg4y43Ke4JYu9km5td2EMreoX4rIqhKLNkkwYgtJvwbfm6lgmjC/5E6QV.FitI5.";
    shell = pkgs.zsh;
  };
  users.users.root.hashedPassword = "!"; # To prevent login under root

  # Allow unfree software
  nixpkgs.config.allowUnfree = true;

  programs.dconf.enable = true; # Enables extensions support
  programs.firefox.enable = true;
  programs.gamemode.enable = true;

  # Enable Steam
   programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  environment.systemPackages = with pkgs; [
    aria2 # Downloader engine for yt-dlp
    blender
    btrfs-assistant # experimental
    btrbk # experimental
    cage # Run gui-apps in tty by: cage _programname_
    direnv # For vs code nixos edits
    dracut # Provides lsinitrd
    duckdb # experimental
    ffmpegthumbnailer
    git
    gnome-system-monitor
    htop
    httm # Experimental for btrfs file virsioning
    inotify-tools # For inotifywait - file monotor 
    kdePackages.breeze # Cursor theme
    libreoffice-fresh
    lshw
    mangohud #hud for games
    mint-l-icons
    myCatppuccinPlymouth # I hope, it makes theme appear in /run/current-system/sw
    nano
    nemo-preview
    protonup-qt
    obsidian
    onlyoffice-desktopeditors
    pciutils # Provide lspci
    poppler-utils # Provide pdftoppm
    (python3.withPackages (ps: [ ps.openpyxl ]))
    qbittorrent
    qimgv
    rawtherapee
    rclone
    signal-desktop
    snapper # snapshots
    snapper-gui # experimental for snapper
    syncthing
    wget
    yt-dlp

    gdk-pixbuf
      (writeTextFile {
        name = "raw-dng-thumbnailer";
        destination = "/share/thumbnailers/raw-dng.thumbnailer";
        text = ''
          [Thumbnailer Entry]
          TryExec=gdk-pixbuf-thumbnailer
          Exec=gdk-pixbuf-thumbnailer -s %s %u %o
          MimeType=image/x-adobe-dng;image/x-dng;
        '';
      })
    
    thunar

    #ntfsprogs-plus
    
    #davinci-resolve
    rapidraw
  ];
  
  fonts = {
    enableDefaultPackages = false;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
      inter
      noto-fonts-color-emoji
      ibm-plex
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif     = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans"  ];
        monospace = [ "JetBrainsMono Nerd Font" "IBM Plex Mono" ];
        emoji     = [ "Noto Color Emoji" ];
      };
    };
  };

  # To enable flake
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  home-manager.backupFileExtension = "backup";
  
  system.stateVersion = "25.11"; # Initial OS version
  system.autoUpgrade = {
    enable = true; # Enable auto update
    flake = "/etc/nixos";
    dates = "weekly";
    persistent = true;
  };
  
  # Garbage collector
  nix.gc = {
      automatic = true;
      dates = "weekly";
      persistent = true;
      options = "--delete-older-than 30d";
      
  };
  # И оптимизация store (дедупликация)
  nix.settings.auto-optimise-store = true;
  
  #boot.kernelPackages = pkgs.linuxKernel.packages.linux_testing; #experimental
  
   # Host!
  networking.hostName = "yggdrasil";
  
  # AMD Radeon GPU
  boot.initrd.kernelModules = [ "amdgpu" ];
  #services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # For Steam
  nixpkgs.config.rocmSupport = true; # Big package for blender with HIP support
  
  
  # ROCm / HIP для Blender
  #hardware.amdgpu.opencl.enable = true;

  #environment.systemPackages = with pkgs; [
  #  rocmPackages.clr
  #  rocmPackages.rocm-runtime
  #];
  
  # RX 7800 XT — gfx1101, ROCm иногда не распознаёт автоматически
  environment.variables = {
    HSA_OVERRIDE_GFX_VERSION = "11.0.1";
  };
  
  # Enable Cinnamon Desktop
  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      enable = true;
      background = "${../../backgrounds/field.jpg}";
      greeters.slick = {
  		enable = true;
  		theme.name = "Mint-Y-Aqua";
  		iconTheme.name = "Mint-Y-Blue";
  		cursorTheme.name = "breeze_cursors";
  	  };
    };
    desktopManager.cinnamon.enable = true;
  };
  
  # Добавить вместо lightdm, например SDDM:
  
  #services.xserver.desktopManager.cinnamon.enable = true;  # остаётся
  #services.displayManager.defaultSession = "cinnamon";
  
  services.libinput.enable = true;
  services.speechd.enable = false; # база сырых голосов слишком велика 600МБ
  services.orca.enable = false; # orca (экранный диктор) тянет speechd
}

