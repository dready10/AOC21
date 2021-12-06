import 'dart:collection';
import 'dart:io';

const int LIFE_CYCLE = 7;

int how_many_births(days_till_reproduction, days_left_in_sim) {
  if (days_till_reproduction >= days_left_in_sim) return 0;
  days_left_in_sim -= days_till_reproduction + 1;
  return 1 + (days_left_in_sim ~/ LIFE_CYCLE) as int;
}

int get_descendent_count(days_till_reproduction, days_left_in_sim) {
  int descendents = how_many_births(days_till_reproduction, days_left_in_sim);
  days_left_in_sim -= days_till_reproduction + 1;
  while (days_left_in_sim >= 0) {
    descendents += get_descendent_count(8, days_left_in_sim);
    days_left_in_sim -= LIFE_CYCLE;
  }
  return descendents;
}

void main() {
  Iterable<int> fishes = File('day6.txt').readAsLinesSync()[0].split(',').map((e) => int.parse(e));

  int total_fish = 0;
  for (int fish in fishes) {
    total_fish += get_descendent_count(fish, 80) + 1; // +1 for fishy in file.
  }
  print(total_fish);

  //ok, so I lucked out that we are looking at 256 epochs and not 512, otherwise
  //this solution would not work. But fish can only have 1-5 days until their
  //next birth which means that for each of the given fish, they will all
  //have the same number of dependents based on if they have 1, 2, 3, 4, or 5
  //days until their next birth... so we just precompute those descendents
  //(just takes a couple minutes)...
  Map<int, int> children_of_fish = Map();
  for (int fish in [1, 2, 3, 4, 5]) {
    children_of_fish[fish] = get_descendent_count(fish, 256);
  }

  //and then use that precomputation to sum everything. I am sure there is a
  //more cleverer way that isn't so cheat-adjacent, but here we are.
  total_fish = 0;
  for (int fish in fishes) {
    total_fish += (children_of_fish[fish] ?? -1) + 1;
  }
  print(total_fish);

  // Real solution (taken from https://github.com/prendradjaja/advent-of-code-2021/blob/main/06--lanternfish/b.py):
  List<int> fish_counts = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  for (int fish in fishes) {
    fish_counts[fish] += 1;
  }
  List<int> fish_counts_copy = List.from(fish_counts);
  print(real_solution(fish_counts, 80));
  print(real_solution(fish_counts_copy, 256));
}

int real_solution(List<int> fish_counts, max_epoch) {
  for (int i = 0; i < max_epoch; i++) {
    int births = fish_counts.first;
    fish_counts.remove(births); //Lists don't have a removeFirst :(. ListQueues do, but they don't have operator[].
    fish_counts[6] += births;
    fish_counts.add(births);
  }
  return fish_counts.reduce((i, j) => i + j);
}
