import '../../../../pages/home/messages/messages_details_page.dart';
import '../../../../pages/home/messages/messages_page.dart';
import '../../../interface/route.dart';

class MessagesTabRoutes {
  IRoute get baseRoute => _messagesRoute;

  MessagesTabRoutes() {
    _init();
  }

  void _init() {
    _messagesRoute.addRoute(_messagesDetailsRoute);
  }

  final _messagesRoute = PBPageRoute(
    name: MessagesPage.name,
    builder: (context, state) {
      return const MessagesPage();
    },
  );

  final _messagesDetailsRoute = PBPageRoute(
    name: MessagesDetailsPage.name,
    path: "details",
    builder: (context, state) {
      return const MessagesDetailsPage();
    },
  );
}
