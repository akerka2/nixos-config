{ config, pkgs, ... }:
{
  # Host!
  networking.hostName = "yggdrasil";
  
  # AMD Radeon GPU
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    hardware.graphics.enable32Bit = true; # For Steam
  };
  
  # Enable and customize Cinnamon Desktop
  services = {
    xserver = {
      enable = true;
      displayManager.lightdm = {
        enable = true;
        background = "${../../backgrounds/field.jpg}";
        greeters.slick = {
          enable = true;
          theme.name = "Mint-Y-Aqua";
          iconTheme.name = "Mint-Y-Blue";
          cursorTheme.name = "breeze_cursors";
        };
      };
      desktopManager.cinnamon.enable = true;
    };
    libinput.enable = true;
    displayManager.defaultSession = "cinnamon";
    speechd.enable = false; # база сырых голосов слишком велика 600МБ
    orca.enable = false; # orca (экранный диктор) тянет speechd
  };
}
