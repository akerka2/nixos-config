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
 
  
  # Enable ROCM  
  nixpkgs.config.rocmSupport = true;
  environment.systemPackages = with pkgs; [
    rocmPackages.rocm-runtime
    rocmPackages.rocblas
    rocmPackages.hipblas
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
  ];  
  
  # runtime for LLMs
  services.ollama = {
    enable = true;
    acceleration = "rocm";
  };
  
  # docker для kohya_ss - обучение lora
  virtualisation.docker.enable = true;
}
