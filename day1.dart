import 'dart:io';

double average(Iterable<num> nums) {
  return nums.fold<num>(0, (a, b) => a + b) / nums.length;
}

int count_increases(Iterable<num> depths) {
  num previous_depth = depths.first;
  int depth_increases = 0;
  for (num depth in depths) {
    if (depth > previous_depth) depth_increases++;
    previous_depth = depth;
  }
  return depth_increases;
}

void main() async {
  File input = new File('day1.txt');
  List<String> lines = await input.readAsLines();
  List<int> depths = lines.map((e) => int.parse(e)).toList();

  // part 1
  print(count_increases(depths));

  // part 2

  // this line of code creates a list of the moving 3-depth-window average
  Iterable<double> depth_windows = Iterable.generate(depths.length - 2, (i) => average(depths.sublist(i, i + 3)));
  print(count_increases(depth_windows));
}
