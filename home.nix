{ pkgs, lib, ... }:

{
  home.username = "akerka";
  home.homeDirectory = "/home/akerka";
  home.stateVersion = "25.11";

  dconf.settings = {
    # Set keyboard layouts (GNOME)
    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.hm.gvariant.mkTuple ["xkb" "us"])
        (lib.hm.gvariant.mkTuple ["xkb" "ru"])
      ];
      # enable keyboard shortcut
      xkb-options = ["grp:alt_shift_toggle"];
    };

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

    # Xed settings
    "org/x/editor/preferences/editor" = {
      tabs-size = 2;
      insert-spaces = true;
      auto-indent = true;
      wrap-mode = "none";
      scheme = "kate";
    };
    "org/x/editor/plugins" = {
      active-plugins = [ "wordcompletion" "time" "textsize" "spell" "sort" "open-uri-context-menu" "modelines" "joinlines" "docinfo" ];
    };
    
    # Уберем использование ALT для перетаскивания окна
    "org/cinnamon/desktop/wm/preferences" = {
      mouse-button-modifier = "<Super>";
     };
    "org/gnome/desktop/wm/preferences" = {
      mouse-button-modifier = "<Super>";
    };

    #Setup buttons set (for GNOME)
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
    "org/cinnamon/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
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
   
    # Use Meslo Font for powerlevel10k
    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
        font = "JetBrainsMono Nerd Font Mono 12";
        use-system-font = false;
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
    ${pkgs.glib}/bin/gsettings set org.cinnamon enabled-applets "['panel1:left:0:menu@cinnamon.org:210', 'panel1:left:1:separator@cinnamon.org:211', 'panel1:left:2:grouped-window-list@cinnamon.org:212', 'panel1:right:0:systray@cinnamon.org:213', 'panel1:right:5:keyboard@cinnamon.org:218', 'panel1:right:8:sound@cinnamon.org:221', 'panel1:right:7:network@cinnamon.org:220', 'panel1:right:1:xapp-status@cinnamon.org:214', 'panel1:right:2:notifications@cinnamon.org:215', 'panel1:right:9:power@cinnamon.org:222', 'panel1:right:10:calendar@cinnamon.org:223', 'panel1:right:11:cornerbar@cinnamon.org:224']"
  '';

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
    	"r" = "cycle-values video-rotate 0 90 180 270";
    	"`" = ''cycle-values video-aspect-override "16:9" "4:3" "2.35:1" "-1"'';
		};
		config = {
			volume = 100;
		};
	};
	
	programs.zsh = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
    };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    initContent = ''
      # Load p10k config if it exists
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';
  };

  home.file.".local/share/backgrounds" = {
    source = ./backgrounds;
    recursive = true;
  };

	home.file.".local/share/nemo/actions" = {
    source = ./nemo-actions;
    recursive = true;
  };
  
  home.file.".config/cinnamon/spices/grouped-window-list@cinnamon.org" = {
    source = ./grouped-window-list-config;
   recursive = true;
  };
  
  home.file.".p10k.zsh".source = ./.p10k.zsh;
  
}
