import 'package:auth/auth.dart';
import 'package:cmmn/cmmn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_app_ordering/cache/local_store.dart';
import 'package:food_app_ordering/cache/local_store_contract.dart';
import 'package:food_app_ordering/decorators/secure_client.dart';
import 'package:food_app_ordering/states_management/auth/auth_cubit.dart';
import 'package:food_app_ordering/states_management/helpers/header_cubit.dart';
import 'package:food_app_ordering/states_management/helpers/main_page_cubit.dart';
import 'package:food_app_ordering/states_management/restaurant/restaurant_cubit.dart';
import 'package:food_app_ordering/ui/pages/auth/auth_page.dart';
import 'package:food_app_ordering/ui/pages/auth/auth_page_adapter.dart';
import 'package:food_app_ordering/ui/pages/home/home_page_adapter.dart';
import 'package:food_app_ordering/ui/pages/home/restaurant_list_page.dart';
import 'package:food_app_ordering/ui/pages/main/main_page.dart';
import 'package:food_app_ordering/ui/pages/restaurant/restaurant_page.dart';
import 'package:food_app_ordering/ui/pages/search_results/search_results_page.dart';
import 'package:food_app_ordering/ui/pages/search_results/search_results_page_adapter.dart';
import 'package:restaurant/restaurant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class CompositionRoot {
  static SharedPreferences _sharedPreferences;
  static ILocalStore _localStore;
  static String _baseUrl;
  static Client _client;
  static SecureClient _secureClient;
  static RestaurantApi _api;
  static AuthManager _manager;
  static IAuthApi _authApi;

  static configure() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _localStore = LocalStore(_sharedPreferences);
    _client = Client();
    _baseUrl = "http://10.0.2.2:3000";
    _secureClient = SecureClient(HttpClientImpl(_client), _localStore);
    _api = RestaurantApi(_baseUrl, _secureClient);
    _authApi = AuthApi(_baseUrl, _client);
    _manager = AuthManager(_authApi);
  }

  static Widget composeAuthUi() {
    AuthCubit _authCubit = AuthCubit(_localStore);
    ISignUpService _signupService = SignUpService(_authApi);
    IAuthPageAdapter _adapter =
        AuthPageAdapter(onUserAuthenticated: composeHomeUi);

    return BlocProvider(
      create: (BuildContext context) => _authCubit,
      child: AuthPage(_manager, _signupService, _adapter),
    );
  }

  static Future<Widget> start() async {
    final token = await _localStore.fetch();
    final authType = await _localStore.fetchAuthType();
    final service = _manager.service(authType);
    return token == null ? composeAuthUi() : _composeMainPage(service);
  }

  static Widget composeHomeUi(IAuthService service) {
    RestaurantCubit _restaurantCubit =
        RestaurantCubit(_api, defaultPageSize: 20);
    IHomePageAdapter adapter = HomePageAdapter(
        onSearch: _composeSearchResultsPageWith,
        onSelection: _composeRestaurantPageWith,
        onLogout: composeAuthUi);
    AuthCubit _authCubit = AuthCubit(_localStore);

    return MultiBlocProvider(providers: [
      BlocProvider<RestaurantCubit>(
        create: (BuildContext context) => _restaurantCubit,
      ),
      BlocProvider<HeaderCubit>(
        create: (BuildContext context) => HeaderCubit(),
      ),
      BlocProvider<AuthCubit>(
        create: (BuildContext context) => _authCubit,
      )
    ], child: RestaurantListPage(adapter, service));
  }

//experimental features for using a bottom navigation bar to show different pages
  static Widget _composeMainPage(IAuthService service) {
    final pagesToCompose = [
      () => composeHomeUi(service),
      () => _composeQR(),
      () => _composeSettings()
    ];
    MainPageCubit _mainPageCubit =
        MainPageCubit(pagesToCompose: pagesToCompose);
    return BlocProvider<MainPageCubit>(
      create: (BuildContext context) => _mainPageCubit,
      child: MainPage(),
    );
  }

  //experimental features for using a bottom navigation bar to show different pages
  static Widget _composeQR() => Center(child: Text('QR Page'));
  static Widget _composeSettings() => Center(child: Text('Settings Page'));

  static Widget _composeSearchResultsPageWith(String query) {
    RestaurantCubit restaurantCubit =
        RestaurantCubit(_api, defaultPageSize: 10);
    ISearchResultsPageAdapter searchResultsPageAdapter =
        SearchResultsPageAdapter(onSelection: _composeRestaurantPageWith);
    return SearchResultsPage(restaurantCubit, query, searchResultsPageAdapter);
  }

  static Widget _composeRestaurantPageWith(Restaurant restaurant) {
    RestaurantCubit restaurantCubit =
        RestaurantCubit(_api, defaultPageSize: 10);
    return RestaurantPage(restaurant, restaurantCubit);
  }
}
