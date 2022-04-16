{pkgs, ...}: {
  config.environment.systemPackages = [pkgs.brightnessctl];
}
