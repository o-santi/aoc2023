{ lib,
  parse-int,
  expect,
  parse-many,
  interspersed,
  debug,
  ...
} :
let
  input = builtins.readFile ./input;
  parse-card = state:
    let state1 = expect "Card" state;
        ws = parse-many (expect " ") state1;
        card-id = parse-int ws;
        state2 = expect ":" card-id;
        winning-numbers = parse-many (s: parse-int (parse-many (expect " ") s)) state2;
        bar = expect " |" winning-numbers;
        scratched-numbers = parse-many (s: parse-int (parse-many (expect " ") s)) bar;
    in
      scratched-numbers // {
        result = {
          type = "ok";
          val = { id = card-id.result.val; winning = winning-numbers.result.val; scratched = scratched-numbers.result.val; };
        };
      };
  cards = interspersed parse-card (expect "\n")  { start = 0; inherit input; };
  pow = a: b: if a == 0 then 1 else b * (pow (a - 1) b);
in
{
  fst = lib.lists.foldl (pile: {winning, scratched, ...}:
    let matched = builtins.length (lib.lists.intersectLists scratched winning);
        points = if matched > 0 then pow (matched - 1) 2 else 0;
    in
      pile + points
  ) 0 cards.result.val;
  snd =
    let
      card-id-set = lib.lists.foldl (acc: id: acc // {"${builtins.toString id}" = 1; }) {} (map ({id, ...}: id) cards.result.val);
      matched-per-card = lib.lists.foldl (pile: {winning, scratched, id}:
          let matched = builtins.length (lib.lists.intersectLists scratched winning); in
          pile // { "${builtins.toString id}" = matched; }) {} cards.result.val;
        count = card-id: card-counts: 
          if (debug card-counts) == {} then 0 else
            let
              tag = builtins.toString card-id;
              matched = ({ "${tag}" = 0; } // matched-per-card)."${tag}";
              new-cards = lib.lists.range (card-id + 1) (card-id + matched);
              card-count = card-counts."${tag}";
              new-cards-set = lib.lists.foldl (acc: id:
                let i = builtins.toString id;
                    i-count = ({ "${i}" = 0; } // acc)."${i}"; in
                  acc // { "${i}" = i-count + card-count;}
              ) card-counts new-cards;
          in
            card-count + count (card-id + 1) (lib.attrsets.filterAttrs (n: v: n != "${tag}") new-cards-set);
    in
      count 1 card-id-set;
}
