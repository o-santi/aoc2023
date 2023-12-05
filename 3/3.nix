{ lib,
  ...
}:
let 
  input = builtins.readFile ./input;
  to-int = c: lib.strings.charToInt c - 48;
  is-digit = c: (to-int c) < 10 && (to-int c) >= 0;
  digits-to-int = ds: lib.lists.foldl (d: sum: 10*d + sum) 0 ds;
  chars = lib.strings.stringToCharacters input; 
  items = lib.lists.foldl (state: char:
    if is-digit char then
      let s = { parsing = { inherit (state) loc; digits = []; }; } // state; in
      s // { loc = { col = state.loc.col + 1; inherit (state.loc) line;}; 
             parsing = { inherit (s.parsing) loc; digits = s.parsing.digits ++ [(to-int char)]; }; }
    else
      let new-state = if (state ? "parsing") then {
            inherit (state) loc tokens;
            numbers = state.numbers ++ [ { val = state.parsing.digits;
                                           x = state.parsing.loc.col ;
                                           y = state.parsing.loc.line; } ];
          } else state; in
        if char == "\n" then
          new-state // {
            loc = { line = new-state.loc.line + 1; col = 0;};
          }
        else if char == "." then
          new-state // {
            loc = { inherit (new-state.loc) line; col = new-state.loc.col + 1; };
          }
        else
          let token = { x = new-state.loc.col; y = new-state.loc.line; }; in
          new-state // {
            tokens = new-state.tokens ++ [ token ];
            loc = { inherit (new-state.loc) line; col = new-state.loc.col + 1; };
          }) { loc = { line = 0; col = 0; }; numbers = []; tokens = [];} chars;
in
{
  fst = lib.lists.foldl (sum: {val, x, y}:
    let near-token = len: t: let x-diff = t.x - x; y-diff = t.y - y; in
                             (x-diff <= len) && (x-diff >= -1) && (y-diff <= 1) && (y-diff >= -1); in
      if (lib.lists.any (near-token (builtins.length val)) items.tokens) then
        sum + (digits-to-int val)
      else
        sum
  ) 0 items.numbers;
  snd = lib.lists.foldl (sum: token:
    let near-token = {x, y, val}: let x-diff = token.x - x; y-diff = token.y - y; len = builtins.length val; in
                             (x-diff <= len) && (x-diff >= -1) && (y-diff <= 1) && (y-diff >= -1); in
      let near-numbers = (lib.lists.foldl (s: {val, ...}@number: if (near-token number) then s ++ [(digits-to-int val)] else s) [] items.numbers); in
      if (builtins.length near-numbers) == 2 then
        sum + (builtins.head near-numbers * (builtins.head (builtins.tail near-numbers)))
      else
        sum) 0 items.tokens;
}
