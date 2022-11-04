import '../../../../pages/home/documents/documents_page.dart';
import '../../../interface/route.dart';

class DocumentsTabRoutes {
  PBPageRoute get baseRoute => _documentsRoute;

  DocumentsTabRoutes() {
    _init();
  }

  void _init() {
    /// init routes here;
  }

  final _documentsRoute = PBPageRoute(
    name: DocumentsPage.name,
    builder: (context, state) {
      return const DocumentsPage();
    },
  );
}
