import '../../../../pages/home/insights/insights_page.dart';
import '../../../interface/route.dart';

class InsightsTabRoutes {
  IRoute get baseRoute => _insightsRoute;

  InsightsTabRoutes() {
    _init();
  }

  void _init() {
    /// init routes here;
  }

  final _insightsRoute = PBPageRoute(
    name: InsightsPage.name,
    builder: (context, state) {
      return const InsightsPage();
    },
  );
}
