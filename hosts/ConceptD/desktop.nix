{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.displayManager.defaultSession = "gnome";
  services.xserver.xkb = { layout = "us,ru"; options = "grp:alt_shift_toggle"; };
  
  services.libinput.enable = true;

  # Для стилуса Wacom (Ezel использует Wacom-совместимый дигитайзер)
  hardware.opentabletdriver.enable = true;
  
  environment.systemPackages = with pkgs; [
    squeekboard  # лучше интегрируется с GNOME на Wayland
  ];
  
  services.power-profiles-daemon.enable = true;
  
  services.iio-sensor-proxy.enable = true; # GNOME подхватит автоматически
  
  environment.systemPackages = with pkgs; [
    xournalpp    # рисование/заметки стилусом
    drawing      # простой аналог Paint с touch-поддержкой
  ];
}
