{ ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.extraModprobeConfig = "options zfs zfs_arc_max=${toString (8 * 1024 * 1024 * 1024)}";

  services.zfs = {
    autoScrub = {
      enable = true;
      pools = [ "nest" ];
    };
    autoSnapshot.enable = true;
  };
}
