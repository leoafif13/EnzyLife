
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

/// Helper function to format raw date strings (e.g. YYYY-MM-DD) into Indonesian DD-MM-YYYY format.
String formatDate(String rawDate) {
  if (rawDate.isEmpty) return '';
  
  String datePart = rawDate;
  String timePart = '';
  
  if (rawDate.contains('T')) {
    final parts = rawDate.split('T');
    datePart = parts[0];
    timePart = parts[1].split('.')[0];
  } else if (rawDate.contains(' ')) {
    final parts = rawDate.split(' ');
    datePart = parts[0];
    timePart = parts[1];
  }
  
  final dateParts = datePart.split('-');
  if (dateParts.length == 3) {
    datePart = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';
  }
  
  if (timePart.isNotEmpty) {
    final timeFormatted = timePart.length >= 5 ? timePart.substring(0, 5) : timePart;
    return '$datePart $timeFormatted';
  }
  
  return datePart;
}
