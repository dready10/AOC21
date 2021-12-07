import 'dart:io';

int simple_difference(int pos1, int pos2) {
  return (pos1 - pos2).abs();
}

int nonconstant_difference(int pos1, int pos2) {
  return ((pos1 - pos2).abs() / 2 * ((pos1 - pos2).abs())).floor();
}

int get_min_required_fuel(List<int> positions, int Function(int, int) diff) {
  final Map<int, int> total_fuel_used = Map();
  for (int position in positions) {
    if (total_fuel_used.keys.contains(position)) continue;
    for (int new_pos in positions) {
      total_fuel_used[position] = (total_fuel_used[position] ?? 0) + diff(new_pos, position);
    }
  }
  return (total_fuel_used.values.toList()..sort()).first;
}

void main() {
  final List<int> crab_positions = File('day7.txt').readAsStringSync().split(',').map((e) => int.parse(e)).toList();
  print(get_min_required_fuel(crab_positions, simple_difference));
  print(get_min_required_fuel(crab_positions, nonconstant_difference));
}
