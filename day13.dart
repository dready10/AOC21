import 'dart:io';

void horizontal_fold(List<List<int>> dots, int along) {
  dots.forEach((dot) {
    if (dot[1] > along) {
      dot[1] = along - (dot[1] - along);
    }
  });
}

void vertical_fold(List<List<int>> dots, int along) {
  dots.forEach((dot) {
    if (dot[0] > along) {
      dot[0] = along - (dot[0] - along);
    }
  });
}

int count_unique(List<List<int>> dots) {
  Map<int, Set> c = Map();
  dots.forEach((dot) => c[dot[0]] = Set());
  dots.forEach((dot) => c[dot[0]]!.add(dot[1]));

  int total = 0;
  c.keys.forEach((element) {
    total += c[element]!.length;
  });
  return total;
}

List<int> get_size(List<List<int>> dots) {
  int maxX = 0, maxY = 0;
  dots.forEach((dot) {
    maxX = maxX > dot[0] ? maxX : dot[0];
    maxY = maxY > dot[1] ? maxY : dot[1];
  });
  return [maxX, maxY];
}

void print_paper(List<List<int>> dots) {
  List<int> size = get_size(dots);
  List<String> row = List.from(Iterable<String>.generate(size[0] + 1, (a) => '.'));
  List<List<String>> s = [];
  for (int i = 0; i <= size[1]; i++) {
    s.add(List.from(row));
  }

  dots.forEach((dot) => {s[dot[1]][dot[0]] = 'X'});

  s.forEach((row) => print(row.join('')));
}

void main() {
  List<String> inputs = File('day13.txt').readAsLinesSync();
  List<List<int>> coordinates = [];
  bool counted_step1 = false;
  inputs.forEach((input) {
    if (input == "") return;
    if (input.substring(0, 1) != 'f') {
      coordinates.add(input.split(',').map((e) => int.parse(e)).toList());
    } else if (input.substring(11, 12) == 'x') {
      vertical_fold(coordinates, int.parse(input.substring(13)));
      if (!counted_step1) {
        counted_step1 = true;
        print(count_unique(coordinates));
      }
    } else if (input.substring(11, 12) == 'y') {
      horizontal_fold(coordinates, int.parse(input.substring(13)));
      if (!counted_step1) {
        counted_step1 = true;
        print(count_unique(coordinates));
      }
    }
  });
  print_paper(coordinates);
}
