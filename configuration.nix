{ config, lib, pkgs, ... }:

# Создаем пакет nix из репозитория темы для plymouth (atppuccin
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
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  
  boot.loader.systemd-boot.enable = true; # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3; # Limit number of kernels
  boot.loader.systemd-boot.consoleMode = "max"; # maximal resolution during boot-time
  boot.loader.timeout = 0; # Skip boot menu
  boot.initrd.systemd.enable = true; # Use initrd - little os between loader and switch-root
  boot.initrd.verbose = false; # Silences the initrd-stage messages
  boot.consoleLogLevel = 3; # Set kernel boot-time verbose level. 3-errors, 4-warnings
  #boot.initrd.kernelModules = [ "amdgpu" ]; # For plymouth. Once have commented and got blackscreen. # Moved to hosts/Yggdrasil/gpu.nix
  boot.kernelParams = [
    "quiet"
    "splash"
    "intremap=on"
    "boot.shell_on_fall"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
    "plymouth.use-simpledrm"
    "initcall_blacklist=simpledrm_platform_driver_init"
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
 
  # Enable Cinnamon Desktop
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.cinnamon.enable = true;
  };
  services.libinput.enable = true;
  services.displayManager.defaultSession = "cinnamon";
  
  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  
  # lightdm-slick-greeter settings
	services.xserver.displayManager.lightdm = {
		background = "/etc/nixos/backgrounds/field.jpg";
		greeters.slick = {
			enable = true;
			theme.name = "Mint-Y-Aqua";
			iconTheme.name = "Mint-Y-Blue";
			cursorTheme.name = "breeze_cursors";
		};
	};
	
	services.syncthing = {
    enable = true;
    user = "akerka";
    dataDir = "/home/akerka/Syncthing";
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
    extraGroups = [ "wheel"]; # Enable ‘sudo’ for the user.
    hashedPassword = "$6$wNwTFr2lCALC4NbF$jDsQGztIeRC1Pe9GZhDdqWKg4y43Ke4JYu9km5td2EMreoX4rIqhKLNkkwYgtJvwbfm6lgmjC/5E6QV.FitI5.";
    shell = pkgs.zsh;
  };
  users.users.root.hashedPassword = "!"; # To prevent login under root

  # Allow unfree software
  nixpkgs.config.allowUnfree = true;

  programs.dconf.enable = true; # Enables extensions support
  programs.firefox.enable = true;

  # Enable Steam
  # hardware.graphics.enable32Bit = true; # Moved to gnu.nix
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    blender
    dracut # Provides lsinitrd
    ffmpegthumbnailer
    flameshot
    git
    gnome-system-monitor
    htop
    kdePackages.breeze
    libreoffice-fresh
    lshw
    mint-l-icons
    myCatppuccinPlymouth # I home, it makes theme appear in /run/current-system/sw
    nemo-preview
    nano
    obsidian
    pciutils #provide lspci
    (python3.withPackages (ps: [ ps.openpyxl ]))
    qbittorrent
    qimgv
    rawtherapee
    syncthing
    wget
    vscode

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
  ];
  
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    #promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  };

  # To enable flake
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  home-manager.backupFileExtension = "backup";
  
  system.stateVersion = "25.11"; # Initial OS version
}

