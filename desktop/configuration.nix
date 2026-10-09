{ config, lib, pkgs, inputs, ... }:

{
  ## AMD Radeon GPU ##
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics.enable = true; # For Steam and ROCM
  hardware.graphics.enable32Bit = true; # For Steam and ROCM
  hardware.amdgpu.opencl.enable = true;# ROCm / HIP для Blender

  hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];
  
  nixpkgs.config.rocmSupport = true; # Big package for blender with HIP support
    
  systemd.tmpfiles.rules = let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [ clr rocblas hipblas rocm-device-libs ];
    };
  in [
    "L+ /opt/rocm - - - - ${rocmEnv}"
  ];
  
  # Специализации под загрузку разных десктопов

  # LightDM and its greeter
  services.xserver.displayManager.lightdm = { 
    enable = true;
    background = "${../backgrounds/field.jpg}";
    greeters.slick = {
  		enable = true;
  		theme.name = "Mint-Y-Aqua";
  		iconTheme.name = "Mint-Y-Blue";
  		cursorTheme.name = "breeze_cursors";
  	};
  };
  #Cinnamon Desktop
  services.xserver.desktopManager.cinnamon.enable = true;
 
  ### ПАКЕТЫ ПРОГРАММ И ШРИФТОВ ###
  environment.systemPackages = with pkgs; [
    pkgsRocm.blender # Blender with HIP support
    mangohud #hsud for games
    rawtherapee
    davinci-resolve
  ];
}
