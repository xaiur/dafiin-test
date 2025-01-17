import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_app_ordering/states_management/helpers/main_page_cubit.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex;
  PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    _currentIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainPageCubit, int>(builder: (context, state) {
      _currentIndex = state;
      return _buildUi();
    });
  }

  _buildUi() => Scaffold(
        body: PageStorage(
          child: context.read<MainPageCubit>().currentPage,
          bucket: _bucket,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0.2,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => context.read<MainPageCubit>().currentIndex(index),
          items: _items(),
        ),
      );

  List<BottomNavigationBarItem> _items() => [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 32.0,
            ),
            label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.qr_code,
              size: 32.0,
            ),
            label: 'QR'),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              size: 32.0,
            ),
            label: 'Settings')
      ];
}
