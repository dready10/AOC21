// Global variable to assist in part 1. Much cleaner than trying to
// pass version numbers and totals up and down function chains.
int version_total = 0;

// Helper function that puts the hex string into a binary list.
List<int> parseHex(String hex) {
  List<int> bin = [];
  for (String c in hex.split('')) {
    bin.addAll(int.parse(c, radix: 16).toRadixString(2).padLeft(4, '0').split('').map((e) => int.parse(e)));
  }
  return bin;
}

// Function that parses a literal packet--assumes headers have been stripped.
// It reads five bytes at a time. If the first byte is 1 it continues, otherwise
// it reads five bytes one final time.
List<int> parseLiteralPacket(List<int> packet) {
  List<int> value = [];
  int bytes_read = 0;
  while (packet[0] == 1) {
    value.addAll(packet.sublist(1, 5));
    packet = packet.sublist(5);
    bytes_read += 5;
  }
  value.addAll(packet.sublist(1, 5));
  bytes_read += 5;
  return [bytes_read, (int.parse(value.join(''), radix: 2))];
}

// How about some co-recursion? Parses the number of bytes/packets to read
// and then reads that number of backets back through parse_packet.
// Eventually the co-recursion has to end because
// we have to compare / add / max / whatever some literal number, which is what
// the above, non-recursive function returns.
List<int> parseOperatorPacket(List<int> packet) {
  int length;
  bool isPackets;
  int bytes_read = 0;
  List<int> res = [];

  if (packet[0] == 0) {
    length = int.parse(packet.sublist(1, 16).join(''), radix: 2);
    packet = packet.sublist(16);
    isPackets = false;
    bytes_read += 16;
  } else {
    length = int.parse(packet.sublist(1, 12).join(''), radix: 2);
    packet = packet.sublist(12);
    isPackets = true;
    bytes_read += 12;
  }

  if (isPackets) {
    while (length-- > 0) {
      List<int> new_res = parse_packet(packet);
      bytes_read += new_res[0];
      res.add(new_res[1]);
      packet = packet.sublist(new_res[0]);
    }
  } else {
    while (length > 0) {
      List<int> new_res = parse_packet(packet);
      length -= new_res[0];
      bytes_read += new_res[0];
      res.add(new_res[1]);
      packet = packet.sublist(new_res[0]);
    }
  }
  return [bytes_read]..addAll(res);
}

// Strip the headers, and then grab the literal or put it through
// parseOperatorPacket to co-recurse back here. Eventually, parseOperatorPacket
// will return a list of values which can be used to calculate the amount
// specified by type.
List<int> parse_packet(List<int> packet) {
  version_total += int.parse(packet.sublist(0, 3).join(''), radix: 2);
  int type = int.parse(packet.sublist(3, 6).join(''), radix: 2);
  int bytes_read = 6;
  int value = 0;
  switch (type) {
    case 0:
      List<int> ret = parseOperatorPacket(packet.sublist(6));
      bytes_read += ret[0];
      ret = ret.sublist(1);
      value = ret.reduce((e, i) => e + i);
      break;
    case 1:
      List<int> ret = parseOperatorPacket(packet.sublist(6));
      bytes_read += ret[0];
      ret = ret.sublist(1);
      value = ret.reduce((e, i) => e * i);
      break;
    case 2:
      List<int> ret = parseOperatorPacket(packet.sublist(6));
      bytes_read += ret[0];
      ret = ret.sublist(1);
      value = ret.reduce((e, i) => e < i ? e : i);
      break;
    case 3:
      List<int> ret = parseOperatorPacket(packet.sublist(6));
      bytes_read += ret[0];
      ret = ret.sublist(1);
      value = ret.reduce((e, i) => e > i ? e : i);
      break;
    case 4:
      List<int> ret = parseLiteralPacket(packet.sublist(6));
      bytes_read += ret[0];
      value = ret[1];
      break;
    case 5:
      List<int> ret = parseOperatorPacket(packet.sublist(6));
      bytes_read += ret[0];
      ret = ret.sublist(1);
      value = ret[0] > ret[1] ? 1 : 0;
      break;
    case 6:
      List<int> ret = parseOperatorPacket(packet.sublist(6));
      bytes_read += ret[0];
      ret = ret.sublist(1);
      value = ret[0] < ret[1] ? 1 : 0;
      break;
    case 7:
      List<int> ret = parseOperatorPacket(packet.sublist(6));
      bytes_read += ret[0];
      ret = ret.sublist(1);
      value = ret[0] == ret[1] ? 1 : 0;
      break;
    default:
      1 / 0; //Something went wrong.
      break;
  }
  return [bytes_read, value];
}

void main() {
  List<int> packet = parseHex(
      '8054F9C95F9C1C973D000D0A79F6635986270B054AE9EE51F8001D395CCFE21042497E4A2F6200E1803B0C20846820043630C1F8A840087C6C8BB1688018395559A30997A8AE60064D17980291734016100622F41F8DC200F4118D3175400E896C068E98016E00790169A600590141EE0062801E8041E800F1A0036C28010402CD3801A60053007928018CA8014400EF2801D359FFA732A000D2623CADE7C907C2C96F5F6992AC440157F002032CE92CE9352AF9F4C0119BDEE93E6F9C55D004E66A8B335445009E1CCCEAFD299AA4C066AB1BD4C5804149C1193EE1967AB7F214CF74752B1E5CEDC02297838C649F6F9138300424B9C34B004A63CCF238A56B71520142A5A7FC672E5E00B080350663B44F1006A2047B8C51CC80286C0055253951F98469F1D86D3C1E600F80021118A124261006E23C7E8260008641A8D51F0C01299EC3F4B6A37CABD80252211221A600BC930D0057B2FAA31CDCEF6B76DADF1666FE2E000FA4905CB7239AFAC0660114B39C9BA492D4EBB180252E472AD6C00BF48C350F9F47D2012B6C014000436284628BE00087C5D8671F27F0C480259C9FE16D1F4B224942B6F39CAF767931CFC36BC800EA4FF9CE0CCE4FCA4600ACCC690DE738D39D006A000087C2A89D0DC401987B136259006AFA00ACA7DBA53EDB31F9F3DBF31900559C00BCCC4936473A639A559BC433EB625404300564D67001F59C8E3172892F498C802B1B0052690A69024F3C95554C0129484C370010196269D071003A079802DE0084E4A53E8CCDC2CA7350ED6549CEC4AC00404D3C30044D1BA78F25EF2CFF28A60084967D9C975003992DF8C240923C45300BE7DAA540E6936194E311802D800D2CB8FC9FA388A84DEFB1CB2CBCBDE9E9C8803A6B00526359F734673F28C367D2DE2F3005256B532D004C40198DF152130803D11211C7550056706E6F3E9D24B0');
  List<int> results = parse_packet(packet);

  // Part 1, implemented with global variable
  print(version_total);

  // Part 2
  print(results[1]);
}
