# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia/disable.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.gc.options = "--delete-generations +5";

  networking.hostName = "nixos_mac"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.


  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Dublin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IE.UTF-8";
    LC_IDENTIFICATION = "en_IE.UTF-8";
    LC_MEASUREMENT = "en_IE.UTF-8";
    LC_MONETARY = "en_IE.UTF-8";
    LC_NAME = "en_IE.UTF-8";
    LC_NUMERIC = "en_IE.UTF-8";
    LC_PAPER = "en_IE.UTF-8";
    LC_TELEPHONE = "en_IE.UTF-8";
    LC_TIME = "en_IE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
  };
 
  services.acpid = {
    enable = true;
    lidEventCommands =
    ''
      export PATH=$PATH:/run/current-system/sw/bin

      lid_state=$(cat /proc/acpi/button/lid/LID0/state | awk '{print $NF}')
      if [ $lid_state = "closed" ]; then
        # Set brightness to zero
        echo 0  > /sys/class/backlight/gmux_backlight/brightness
      else
        # Reset the brightness
        echo 500  > /sys/class/backlight/gmux_backlight/brightness
      fi
    '';

    powerEventCommands =
    ''
      systemctl suspend
    '';
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend = no
    AllowHibernation = no
    AllowHybridSleep = no
    AllowSuspendThenHibernate = no
  '';
  
  # https://nixos.wiki/wiki/Laptop
  # Thermald proactively prevents overheating on Intel CPUs and works well with other tools.
  services.thermald.enable = true;
  services.tlp.enable = true;
  powerManagement.powertop.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    mac = {
      isNormalUser = true;
      description = "vb";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [];
    };
    nix = {
     isNormalUser = true;
     description = "vb";
     extraGroups = [ "networkmanager" "wheel" ];
     packages = with pkgs; [];
   };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  powertop python3 nfs-utils
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  programs.ssh.startAgent = true;  
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [80 443 22 
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  services.k3s = {  
    enable = true;
    role = "server";
    token = "<token>";
    serverAddr = "https://ip:6443";
  };

  services.k3s.extraFlags = toString [
    "--write-kubeconfig-mode" "644" # "--kubelet-arg=v=4" # Optionally add additional args to k3s
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
