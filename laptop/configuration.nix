{ config, lib, pkgs, inputs, ... }:
{
### HOSTNAME ###
  networking.hostName = "conceptd";

### GPU ###
  boot.initrd.kernelModules = [ "i915" ];

  # Nvidia GeForce GTX 1650 Max-Q + intel PRIME
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # For Steam
  
### DESKTOP ###
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
    
    xournalpp    # рисование/заметки стилусом
    drawing      # простой аналог Paint с touch-поддержкой
  ];
  
  services.power-profiles-daemon.enable = true;
  
  hardware.sensor.iio.enable = true;
}
