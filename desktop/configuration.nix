{ config, lib, pkgs, inputs, ... }:

### Создаем пакет-обертку для Blender, с коррекциями против краша HIP из-за конфликта версий LLVM ###
# (см. https://github.com/NixOS/nixpkgs/issues/530702)
let
  
  
  blenderHipFixed = pkgs.symlinkJoin {
    name = "blender-hip-fixed";
    paths = [ pkgs.pkgsRocm.blender ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/blender \
        --set LD_PRELOAD "${pkgs.rocmPackages.rocm-comgr}/lib/libamd_comgr.so.3"
    '';
  };
in

{
  # Desktop Environment: LightDM, SlickGreeter
  services.xserver.displayManager.lightdm = { 
    enable = true;
    background = "${./backgrounds/field.jpg}";
    greeters.slick = {
  		enable = true;
  		theme.name = "Mint-Y-Aqua";
  		iconTheme.name = "Mint-Y-Blue";
  		cursorTheme.name = "breeze_cursors";
  	};
  };
  # Enable Cinnamon Desktop
  services.xserver.desktopManager.cinnamon.enable = true;
  
  

  ##<-- ГРАФИЧЕСКИЕ ДРАЙВЕРЫ И БИБЛИОТЕКИ -->##
  # AMD Radeon GPU
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
  
  ##<-- ПАКЕТЫ ПРОГРАММ И ШРИФТОВ -->##
  environment.systemPackages = with pkgs; [
    pkgsRocm.blender # Blender with HIP support
    mangohud #hsud for games
    rawtherapee
    davinci-resolve
  ];
}
