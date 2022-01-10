import 'dart:collection';
import 'dart:io';

//Right now to go from (int, int) => int I just use MAX_MAZE_SIZE*i + j.
//Works for this problem, not fully generalizable.
const int MAX_MAZE_SIZE = 1000;

// Part 2 increases map size by 5x. If it were 10x, the below would be 10.
const int MULTIPLIED_MAP_SIZE = 5;

int mapCoordinate(int x, int y) {
  return x * MAX_MAZE_SIZE + y;
}

int getYCoord(int coord) {
  return coord % MAX_MAZE_SIZE;
}

int getXCoord(int coord) {
  return (coord - coord % MAX_MAZE_SIZE) ~/ MAX_MAZE_SIZE;
}

List<List<int>> make_big_maze(List<List<int>> maze) {
  List<List<int>> big_maze = [];
  for (List<int> row in maze) {
    List<int> new_row = List.from(row);
    for (int i = 1; i < MULTIPLIED_MAP_SIZE; i++) {
      new_row.addAll(List.from(row.map((e) => e + i > 9 ? e + i - 9 : e + i)));
    }
    big_maze.add(new_row);
  }

  int height = big_maze.length;
  for (int i = 1; i < MULTIPLIED_MAP_SIZE; i++) {
    big_maze.addAll(big_maze.sublist(0, height).map((r) => r.map((e) => (e + i) > 9 ? e + i - 9 : (e + i)).toList()));
  }
  return big_maze;
}

//Decided I would do this without looking up any algorithms. I am certain that there is a faster
//way to do this, but part 2 finishes in like 2 seconds anyway.
int bfs_traverse(List<List<int>> maze, Map<int, int> scores, ListQueue<List<int>> nodes_to_visit) {
  int maxX = maze[0].length, maxY = maze.length, newX, newY;
  List<List<int>> directions = [
    [0, 1],
    [1, 0],
    [0, -1],
    [-1, 0]
  ];

  while (nodes_to_visit.isNotEmpty) {
    int x = nodes_to_visit.first[0];
    int y = nodes_to_visit.first[1];
    nodes_to_visit.removeFirst();

    for (List<int> movement in directions) {
      newX = x + movement[0];
      newY = y + movement[1];
      if (newX >= maxX || newY >= maxY || newY < 0 || newX < 0) continue; //don't go out of bounds
      int routeScore = scores[mapCoordinate(x, y)]!;
      int currentCoordScore = scores[mapCoordinate(newX, newY)] ?? -1;
      int newScore = routeScore + maze[newY][newX];
      if (currentCoordScore < 0 || newScore < currentCoordScore) {
        scores[mapCoordinate(newX, newY)] = newScore;
        nodes_to_visit.add([newX, newY]);
      }
    }
  }
  return scores[mapCoordinate(maxX - 1, maxY - 1)]!;
}

void main() {
  List<List<int>> maze =
      File('day15.txt').readAsLinesSync().map((line) => line.split('').map((s) => int.parse(s)).toList()).toList();

  Map<int, int> scores = Map();
  scores[0] = 0;
  //part 1
  int res = bfs_traverse(
      maze,
      scores,
      ListQueue.from([
        [0, 0]
      ]));
  print(res);

  //part 2
  List<List<int>> big_maze = make_big_maze(maze);
  scores = Map();
  scores[0] = 0;

  res = bfs_traverse(
      big_maze,
      scores,
      ListQueue.from([
        [0, 0]
      ]));
  print(res);
}
