
/// Helper function to format integer prices into Indonesian Rupiah currency format.
/// Example: 100000 -> "Rp. 100.000"
String formatPrice(int price) {
  final s = price.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp. $buf';
}
