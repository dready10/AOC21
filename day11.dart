import 'dart:io';

int flash(List<List<int>> octopuses, i, j) {
  octopuses[i][j] = 0;
  int flashes = 1;
  for (int i2 = -1; i2 < 2; i2++) {
    for (int j2 = -1; j2 < 2; j2++) {
      if (octopuses[i + i2][j + j2] != 0) octopuses[i + i2][j + j2] += 1;
      if (octopuses[i + i2][j + j2] > 9) flashes += flash(octopuses, i + i2, j + j2);
    }
  }
  return flashes;
}

bool is_all_zeros(List<List<int>> octopuses) {
  return octopuses.reduce((e, i) => e + i).reduce((e, i) => e + i) == 0;
}

int count_flashes(List<List<int>> octopuses) {
  // Increment everyone by one.
  for (int i = 1; i < octopuses.length - 1; i++) {
    for (int j = 1; j < octopuses[0].length - 1; j++) {
      octopuses[i][j] += 1;
    }
  }

  // Flash if powerlevel >= 9.
  int flashes = 0;
  for (int i = 1; i < octopuses.length - 1; i++) {
    for (int j = 1; j < octopuses[0].length - 1; j++) {
      if (octopuses[i][j] > 9) {
        flashes += flash(octopuses, i, j);
      }
    }
  }
  return flashes;
}

void main() {
  //The trick I did here I stole from someone for like day 6 or day 7 or something.
  //Up front, I wrap the grid in zeros so that I don't get any null errors and I don't have
  //to do bounds checking when looking at neighbors. I can just reference them
  //at will, but ignore them in any calculations. It makes the count_flashes and flash
  //functions much cleaner.
  List<List<int>> octopuses = File('day11.txt')
      .readAsLinesSync()
      .map((line) => line.split('').map((o) => int.parse(o)).toList()
        ..insert(0, 0)
        ..add(0))
      .toList();
  octopuses.insert(0, List.generate(octopuses[0].length, (e) => 0));
  octopuses.add(List.generate(octopuses[0].length, (e) => 0));

  int total_flashes = 0;
  int all_flashes_at = 0;
  while (!is_all_zeros(octopuses)) {
    if (all_flashes_at < 100)
      total_flashes += count_flashes(octopuses);
    else
      count_flashes(octopuses);
    all_flashes_at++;
  }
  print("Flashes after 100 cycles: $total_flashes");
  print("Earliest cycle when all octopoda simultaneously flash: $all_flashes_at");
}
