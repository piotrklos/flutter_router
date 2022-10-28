import 'package:example/bloc/more/more_bloc.dart';
import 'package:example/pages/home/more/more_page.dart';
import 'package:example/pages/start/start_page.dart';
import 'package:example/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:mockito/mockito.dart';

import 'test_wrappers.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockMoreCubit extends Mock implements MoreCubit {}

void main() {
  late final NavigatorObserver navigatorObserver;
  final moreCubit = MockMoreCubit();

  setUpAll(() {
    navigatorObserver = MockNavigatorObserver();
    GetIt.instance.registerFactory<UserService>(() => UserService());
    GetIt.instance.registerLazySingleton<MoreCubit>(() => moreCubit);
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('didPush', (WidgetTester tester) async {
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

  testWidgets('didPush - more page', (WidgetTester tester) async {
    final widget = await TestWrappers.preparePageWrapperWithaNavigator(
      pageName: MorePage.name,
      observer: navigatorObserver,
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    // expect(find.text('Login To app'), findsOneWidget);
    // expect(find.text('Login Internal user'), findsOneWidget);
    // expect(find.text('Login External user'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('./resources/test_more.png'),
    );

    // await tester.tap(find.text('Login External user'));
    // await tester.pump();
  });
}
