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

## 2. Блокируем (blacklist) все модули ядра Nvidia и Nouveau ##
  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidia"
    "nvidia_drm"
    "nvidia_modeset"
    "nvidia_uvm"
    "i2c_nvidia_gpu"
  ];
  ## 3. Отключаем modeset для nouveau в modprobe ##
  boot.extraModprobeConfig = ''
    options nouveau modeset=0
  '';

  ## 4. Правила udev: физическое отключение (remove) устройств Nvidia с PCI-шины ##
  services.udev.extraRules = ''
    # Удаляем USB xHCI Host Controller от Nvidia (если есть)
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
    
    # Удаляем USB Type-C UCSI от Nvidia (если есть)
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
    
    # Удаляем аудио-контроллер Nvidia (HDMI/DP Audio)
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
    
    # Удаляем саму видеокарту 3D/VGA Controller (GTX 1650)
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';

  # Удалите/закомментируйте блок `hardware.nvidia` и `hardware.nvidia.prime`
  
  ## touchscreen ##
  boot.kernelParams = [
    "i2c_hid.polling_interval=0"
    "i2c_hid_acpi.quirks=0x0001" # Принудительный опрос HID-дескрипторов
  ];
  hardware.enableAllFirmware = true;
  services.xserver.wacom.enable = true; # Корректирует правила udev для Wacom/I2C
  
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
