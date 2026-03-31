{ config, lib, pkgs, ... }:

{
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
    ${pkgs.glib}/bin/gsettings set org.cinnamon enabled-applets "['panel1:left:0:menu@cinnamon.org:210', 'panel1:left:1:separator@cinnamon.org:211', 'panel1:left:2:grouped-window-list@cinnamon.org:212', 'panel1:right:0:systray@cinnamon.org:213', 'panel1:right:5:keyboard@cinnamon.org:218', 'panel1:right:8:sound@cinnamon.org:221', 'panel1:right:7:network@cinnamon.org:220', 'panel1:right:1:xapp-status@cinnamon.org:214', 'panel1:right:2:notifications@cinnamon.org:215', 'panel1:right:9:power@cinnamon.org:222', 'panel1:right:10:calendar@cinnamon.org:223', 'panel1:right:11:cornerbar@cinnamon.org:224']"
  '';
  
  home.file.".local/share/nemo/actions" = {
    source = ../../nemo-actions;
    recursive = true;
  };
  
  home.file.".config/cinnamon/spices/grouped-window-list@cinnamon.org" = {
    source = ../../grouped-window-list-config;
   recursive = true;
  };
}
