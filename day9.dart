import 'dart:io';

Iterable<List<int>> neighbors(int row, int col, int max_rows, int max_cols) {
  List<List<int>> neighbors = [];
  neighbors.add([row - 1, col]);
  neighbors.add([row + 1, col]);
  neighbors.add([row, col - 1]);
  neighbors.add([row, col + 1]);
  return neighbors.where((coord) => coord[0] >= 0 && coord[0] < max_rows && coord[1] >= 0 && coord[1] < max_cols);
}

// A recursive function that adds non-9 neighbors to the basin. If we see a new point, we recurse on that point.
// Sets make this much cleaner.
Set fill_basin(List point, List cave_map, {Set? basin}) {
  int max_rows = cave_map.length, max_cols = cave_map[0].length;
  if (basin == null) basin = {};
  basin.add(point[0] * 100 + point[1]);
  for (List neighbor in neighbors(point[0], point[1], max_rows, max_cols).toList()
    ..retainWhere((e) => cave_map[e[0]][e[1]] != 9)) {
    if (!basin.contains(neighbor[0] * 100 + neighbor[1])) fill_basin(neighbor, cave_map, basin: basin);
  }
  return basin;
}

void main() {
  List<List<int>> cave_map =
      File('day9.txt').readAsLinesSync().map((line) => line.split('').map((e) => int.parse(e)).toList()).toList();

  List<List<int>> low_points = [];
  int max_rows = cave_map.length;
  int max_cols = cave_map[0].length;

  // Iterate through each cell, looking at the neighbor for each one. If there is
  // a neighbor that is of lower value than the cell we are looking at, this is
  // not a low point, so move to the next cell. If we look at all neighbors and
  // haven't moved to the next neighbor, we are at a low point, so add it to the list.
  for (int row = 0; row < cave_map.length; row++) {
    next_neighbor:
    for (int col = 0; col < cave_map[0].length; col++) {
      for (List neighbor in neighbors(row, col, max_rows, max_cols)) {
        if (cave_map[row][col] >= cave_map[neighbor[0]][neighbor[1]]) continue next_neighbor;
      }
      low_points.add([row, col]);
    }
  }
  // Dart's string interpolation is so, so vastly better than python's.
  print("Risk level sum: ${low_points.map((e) => cave_map[e[0]][e[1]] + 1).reduce((a, b) => a + b)}");

  // Part 2
  List basins = [];
  for (List point in low_points) {
    Set basin = fill_basin(point, cave_map);
    basins.add(basin);
  }
  basins.sort((a, b) => (a.length.compareTo(b.length)));
  basins = basins.reversed.toList();
  print("Product of the size of the three largest basins: ${basins[0].length * basins[1].length * basins[2].length}");
}
