{ lib, parse-int, expect, parse-many, ... }:
let
  input = builtins.readFile ./input;
  debug = e: x: (builtins.trace (builtins.toJSON e) x);
  parse-color = s0:
    let s1 = parse-int s0;
        count = s1.result;
        s2 = expect " " s1;
        subs = builtins.substring s2.start 5 input; in
      s0 // s1 // (if lib.strings.hasPrefix "red" subs then
        { start = s2.start + 3; result = { red = count; }; }
      else if lib.strings.hasPrefix "blue" subs then
        { start = s2.start + 4; result = { blue = count; }; }
      else if lib.strings.hasPrefix "green" subs then
        { start = s2.start + 5; result = { green = count; }; }
      else { fail = "Unexpected color";}) ;
  parse-set = s0:
    let s1 = expect " " s0;
        s2 = parse-color s1; in
      if (s2 ? "fail") || (s1 ? "fail") then
        s0 // { fail = s1.fail; }
      else
        let next = (builtins.substring s2.start 1 input); in
        if next == "," then
          let colors = parse-set (s2 // { start = s2.start + 1; }); in
          if !(colors ? "fail") then 
            { start = colors.start; result = s2.result // colors.result; }
          else
            s2 // {fail = true; }
        else if next == ";" || next == "\n" || next == "" then 
          { start = s2.start + 1; result = s2.result; }
        else
          s0 // { fail = true; };
  parse-game = s0:
    let s1 = expect "Game " s0; in
    if (s1 ? "fail") then
      s0 // { fail = s1.fail; } else
                let
                  s2 = parse-int s1; game-id = s2.result;
                  s3 = expect ":" s2;
                  s4 = parse-many parse-set s3;
                in
                  { start = s4.start; result = { id = game-id; sets = s4.result; }; };
  games = (parse-many parse-game { inherit input; start = 0;  }).result;
in 
{ fst = let    
    possible = { red = 12; green = 13; blue = 14; };
    solution = lib.lists.foldl  (sum: { id, sets }:
      let valid = lib.lists.all ({red ? 0, green ? 0, blue ? 0}:
            (green <= possible.green) && (blue <= possible.blue) && (red <= possible.red)) sets; in
        if valid then
          sum + id
        else
          sum
    ) 0 (debug games games);
  in
    solution;
  snd = lib.lists.foldl (sum: {id, sets}:
    let
      max = a: b: if a > b then a else b;
      minimum = lib.lists.foldl ( min:
        {red ? 0, green ? 0, blue ? 0}: {
          red = max min.red red;
          green = max min.green green;
          blue = max min.blue blue;
        })
        { red = 0; blue=0; green= 0; } sets;
      power = minimum.red * minimum.green * minimum.blue;
    in
      sum + power) 0 games;
}
