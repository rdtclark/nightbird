{ ... }:

# Fill in the real disk IDs before running disko or nixos-install.
# Find them on the server with: ls -la /dev/disk/by-id/ata-VK1920GFDKL_*
let
  ssd0 = "/dev/disk/by-id/ata-VK1920GFDKL_S26CNX0H800763";
  ssd1 = "/dev/disk/by-id/ata-VK1920GFDKL_S26CNXRHB00273";
  ssd2 = "/dev/disk/by-id/ata-VK1920GFDKL_S26CNXRHB00659";
  ssd3 = "/dev/disk/by-id/ata-VK1920GFDKL_S26CNXRHB00673";

  zfsDisk = device: {
    inherit device;
    type = "disk";
    content = {
      type = "gpt";
      partitions.zfs = {
        size = "100%";
        content = { type = "zfs"; pool = "nest"; };
      };
    };
  };
in
{
  disko.devices = {
    disk = {
      ssd0 = zfsDisk ssd0;
      ssd1 = zfsDisk ssd1;
      ssd2 = zfsDisk ssd2;
      ssd3 = zfsDisk ssd3;
    };

    zpool.nest = {
      type = "zpool";
      # All 4 disks form a single RAIDZ1 vdev (1 parity disk, ~5.7 TB usable)
      mode = "raidz1";

      options = {
        ashift = "12";
        autotrim = "on";
      };

      rootFsOptions = {
        compression = "lz4";
        atime = "off";
        xattr = "sa";
        dnodesize = "auto";
        "com.sun:auto-snapshot" = "false";
      };

      datasets = {
        backups = {
          type = "zfs_fs";
          options."com.sun:auto-snapshot" = "true";
        };
      };
    };
  };
}
