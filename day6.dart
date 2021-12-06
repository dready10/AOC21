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
  //(just takes a few minutes)...
  Map<int, int> children_of_fish = Map();
  for (int fish in [1, 2, 3, 4, 5]) {
    children_of_fish[fish] = get_descendent_count(fish, 256);
  }

  //and then use that precomputation to sum everything.
  total_fish = 0;
  for (int fish in fishes) {
    total_fish += (children_of_fish[fish] ?? -1) + 1;
  }
  print(total_fish);
}
