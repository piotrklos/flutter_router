import 'package:bloc_test/bloc_test.dart';
import 'package:example/app_router/interface/route.dart';
import 'package:example/bloc/more/more_bloc.dart';
import 'package:example/bloc/more/more_state.dart';
import 'package:example/pages/home/more/more_page.dart';
import 'package:example/pages/home/more/notification/notification_page.dart';
import 'package:example/pages/start/start_page.dart';
import 'package:example/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'test_wrappers.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockMoreCubit extends MockCubit<MoreState> implements MoreCubit {}

class MockRoute extends Mock implements Route {}

void main() {
  late NavigatorObserver navigatorObserver;
  late MoreCubit moreCubit;

  setUpAll(() {
    registerFallbackValue(MockRoute());
    moreCubit = MockMoreCubit();
    navigatorObserver = MockNavigatorObserver();
    GetIt.instance.registerFactory<UserService>(() => UserService());
    GetIt.instance.registerLazySingleton<MoreCubit>(() => moreCubit);
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  List<BlocProvider<BlocBase<Object?>>> _getProviders() => [
        BlocProvider<MoreCubit>(create: (_) => moreCubit),
      ];

  testWidgets('should render correctly', (WidgetTester tester) async {
    final widget = await TestWrappers.preparePageWrapperWithaNavigator(
      pageName: StartPage.name,
      observer: navigatorObserver,
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.text('Login To app'), findsOneWidget);
    expect(find.text('Login Internal user'), findsOneWidget);
    expect(find.text('Login External user'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('./resources/test.png'),
    );

    // await tester.tap(find.text('Login External user'));
    // await tester.pump();
  });

  testWidgets('should render correctly with cubit and full widgets tree',
      (WidgetTester tester) async {
    when(() => moreCubit.state).thenReturn(const MoreState("test message"));

    final widget = await TestWrappers.preparePageWrapperWithaNavigatorAndBlocs(
      pageName: MorePage.name,
      providers: _getProviders(),
      observer: navigatorObserver,
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.text('More Tab'), findsOneWidget);
    expect(find.text('Notification'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('./resources/test_more_with_tab.png'),
    );

    await tester.tap(find.text('Notification'));
    await tester.pump();
    verify(() => navigatorObserver.didPush(any(), any())).called(2);
  });
  testWidgets('should render correctly with cubit and passed widgets tree',
      (WidgetTester tester) async {
    when(() => moreCubit.state).thenReturn(const MoreState("test message"));

    final widget = await TestWrappers.preparePageWrapperWithaNavigatorAndBlocs(
      pageName: MorePage.name,
      providers: _getProviders(),
      observer: navigatorObserver,
      routes: [
        PBPageRoute(
          name: MorePage.name,
          builder: (_, __) => const MorePage(),
        )..addRoute(
            PBPageRoute(
              name: NotificationPage.name,
              builder: (_, __) => const NotificationPage(),
            ),
          ),
      ],
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.text('More Tab'), findsOneWidget);
    expect(find.text('Notification'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('./resources/test_more.png'),
    );

    await tester.tap(find.text('Notification'));
    await tester.pump();
    verify(() => navigatorObserver.didPush(any(), any())).called(2);
  });
}
