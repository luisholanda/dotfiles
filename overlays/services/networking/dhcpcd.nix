_final: prev: {
  dhcpcd = prev.dhcpcd.override {enablePrivSep = false;};
}
