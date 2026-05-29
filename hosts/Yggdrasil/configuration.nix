{ config, pkgs, ... }:
{
  # Host!
  networking.hostName = "yggdrasil";
  
  # AMD Radeon GPU
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # For Steam
  
  # Enable Cinnamon Desktop
  services.xserver = {
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
  services.libinput.enable = true;
  services.displayManager.defaultSession = "cinnamon";
  services.speechd.enable = false; # база сырых голосов слишком велика 600МБ
  services.orca.enable = false; # orca (экранный диктор) тянет speechd

  services.displayManager.lightdm.extraConfig = ''
    greeter-setup-script=${pkgs.numlockx}/bin/numlockx on
  '';

  console.useXkbConfig = true;
}
