{ config, lib, pkgs, inputs, ... }:

{
  ## Hostname ##
  networking.hostName = "conceptd";

  ## Nvidia GeForce GTX 1650 Max-Q + intel PRIME ##
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages; # Use LTS-kernel for compatiblity
  boot.initrd.kernelModules = [ "i915" ];

#  services.xserver.videoDrivers = [ "nvidia" ];
services.xserver.videoDrivers = [ "modesetting" ];
#  hardware.nvidia = {
#    modesetting.enable = true;
#    powerManagement.enable = true; # Nvidia Power Management
#    powerManagement.finegrained = true; # Allows D3cold for Nvidia (sleep)
#    open = false;
#    nvidiaSettings = true;
#    package = config.boot.kernelPackages.nvidiaPackages.stable;
#    prime = {
#      sync.enable = false;
#      offload = {
#        enable = true;
#       enableOffloadCmd = true; # create nvidia-offload utilite
#      };
#      intelBusId = "PCI:0:2:0";
#      nvidiaBusId = "PCI:1:0:0";
#    };
#  };
#  hardware.graphics.enable = true;
#  hardware.graphics.enable32Bit = true; # For Steam
  
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
