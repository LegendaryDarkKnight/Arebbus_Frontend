enum AddonCategory {
  bus('Bus'),
  route('Route'),
  stop('Stop');

  const AddonCategory(this.value);
  final String value;

  static AddonCategory fromString(String value) {
    return AddonCategory.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AddonCategory.bus,
    );
  }
}