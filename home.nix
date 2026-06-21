{ pkgs, lib, ... }:

{
  home.username = "akerka";
  home.homeDirectory = "/home/akerka";
  home.stateVersion = "26.05";
  
  #nixpkgs.config.allowUnfree = true; # for ~/.config/nixpkgs/config.nix

  dconf.settings = {
    # Xed settings
    "org/x/editor/preferences/editor" = {
      tabs-size = lib.hm.gvariant.mkUint32 2;
      insert-spaces = true;
      auto-indent = true;
      wrap-mode = "none";
      scheme = "elementary light";
    };
    "org/x/editor/plugins" = {
      active-plugins = [ "wordcompletion" "time" "textsize" "spell" "sort" "open-uri-context-menu" "modelines" "joinlines" "docinfo" ];
    };
   
    # Use Meslo Font for powerlevel10k
    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
        font = "JetBrainsMono Nerd Font Mono 12";
        use-system-font = false;
    };
    
    # Common (Cinnamon) settings for language switching
    "org/cinnamon/desktop/keybindings/wm" = {
      switch-input-source = [ "<Alt>Shift_L" "<Shift>Alt_L" ]; # Switch language
      switch-input-source-backward = ["<Primary><Alt>Shift_L" "<Primary><Shift>Alt_L"]; # Switch backward
    };
    "org/cinnamon/desktop/interface" = {
      keyboard-layout-prefer-variant-names = true;
    };
    "org/cinnamon/desktop/input-sources" = {
      per-window = true;
    };
  };

  programs.keepassxc.enable = true;

  # MPV settings (alternative to edit ~/.config/mpv/input.config
  programs.mpv = {
    enable = true;
    bindings = {
      "RIGHT" = "no-osd seek  1 ";
      "LEFT" = "no-osd seek -1";
      "UP" = "add volume 2";
      "DOWN" = "add volume -2";
      "Shift+RIGHT" = "seek  30";
      "Shift+LEFT" = "seek  -30";
      "Ctrl+RIGHT" = "no-osd frame-step";
      "Ctrl+LEFT" = "no-osd frame-back-step";
      "ENTER" = "cycle fullscreen";
      "ESC" = "{encode} quit 4";
      "r" = "cycle-values video-rotate 0 90 180 270";
      "`" = ''cycle-values video-aspect-override "16:9" "4:3" "2.35:1" "-1"'';
    };
    config = {
      volume = 100;
    #  fs = true;
    };
  };
  
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide          # подсветка Nix
    ];
  };
  home.packages = with pkgs; [
    nixd
  ];

  programs.zsh = {
    enable = true;
    shellAliases = {
      # Aliases for quick system update
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
      update = "nix flake update --flake ~/.nixos-config && rebuild";
    };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    # copy a present powerlevel config
    initContent = ''
      # Load p10k config if it exists
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';
  };

  home.file.".local/share/backgrounds" = {
    source = ./backgrounds;
    recursive = true;
  };
  
  home.file.".p10k.zsh".source = ./.p10k.zsh;
}
