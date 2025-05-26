enum LocationStatus {
  onBus('ON_BUS'),
  waiting('WAITING'),
  leftBus('LEFT_BUS');

  const LocationStatus(this.value);
  final String value;

  static LocationStatus fromString(String value) {
    return LocationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => LocationStatus.waiting,
    );
  }
}