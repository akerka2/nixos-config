{ pkgs, lib, ... }:

{
  home.username = "akerka";
  home.homeDirectory = "/home/akerka";
  home.stateVersion = "26.05";
  
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
  
  # Скрыть ненужные пункты меню приложений, переопределив их
  # В конфигурации home-manager
  xdg.desktopEntries = {
    "thunar-bulk-rename" = {
      name = "Bulk Rename";
      noDisplay = true;  # Вот это скрывает из меню
      exec = "thunar --bulk-rename";
    };
  };
  
    dconf.settings = {
    "org/cinnamon/desktop/interface" = {
      # Set Cinnamon theme
      gtk-theme = "Mint-L-Aqua";
      # Set icon theme
      icon-theme = "Mint-L-Aqua";

      # Set cursor theme
      cursor-theme = "breeze_cursors";
    };
      
    # Select panel theme
    "org/cinnamon/theme" = {
      name = "Mint-L-Dark-Aqua";
    };
    
    # Уберем использование ALT для перетаскивания окна
    "org/cinnamon/desktop/wm/preferences" = {
      mouse-button-modifier = "<Super>";
    };
    
    #Set fonts
    "org/gnome/desktop/interface" = {
      font-name = "Ubuntu 10"; #Default font
      document-font-name = "Sans 12"; #Document
      monospace-font-name = "JetBrainsMono Nerd Font 12"; #Monospace
      titlebar-font = "Ubuntu Semi-Bold 12"; #Windows title
    };
    
    # Настроим нижнюю панель
    "org/cinnamon" = {
      panels-height = "['1:40']"; #Высота
      panel-zone-symbolic-icon-sizes = ''[{"panelId": 1, "left": 32, "center": 28, "right": 16}]'';
    };
    
    # Set backgrounds
    "org/cinnamon/desktop/background" = {
      picture-uri = "file:///home/akerka/.local/share/backgrounds/wood.jpg";
      picture-options = "zoom";  # or "stretched", "centered", "scaled", "wallpaper"
    };
    
    # Hide removable from desktop
    "org/nemo/desktop" = {
      volumes-visible = false;
      home-icon-visible = true;
    };
  };
  
  home.activation.setCinnamonApplets = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.glib}/bin/gsettings set org.cinnamon enabled-applets "['panel1:left:0:menu@cinnamon.org:210',
    'panel1:left:1:separator@cinnamon.org:211', 'panel1:left:2:grouped-window-list@cinnamon.org:212',
    'panel1:right:0:systray@cinnamon.org:213', 'panel1:right:5:keyboard@cinnamon.org:218',
    'panel1:right:8:sound@cinnamon.org:221', 'panel1:right:7:network@cinnamon.org:220',
    'panel1:right:1:xapp-status@cinnamon.org:214', 'panel1:right:2:notifications@cinnamon.org:215',
    'panel1:right:9:power@cinnamon.org:222', 'panel1:right:10:calendar@cinnamon.org:223',
    'panel1:right:11:cornerbar@cinnamon.org:224']"
  '';
  
  home.file.".local/share/nemo/actions" = {
    source = ../../nemo-actions;
    recursive = true;
  };
}
