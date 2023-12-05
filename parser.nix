lib: rec {
  inherit lib;
  debug = e: (builtins.trace (builtins.toJSON e) e);
  parse-int = { start, input, ...} @ state:
    let helper = curr:
          let char = (builtins.substring curr 1 input); in
          if char == "" then [] else 
            let digit = lib.strings.charToInt char - 48; in
            if (digit >= 0) && (digit < 10) then
              [digit] ++ helper (curr + 1)
            else
              [];
        digits = helper start;
        result = if digits != [] then
          { result = {
              type = "ok";
              val = lib.lists.foldl (num: digit: (10 * num) + digit) 0 digits;
            };
          }
         else
           { result = {
               type = "fail";
               reason = "Expected int.";
             }; };
    in
      state // { start = start + (builtins.length digits); } // result;
  expect = word: { start, input, ... } @ state:
    let word-len = builtins.stringLength word;
        subs = builtins.substring start word-len input;
        result = if word == subs
                 then { start = start + word-len; result = { type = "ok"; val = word; }; }
                 else { result = { type = "fail"; reason = "Expected '${word}' but got '${subs}'"; }; };
    in
      state // result;
  parse-many = p: state:
    let try = p state; in
    if try.result.type == "ok" then
      let others = parse-many p (state // { start = try.start; }); in
      state // {
        start = others.start;
        result = { type="ok"; val = [try.result.val] ++ others.result.val; };
      } 
    else
      state // { result = { type = "ok"; val = []; }; };
  either = parsers: state:
    let tried = lib.lists.foldl (st: p:
          if st.tag == "none" then
            let res = p state; in
            if (res.result.type == "ok") then
              { tag = "some"; value = res; }
            else
              st // { result = {
                        type = "fail";
                        reason = ({ fail = []; } // st).fail ++ [ res.fail ];
                      }; }
          else
            st
        ) { tag = "none";} parsers;
    in
      if tried.tag == "some" then
        tried.value
      else
        state // { result = { type = "fail"; reason = tried.result.reason;}; };
}

