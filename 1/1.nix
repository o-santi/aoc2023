lib:
{ fst =
    let input = builtins.readFile ./input;
        solve = (input:
          let lines = lib.splitString "\n" input; in
          builtins.foldl' (sum: line:
            let chars = lib.stringToCharacters line;
                rest = builtins.foldl' (acc: c:
                  let number = (lib.strings.charToInt c) - 48; in
                  if number >= 0 && number < 10 then
                    { first = number; } // acc // { last = number; }
                  else acc
                ) { } chars;
            in
              sum + (10 * rest.first) + rest.last
          ) 0 lines);
    in
      solve input;
  snd =
    let input = builtins.readFile ./input;
        rec-number = { rest, ...} @ state :
          let strings = {
                "1" = 1; "2" = 2; "3" = 3; "4" = 4; "5" = 5; "6" = 6; "7" = 7; "8" = 8; "9" = 9;
                one = 1; two = 2; three = 3; four = 4; five = 5; six = 6; seven = 7; eight = 8; nine = 9;
              };
              max = a: b: if a > b then a else b;
              matching-strings = lib.attrsets.mapAttrsToList (prefix: number: (
                if lib.strings.hasPrefix prefix rest then
                  { first = number; } // state //
                  { rest = builtins.substring (max ((builtins.stringLength prefix) -1) 1) (builtins.stringLength rest) rest;
                    last = number;
                  }
                else {})
              ) strings;
              next-state = builtins.foldl' (acc: match: acc // match) (state // { rest = builtins.substring 1 (builtins.stringLength rest) rest; }) matching-strings;
          in
            if rest == "" then state else (rec-number ( next-state ));
        solve = (input:
          let lines = lib.splitString "\n" input; in
          builtins.foldl' (acc: line:
            let final = rec-number { rest = line; }; in
            acc + (10 * final.first) + final.last
          ) 0 lines);
    in
}

