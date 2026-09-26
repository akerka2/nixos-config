{ pkgs, lib, ... }:

{
  home.username = "akerka";
  home.homeDirectory = "/home/akerka";
  home.stateVersion = "26.05";
  
  dconf.settings = {
    # Xed settings
    "org/x/editor/preferences/editor" = {
      tabs-size = lib.hm.gvariant.mkUint32 2;
      insert-spaces = true;
      auto-indent = true;
      wrap-mode = "none";
      scheme = "elementary light";
    };
    "org/x/editor/plugins" = {
      active-plugins = [ "wordcompletion" "time" "textsize" "spell" "sort" "open-uri-context-menu" "modelines" "joinlines" "docinfo" ];
    };
   
    # Use Meslo Font for powerlevel10k
    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
        font = "JetBrainsMono Nerd Font Mono 12";
        use-system-font = false;
    };
  };

  programs.keepassxc.enable = true;

  # MPV settings (alternative to edit ~/.config/mpv/input.config
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      cut  # Скрипт обрезки видео без перекодирования, в копию
      # другие скрипты...
      mpv-image-viewer.minimap
    ];
    extraMakeWrapperArgs = [
      "--prefix" "PATH" ":" "${lib.makeBinPath [ pkgs.ffmpeg ]}"
    ];

    bindings = {
      "MBTN_LEFT" = "cycle pause";
      "MBTN_LEFT_DBL" = "cycle fullscreen";    # toggle fullscreen
      "RIGHT" = "no-osd seek  1 ";
      "LEFT" = "no-osd seek -1";
      "UP" = "add volume 2";
      "DOWN" = "add volume -2";
      "Shift+RIGHT" = "seek  30";
      "Shift+LEFT" = "seek  -30";
      "Ctrl+RIGHT" = "no-osd frame-step";
      "Ctrl+LEFT" = "no-osd frame-back-step";
      "ENTER" = "cycle fullscreen";
      "ESC" = "{encode} quit 4";
      "r" = "cycle-values video-rotate 0 90 180 270";
      "`" = ''cycle-values video-aspect-override "16:9" "4:3" "2.35:1" "-1"'';
      "v" = "vf toggle hflip";
      "b" = "vf toggle vflip";
    };
    config = {
      volume = 100;
    #  fs = true;
    };
  };
  
  # Файл настройки скрипта перекодирования видео
  home.file.".config/mpv-cut/config.lua".text = ''
    -- config.lua
    ACTIONS.COPY = function(d)
	    local args = {
		    "ffmpeg",
		    "-nostdin", "-y",
		    "-loglevel", "error",
		    "-ss", d.start_time,
		    "-t", d.duration,
		    "-i", d.inpath,
		    "-c", "copy",
		    "-map", "0",
		    "-dn",
		    "-avoid_negative_ts", "make_zero",
		    utils.join_path(d.indir, d.infile_noext .. "_COPY_" .. d.channel .. "_FROM_" .. d.start_time_hms .. "_TO_" .. d.end_time_hms .. d.ext)
	    }
	    mp.command_native_async({
		    name = "subprocess",
		    args = args,
		    playback_only = false,
	    }, function()
		    mp.msg.info("Done")
		    mp.osd_message("Done")
	    end)
    end
  '';
     
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide          # подсветка Nix
      ms-python.python   # Поддержка Python
    ];
  };

  home.packages = with pkgs; [
    nixd
  ];
  
  programs.zsh = {
    enable = true;
    shellAliases = {
      # Aliases for quick system update
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
      update = "nix flake update --flake /etc/nixos && nixos-rebuild build --flake /etc/nixos#$(hostname) && nvd diff /run/current-system result && sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)  ";
    };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    # copy a present powerlevel config
    initContent = ''
      # Load p10k config if it exists
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';
  };

  home.file.".local/share/backgrounds" = {
    source = ./backgrounds;
    recursive = true;
  };
  
  home.file.".p10k.zsh".source = ./.p10k.zsh;
}
