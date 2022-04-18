{config, ...}: {
  config.user.home.programs.htop = {
    enable = true;
    settings = {
      cpu_count_from_zero = true;
      delay = 5;
      detailed_cpu_time = true;
      highlight_base_name = true;
      shadow_other_users = true;
      show_cpu_frequency = true;
    };
  };
}
