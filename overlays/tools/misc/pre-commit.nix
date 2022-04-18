_final: prev: {
  pre-commit = prev.pre-commit.overrideAttrs (_old: {
    doCheck = false;

    checkInputs = [];
  });
}
