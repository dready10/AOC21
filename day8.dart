import 'dart:convert';
import 'dart:io';

Map<String, String> decode_displays(List displays) {
  Map<String, String> results = Map();
  // Should be self explanatory. 'one' is the only display with 2 segments, etc. .first is
  // there because .where returns an iterable instead of an element, but because length == 2
  // only returns one result, we can just grab that first one and .join it to get 'age' => '7'.
  String one = displays.where((element) => element.length == 2).first.join('');
  String four = displays.where((element) => element.length == 4).first.join('');
  String seven = displays.where((element) => element.length == 3).first.join('');
  String eight = displays.where((element) => element.length == 7).first.join('');

  //A three has five segments and fully contains one's segments; the other five-segment inputs don't.
  String three = displays
      .where((element) => element.length == 5 && element.contains(one[0]) && element.contains(one[1]))
      .first
      .join('');
  //Same for six (but with six segments).
  String six = displays
      .where((element) => element.length == 6 && !(element.contains(one[0]) && element.contains(one[1])))
      .first
      .join('');

  //A nine has six sigments and fully contains a four while the other six-segment displays do not.
  String nine = displays
      .where((element) =>
          element.length == 6 &&
          (element.contains(four[0]) &&
              element.contains(four[1]) &&
              element.contains(four[2]) &&
              element.contains(four[3])))
      .first
      .join('');

  //Zero is six segments not a three or nine.
  String zero = displays
      .where(
          (element) => element.length == 6 && (element..sort()).join('') != six && (element..sort()).join('') != nine)
      .first
      .join('');

  //Five is a five-segment display that is fully contained by six.
  String five = displays
      .where((element) =>
          element.length == 5 &&
          six.contains(element[0]) &&
          six.contains(element[1]) &&
          six.contains(element[2]) &&
          six.contains(element[3]) &&
          six.contains(element[4]))
      .first
      .join('');
  //Two is a five-segment display that's not a five or three.
  String two = displays
      .where(
          (element) => element.length == 5 && (element..sort()).join('') != five && (element..sort()).join('') != three)
      .first
      .join('');

  results[zero] = '0';
  results[one] = '1';
  results[two] = '2';
  results[three] = '3';
  results[four] = '4';
  results[five] = '5';
  results[six] = '6';
  results[seven] = '7';
  results[eight] = '8';
  results[nine] = '9';

  return results;
}

void main() {
  int part1total = 0;
  int part2total = 0;

  //Open and read the file line by line.
  File('day8.txt').openRead().transform(const Utf8Decoder()).transform(const LineSplitter()).listen((line) {
    //The order of a/b/c/d/etc in either the display mapping (LHS of |) or the display (RHS of |) does not matter.
    //All that matters is the characters therein. So, we can just sort all our inputs, decode them,
    //and then map from the sorted string to the integer value.

    //For example, if the display mapping is 'gae' we know it's a seven. So instead of trying to map all the
    //permutations of gae (age, ega, etc) to a seven, it's simpler to store the sorted mapping and then sort
    //the displays. Simplifies everything.

    //So in the two lines of code below we end up with a list of lists of sorted elements,
    //eg: input 'gae ecabf edagc' is represented as [[a, e, g], [a, b, c, e, f], [a, c, d, e, g]]
    List<List<String>> display_mapping = line.split(' | ')[0].split(' ').map((e) => e.split('')..sort()).toList();
    List<List<String>> displays = line.split(' | ')[1].split(' ').map((e) => e.split('')..sort()).toList();

    //Part 1
    part1total += displays.where((element) => [2, 3, 4, 7].contains(element.length)).length;

    //Part 2
    Map<String, String> mapped_displays = decode_displays(display_mapping);
    part2total += int.parse(displays.map((e) => mapped_displays[e.join('')]).join(''));
  }).onDone(() {
    print('Number of digits equal to one, four, seven, or eight: $part1total');
    print('Sum of all displays: $part2total');
  });
}
