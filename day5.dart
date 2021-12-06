import 'dart:io';

bool isStraightLine(List<int> orig, List<int> dest) {
  return orig[0] == dest[0] || orig[1] == dest[1];
}

bool isDiagonalLine(List<int> orig, List<int> dest) {
  return ((orig[1] - dest[1]).abs() == (orig[0] - dest[0]).abs());
}

void traverse(Map<String, int> seen, List<int> coord1, List<int> coord2) {
  if (coord1[0] != coord2[0]) {
    //move horizontal
    for (int i = 0; i.abs() <= (coord2[0] - coord1[0]).abs(); i += (coord2[0] - coord1[0]).sign) {
      String key = "${coord1[0] + i},${coord1[1]}";
      seen[key] = (seen[key] ?? 0) + 1;
    }
  } else if (coord1[1] != coord2[1]) {
    //move vertical
    for (int i = 0; i.abs() <= (coord2[1] - coord1[1]).abs(); i += (coord2[1] - coord1[1]).sign) {
      String key = "${coord1[0]},${coord1[1] + i}";
      seen[key] = (seen[key] ?? 0) + 1;
    }
  }
}

void traverseDiag(Map<String, int> seen, List<int> coord1, List<int> coord2) {
  int x_step = (coord2[0] - coord1[0]).sign;
  int y_step = (coord2[1] - coord1[1]).sign;
  for (int i = 0; i <= (coord2[1] - coord1[1]).abs(); i += 1) {
    String key = "${coord1[0] + i * x_step},${coord1[1] + i * y_step}";
    seen[key] = (seen[key] ?? 0) + 1;
  }
}

void main() {
  List<List<String>> inputs = File('day5.txt').readAsLinesSync().map((e) => e.split(' -> ')).toList();
  Map<String, int> grid_count = Map<String, int>();

  // Part 1
  for (List<String> input in inputs) {
    List<int> orig = input[0].split(',').map((e) => int.parse(e)).toList();
    List<int> dest = input[1].split(',').map((e) => int.parse(e)).toList();
    if (isStraightLine(orig, dest)) {
      traverse(grid_count, orig, dest);
    }
  }

  int count = 0;
  for (String key in grid_count.keys) {
    if ((grid_count[key] ?? 0) > 1) {
      count++;
    }
  }
  print(count);

  // Part 2. I could have refactored this so that a lot of the code for
  // part 1 also started on part 2, but I'm already behind on AoC... so we'll
  // go for the messier, but likely less time-consuming way to implement.
  for (List<String> input in inputs) {
    List<int> orig = input[0].split(',').map((e) => int.parse(e)).toList();
    List<int> dest = input[1].split(',').map((e) => int.parse(e)).toList();
    if (isDiagonalLine(orig, dest)) {
      traverseDiag(grid_count, orig, dest);
    }
  }

  count = 0;
  for (String key in grid_count.keys) {
    if ((grid_count[key] ?? 0) > 1) {
      count++;
    }
  }
  print(count); //part 2
}
