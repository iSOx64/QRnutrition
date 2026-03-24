enum ViewStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

extension ViewStatusX on ViewStatus {
  bool get isInitial => this == ViewStatus.initial;
  bool get isLoading => this == ViewStatus.loading;
  bool get isSuccess => this == ViewStatus.success;
  bool get isEmpty => this == ViewStatus.empty;
  bool get isError => this == ViewStatus.error;
}
