{ config, lib, pkgs, ... }:

{
  dconf.settings = {
    # Set keyboard layouts (GNOME)
    "org/gnome/desktop/input-sources" = {
    sources = [
      (lib.hm.gvariant.mkTuple ["xkb" "us"])
      (lib.hm.gvariant.mkTuple ["xkb" "ru"])
    ];
    
    # enable keyboard shortcut
    xkb-options = ["grp:alt_shift_toggle"];
    
    # Уберем использование ALT для перетаскивания окна
    "org/gnome/desktop/wm/preferences" = {
      mouse-button-modifier = "<Super>";
    };
    
    #Setup buttons set (for GNOME)
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
    
    
  };
}
