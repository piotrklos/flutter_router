class TabBarState {
  final int currentIndex;
  final void Function(int index, bool resetLocation) changeTab;

  TabBarState({
    required this.currentIndex,
    required this.changeTab,
  });
}
