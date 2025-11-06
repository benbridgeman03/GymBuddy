String getTimeOfDay(DateTime dateTime) {
  final hour = dateTime.hour;

  if (hour >= 0 && hour < 12) {
    return "Morning";
  } else if (hour >= 12 && hour < 17) {
    return "Afternoon";
  } else {
    return "Evening";
  }
}
