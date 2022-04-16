final: prev: {
  pre-commit = prev.pre-commit.overrideAttrs (old: {
    doCheck = false;

    checkInputs = [];
  });
}
