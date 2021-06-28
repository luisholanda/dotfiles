{ lib, ... }:
with builtins;
with lib;
rec {
  # Convert an attribute map to a list.
  # attrsToList :: attrs -> [{ name = any; value = any; }]
  attrsToList = attrs:
    mapAttrsToList (name: value: { inherit name value; }) attrs;

  # Maps and filters attributes
  # mapFilterAttrs :: (name -> value -> bool)
  #                -> (name -> value -> { name = any; value = any; })
  #                -> attrs
  #                -> attrs
  mapFilterAttrs = pred: f: attrs: filterAttrs pred (mapAttrs' f attrs);

  # Generates an attribute set by mapping a function over a list of values.
  # genAttrs' :: [any] -> (value -> { name = any; value = any; }) -> attrs
  genAttrs' = values: f: listToAttrs (map f values);

  # Check if any attribute in a set satisfies a predicate.
  # anyAttrs :: (name -> value -> bool) -> attrs -> bool
  anyAttrs = pred: attrs: any (attr: pred attr.name attr.value) (attrsToList attrs);

  # Count the number of attributes in a set that satisfies a predicate.
  # countAttrs :: (name -> value -> bool) -> attrs -> integer
  countAttrs = pred: attrs: count(attr: pred attr.name attr.value) (attrsToList attrs);
}
