String getDayFromDate(DateTime date) {
  const days = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
  ];
  return days[date.weekday - 1];
}