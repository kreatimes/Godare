import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:godare/pages/edit_profile_page.dart';
import 'package:godare/pages/forgot_password_page.dart';
import 'package:godare/pages/login_page.dart';
import 'package:godare/pages/my_home_page.dart';
import 'package:godare/pages/notifications_page.dart';
import 'package:godare/pages/password_reset_page.dart';
import 'package:godare/pages/register_page.dart';
import 'package:godare/pages/search_users_page.dart';
import 'package:godare/pages/user_profile_page.dart';

import '../pages/change_password_page.dart';
import '../pages/follow_list_page.dart';
import '../pages/post_detail_page.dart';

const String ROUTE_HOME = '/home';
const String ROUTE_LOGIN = '/login';
const String ROUTE_REGISTER = '/register';
const String ROUTE_RESET_PASSWORD = '/reset_password';
const String ROUTE_FORGOT_PASSWORD = '/forgot_password';
const String ROUTE_USER_PROFILE = '/userProfile';
const String ROUTE_NOTIFICATIONS = '/notifications';
const String ROUTE_SEARCH_USERS = '/searchUsers';
const String ROUTE_EDIT_PROFILE = '/editProfile';
const String ROUTE_CHANGE_PASSWORD = '/changePassword';
const String ROUTE_POST_DETAIL = '/postDetail';
const String ROUTE_FOLLOW_LIST = '/followList';

class MyRouters {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case ROUTE_HOME:
        return PageTransition(
          child: const MyHomePage(),
          type: PageTransitionType.fade,
          settings: settings,
          alignment: Alignment.center,
        );
      case ROUTE_LOGIN:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case ROUTE_REGISTER:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case ROUTE_FORGOT_PASSWORD:
      // Recibe fromDrawer como argumento — false por defecto (viene del login)
        final fromDrawer = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordPage(fromDrawer: fromDrawer),
          settings: settings,
        );
      case ROUTE_RESET_PASSWORD:
      // Pasa los settings para que PasswordResetPage pueda leer fromDrawer
        return MaterialPageRoute(
          builder: (_) => const PasswordResetPage(),
          settings: settings,
        );
      case ROUTE_NOTIFICATIONS:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case ROUTE_SEARCH_USERS:
        return MaterialPageRoute(builder: (_) => const SearchUsersPage());
      case ROUTE_EDIT_PROFILE:
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      case ROUTE_CHANGE_PASSWORD:
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());
      case ROUTE_USER_PROFILE:
        final userId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => UserProfilePage(userId: userId),
        );
      case ROUTE_POST_DETAIL:
        final postId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => PostDetailPage(postId: postId ?? ''),
        );
      case ROUTE_FOLLOW_LIST:
        final args = settings.arguments as FollowListArgs;
        return MaterialPageRoute(
          builder: (_) => FollowListPage(
            userId: args.userId,
            showFollowers: args.showFollowers,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}