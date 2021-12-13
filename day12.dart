import 'dart:io';

int GLOBAL_COUNT = 0;

bool is_big(String cave) {
  return cave.substring(0, 1).toUpperCase() == cave.substring(0, 1);
}

void list_paths(Set<String> caves, Map<String, List<String>> connections, String current_cave, List<String> path,
    Set<String> visited_caves, bool is_part2, bool small_visited_twice) {
  if (current_cave == 'end') {
    GLOBAL_COUNT++;
    return;
  }

  List possible_paths = connections[current_cave]!;
  possible_paths.forEach((next_cave) {
    if (next_cave == 'start') return;
    List<String> path_copy = List.from(path);
    Set<String> visited_copy = Set.from(visited_caves);

    if (!is_big(next_cave)) {
      if (!visited_caves.contains(next_cave)) {
        path_copy.add(next_cave);
        visited_copy.add(next_cave);
        list_paths(caves, connections, next_cave, path_copy, visited_copy, is_part2, small_visited_twice);
      } else if (is_part2 && !small_visited_twice) {
        path_copy.add(next_cave);
        visited_copy.add(next_cave);
        list_paths(caves, connections, next_cave, path_copy, visited_caves, is_part2, true);
      }
    } else {
      path_copy.add(next_cave);
      list_paths(caves, connections, next_cave, path_copy, visited_caves, is_part2, small_visited_twice);
    }
  });
}

void main() {
  //I am mostly ashamed of this code, but it works and I am teeechnically on vacation, so I'm going to let is slide.
  List<String> input = File('day12.txt').readAsLinesSync();
  Map<String, List<String>> connections = Map();
  Set<String> caves = Set();
  input.forEach((connection) {
    List cnx = connection.split('-');
    caves
      ..add(cnx[0])
      ..add(cnx[1]);
  });
  caves.forEach((cave) => connections[cave] = []);
  input.forEach((connection) {
    List cnx = connection.split('-');
    connections[cnx[0]]!.add(cnx[1]);
    connections[cnx[1]]!.add(cnx[0]);
  });

  list_paths(caves, connections, 'start', ['start'], {'start'}, false, false);
  print(GLOBAL_COUNT);
  GLOBAL_COUNT = 0;
  list_paths(caves, connections, 'start', ['start'], {'start'}, true, false);
  print(GLOBAL_COUNT);
}
