import 'dart:convert';
import 'dart:io';

void main() {
  List<String> polymer;
  Map<String, String> pair_rules = Map();
  List<String> inputs = File('day14.txt').readAsLinesSync();

  // Part 1. This is straightforward implementation of the problem. Keep a list
  // of letters...
  polymer = inputs[0].split('');
  for (int i = 2; i < inputs.length; i++) {
    List pair = inputs[i].split(' -> ');
    pair_rules[pair[0]] = pair[1];
  }

  // ...and input the new elements according to the rules in the problem...
  Map<String, int> counts;
  for (int i = 0; i < 10; i++) {
    List<String> new_polymer = List.from(polymer);
    for (int j = 0; j < polymer.length - 1; j++) {
      String insert = pair_rules[polymer.sublist(j, j + 2).join('')]!;
      new_polymer.insert(j * 2 + 1, insert);
    }
    polymer = new_polymer;
    counts = Map();
    polymer.forEach((i) => counts[i] = (counts[i] ?? 0) + 1);
  }

  // ...then count the letters in the that list and do some math for the answer.
  counts = Map();
  polymer.forEach((i) => counts[i] = (counts[i] ?? 0) + 1);
  int? max, min;
  counts.keys.forEach((key) {
    max = max == null ? counts[key] : (counts[key]! > max! ? counts[key] : max);
    min = min == null ? counts[key] : (counts[key]! < min! ? counts[key] : min);
  });
  print(max! - min!);

  //Part 2

  //Of course, this was not fast enough for part 2. So we re-implemented with Too Many Maps.
  //blank_polymer_counts may be unnecessary, and belies the fact that it's not quite clear to me
  //what operator= is doing with Maps. Needless to say: on vacation, not going to dive deper rn.

  // The approach is basically the same as the fish problem from day six: we don't need to keep
  // track of the full lineage of the mapping (like the full lineage of fishes). We just know
  // that, for example, the code CH will result in one additional B to the string and in the
  // codes CB and BH. So we keep track of the number of CHs in the string (and CBs and BHs)
  // as well as just the number of letters themselves (as counting the CB + BH would double-count
  // added Bs). So let's walk through it.
  Map<String, int> polymer_counts = Map();
  Map<String, String> polymer_to_letter = Map();
  Map<String, int> letter_counts = Map();
  Map<String, List<String>> new_polymer_rules = Map();
  Map<String, int> blank_polymer_counts = Map();

  // So we set up the lists. We need to track the polymer_counts, a blank_count
  // (because operator= on Maps was doing things I don't understand). We also
  // need to know which polymer pair leads to what letter (polymer_to_letter)
  // and which new polymer pairs (new polymer rules).
  for (int i = 2; i < inputs.length; i++) {
    List<String> pair_rule = inputs[i].split(' -> ');
    polymer_counts[pair_rule[0]] = 0;
    blank_polymer_counts = Map.from(polymer_counts);
    polymer_to_letter[pair_rule[0]] = pair_rule[1];
    new_polymer_rules[pair_rule[0]] = [
      pair_rule[0].substring(0, 1) + pair_rule[1],
      pair_rule[1] + pair_rule[0].substring(1, 2)
    ];
    letter_counts[pair_rule[0].substring(0, 1)] = 0;
    letter_counts[pair_rule[0].substring(1, 2)] = 0;
    letter_counts[pair_rule[1]] = 0;
  }

  //Initialize the letter_counts with the starting string (eg NNCB)
  polymer = inputs[0].split('');
  polymer.forEach((letter) => letter_counts[letter] = (letter_counts[letter] ?? 0) + 1);

  // Phase 0 of keeping track of the polymer_counts
  for (int i = 0; i < polymer.length - 1; i++) {
    polymer_counts[polymer.sublist(i, i + 2).join('')] = polymer_counts[polymer.sublist(i, i + 2).join('')]! + 1;
  }

  //Phase 1-40: For each polymer pair (CB), set the new pair counts to the amount of current CB
  // and also add to the letter counts the letter CB adds. So if CB adds H and we start the
  // phase with 10 CBs, we end up with 0 CB (because the H goes in between), 10 CH, 10 HB, and
  // 10 additional Hs.
  for (int i = 0; i < 40; i++) {
    Map<String, int> new_polymer_counts = Map.from(blank_polymer_counts);
    polymer_counts.keys.forEach((rule) {
      int count = polymer_counts[rule]!;
      letter_counts[polymer_to_letter[rule]!] = letter_counts[polymer_to_letter[rule]]! + count;
      new_polymer_rules[rule]!.forEach((mapping) {
        new_polymer_counts[mapping] = new_polymer_counts[mapping]! + count;
      });
    });
    polymer_counts = Map.from(new_polymer_counts);
  }

  // Now just get the max and min letter counts.
  max = null;
  min = null;
  letter_counts.keys.forEach((key) {
    max = max == null ? letter_counts[key] : (letter_counts[key]! > max! ? letter_counts[key] : max);
    min = min == null ? letter_counts[key] : (letter_counts[key]! < min! ? letter_counts[key] : min);
  });
  print(max! - min!);
}
