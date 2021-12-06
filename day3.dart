import 'dart:io';

int most_common_digit_in_position(List<List<int>> codes, position) {
  int ones_at_position = 0;
  codes.forEach((code) => ones_at_position += code[position]);
  return ones_at_position >= codes.length / 2 ? 1 : 0;
}

int least_common_digit_in_position(List<List<int>> codes, position) {
  int ones_at_position = 0;
  codes.forEach((code) => ones_at_position += code[position]);
  return ones_at_position < codes.length / 2 ? 1 : 0;
}

void main() {
  // Part 1
  // My goal in part 1 was to get this as close to a one-liner as possible. Not
  // too terribly successful, but also kind of not mad at it?

  // Basically: "Read in all the lines, put them into a list of integer codes,
  // reduce the list by summing vertically across the codes" (which there
  // doesn't seem to be a built in function for, oddly?), get the most common
  // digit, and than parse that into an int.
  int total_codes = 1;
  Iterable<String> gamma = File('day3.txt')
      .readAsLinesSync()
      .map((diagnostic) => diagnostic.split('').map((code) => int.parse(code)).toList())
      .reduce((ones, code) {
    total_codes++;
    for (int i = 0; i < ones.length; i++) ones[i] += code[i];
    return ones;
  }).map((code) => code > total_codes / 2 ? '1' : '0');
  int epsilon = int.parse(gamma.map((e) => e == '1' ? '0' : '1').join(''), radix: 2);
  print(int.parse(gamma.join(''), radix: 2) * epsilon);

  //part 2
  // Ok, so I have a lot of duplicate code here because of my goal up front. Obviously
  // doing this only once and storing the results somewhere is better.
  List<List<int>> oxy_codes = File('day3.txt')
      .readAsLinesSync()
      .map((diagnostic) => diagnostic.split('').map((code) => int.parse(code)).toList())
      .toList();

  // Like so.
  List<List<int>> co2_codes = List.from(oxy_codes);

  // Ok, so now we figure out which digit to retain (1 or 0) with the most_common
  // and least_common helper function and then retain them, then iterate forward.
  int check_position = 0;
  while (oxy_codes.length > 1 || co2_codes.length > 1) {
    int retain_oxy = most_common_digit_in_position(oxy_codes, check_position);
    int retain_co2 = least_common_digit_in_position(co2_codes, check_position);

    oxy_codes =
        oxy_codes.length > 1 ? oxy_codes.where((element) => element[check_position] == retain_oxy).toList() : oxy_codes;
    co2_codes =
        co2_codes.length > 1 ? co2_codes.where((element) => element[check_position] == retain_co2).toList() : co2_codes;

    check_position++;
  }

  // And then just get the result.
  print(int.parse(oxy_codes[0].join('').toString(), radix: 2) * int.parse(co2_codes[0].join('').toString(), radix: 2));
}
