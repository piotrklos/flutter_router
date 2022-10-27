// import 'package:flutter/material.dart';

// import '../../app_router/app_router.dart';

// class AppScaffold extends Scaffold {
//   AppScaffold({
//     AppBar? appBar,
//     super.key,
//     super.body,
//     super.floatingActionButton,
//     super.floatingActionButtonLocation,
//     super.floatingActionButtonAnimator,
//     super.persistentFooterButtons,
//     super.persistentFooterAlignment,
//     super.drawer,
//     super.onDrawerChanged,
//     super.endDrawer,
//     super.onEndDrawerChanged,
//     super.bottomNavigationBar,
//     super.bottomSheet,
//     super.backgroundColor,
//     super.resizeToAvoidBottomInset,
//     super.primary,
//     super.drawerDragStartBehavior,
//     super.extendBody,
//     super.extendBodyBehindAppBar,
//     super.drawerScrimColor,
//     super.drawerEdgeDragWidth,
//     super.drawerEnableOpenDragGesture,
//     super.endDrawerEnableOpenDragGesture,
//     super.restorationId,
//   }) : super(
//           appBar: _createAppBarWithBackButton(appBar),
//         );

//   static AppBar _createAppBarWithBackButton(AppBar? oldAppBard) {
//     return AppBar(
//       leading: _leadingBuilder(),
//       automaticallyImplyLeading: false,
//       title: oldAppBard?.title,
//       actions: oldAppBard?.actions,
//       flexibleSpace: oldAppBard?.flexibleSpace,
//       bottom: oldAppBard?.bottom,
//       elevation: oldAppBard?.elevation,
//       scrolledUnderElevation: oldAppBard?.scrolledUnderElevation,
//       notificationPredicate: oldAppBard?.notificationPredicate ??
//           defaultScrollNotificationPredicate,
//       shadowColor: oldAppBard?.shadowColor,
//       surfaceTintColor: oldAppBard?.surfaceTintColor,
//       shape: oldAppBard?.shape,
//       backgroundColor: oldAppBard?.backgroundColor,
//       foregroundColor: oldAppBard?.foregroundColor,
//       iconTheme: oldAppBard?.iconTheme,
//       actionsIconTheme: oldAppBard?.actionsIconTheme,
//       primary: oldAppBard?.primary ?? true,
//       centerTitle: oldAppBard?.centerTitle,
//       excludeHeaderSemantics: oldAppBard?.excludeHeaderSemantics ?? false,
//       titleSpacing: oldAppBard?.titleSpacing,
//       toolbarOpacity: oldAppBard?.toolbarOpacity ?? 1.0,
//       bottomOpacity: oldAppBard?.bottomOpacity ?? 1.0,
//       toolbarHeight: oldAppBard?.toolbarHeight,
//       leadingWidth: oldAppBard?.leadingWidth,
//       toolbarTextStyle: oldAppBard?.toolbarTextStyle,
//       titleTextStyle: oldAppBard?.titleTextStyle,
//       systemOverlayStyle: oldAppBard?.systemOverlayStyle,
//     );
//   }

//   static Widget _leadingBuilder() {
//     return Builder(
//       builder: (context) {
//         if (AppRouter.of(context).canPop()) {
//           return  BackButton(
//             onPressed: () {
//               AppRouter.of(context).pop();
//             },
//           );
//         }
//         return Container();
//       },
//     );
//   }
// }
