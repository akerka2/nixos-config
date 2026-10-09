{ config, lib, pkgs, inputs, ... }:

{
  ## Hostname ##
  networking.hostName = "conceptd";

  ## Nvidia GeForce GTX 1650 Max-Q + intel PRIME ##
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages; # Use LTS-kernel for compatiblity
  boot.initrd.kernelModules = [ "i915" ];

  services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  modesetting.enable = true;
  powerManagement.enable = true;
  powerManagement.finegrained = true; # Позволяет уходить в D3cold
  open = false;
  nvidiaSettings = true;
  package = config.boot.kernelPackages.nvidiaPackages.stable;

  prime = {
    sync.enable = false;
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
};

# Принудительно укажем Mutter/GNOME запускать основной стол на Intel
environment.sessionVariables = {
  "KWIN_DRM_DEVICES" = "/dev/dri/card0"; # Если вдруг используете KDE
  "AQ_DRM_DEVICES" = "/dev/dri/card0";
};

# Задаем явно порядок видеокарт для системы (Intel — первая)
services.xserver.displayManager.setupCommands = ''
  ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 0 0
'';
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # For Steam
  
  

 
  ## Gnome ##
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  services.xserver.xkb = { layout = "us,ru"; options = "grp:alt_shift_toggle"; };
  services.libinput.enable = true;

  ## Wacom touchscreen and digitiser ##
  hardware.opentabletdriver.enable = true;
  hardware.sensor.iio.enable = true;
  services.power-profiles-daemon.enable = true;
  
  environment.systemPackages = with pkgs; [
  ]; 
}
