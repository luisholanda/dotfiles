{
  pkgs,
  ...
}: {
  # The default options don't give us enough control over the rules and types.
  config.services.ananicy = {
    enable = true;
    rulesProvider = pkgs.ananicy-cpp-rules;
  };
}
