import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konta/presentation/screens/main_shell.dart';
import 'package:konta/presentation/screens/auth/login_screen.dart';
import 'package:konta/presentation/screens/auth/register_screen.dart';
import 'package:konta/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:konta/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:konta/presentation/screens/customers/customer_list_screen.dart';
import 'package:konta/presentation/screens/customers/customer_form_screen.dart';
import 'package:konta/presentation/screens/customers/customer_select_screen.dart';
import 'package:konta/presentation/screens/documents/document_list_screen.dart';
import 'package:konta/presentation/screens/invoices/invoice_form_screen.dart';
import 'package:konta/presentation/screens/invoices/invoice_detail_screen.dart';
import 'package:konta/presentation/screens/expenses/expense_list_screen.dart';
import 'package:konta/presentation/screens/expenses/expense_form_screen.dart';
import 'package:konta/presentation/screens/expenses/expense_detail_screen.dart';
import 'package:konta/presentation/screens/payments/payment_list_screen.dart';
import 'package:konta/presentation/screens/products/product_list_screen.dart';
import 'package:konta/presentation/screens/products/product_form_screen.dart';
import 'package:konta/presentation/screens/export/export_screen.dart';
import 'package:konta/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:konta/presentation/screens/profile/profile_screen.dart';
import 'package:konta/presentation/screens/settings/settings_screen.dart';
import 'package:konta/presentation/screens/settings/templates_screen.dart';
import 'package:konta/presentation/screens/team/team_members_screen.dart';
import 'package:konta/presentation/screens/team/invite_member_screen.dart';
import 'package:konta/presentation/screens/team/permissions_screen.dart';
import 'package:konta/presentation/screens/onboarding/join_company_screen.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/presentation/providers/auth_provider.dart';

String _getTitle(String location) {
  if (location == '/') return 'Tableau de bord';
  if (location.startsWith('/documents')) return 'Documents';
  if (location.startsWith('/expenses')) return 'Dépenses';
  return 'Konta';
}

final router = GoRouter(
  redirect: (context, state) async {
    final isAuthenticated = SupabaseService.isAuthenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');
    final isOnboarding = state.matchedLocation == '/onboarding';

    if (!isAuthenticated && !isAuthRoute) {
      return '/auth/login';
    }

    if (isAuthenticated && isAuthRoute) {
      return '/';
    }

    if (isAuthenticated && !isOnboarding) {
      if (!context.mounted) return null;
      final container = ProviderScope.containerOf(context);
      final needsOnboarding = await container.read(
        needsOnboardingProvider.future,
      );
      if (needsOnboarding) {
        return '/onboarding';
      }
    }

    if (isAuthenticated && isOnboarding) {
      if (!context.mounted) return null;
      final container = ProviderScope.containerOf(context);
      final needsOnboarding = await container.read(
        needsOnboardingProvider.future,
      );
      if (!needsOnboarding) {
        return '/';
      }
    }

    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          MainShell(title: _getTitle(state.matchedLocation), child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/documents',
          builder: (context, state) => const DocumentListScreen(type: 'all'),
        ),
        GoRoute(
          path: '/expenses',
          builder: (context, state) => const ExpenseListScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/onboarding/join',
      builder: (context, state) => const JoinCompanyScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomerListScreen(),
    ),
    GoRoute(
      path: '/customers/new',
      builder: (context, state) => const CustomerFormScreen(),
    ),
    GoRoute(
      path: '/customers/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return CustomerFormScreen(customerId: id);
      },
    ),
    GoRoute(
      path: '/customers/select',
      builder: (context, state) => const CustomerSelectScreen(),
    ),
    GoRoute(
      path: '/invoices/new',
      builder: (context, state) => const InvoiceFormScreen(type: 'invoice'),
    ),
    GoRoute(
      path: '/invoices/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return InvoiceDetailScreen(invoiceId: id ?? '');
      },
    ),
    GoRoute(
      path: '/invoices/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return InvoiceFormScreen(invoiceId: id, type: 'invoice');
      },
    ),
    GoRoute(
      path: '/quotes/new',
      builder: (context, state) => const InvoiceFormScreen(type: 'devis'),
    ),
    GoRoute(
      path: '/quotes/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return InvoiceDetailScreen(invoiceId: id ?? '');
      },
    ),
    GoRoute(
      path: '/quotes/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return InvoiceFormScreen(invoiceId: id, type: 'devis');
      },
    ),
    GoRoute(
      path: '/avoirs',
      builder: (context, state) => const DocumentListScreen(type: 'avoir'),
    ),
    GoRoute(
      path: '/avoirs/new',
      builder: (context, state) => const InvoiceFormScreen(type: 'avoir'),
    ),
    GoRoute(
      path: '/avoirs/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return InvoiceDetailScreen(invoiceId: id ?? '');
      },
    ),
    GoRoute(
      path: '/avoirs/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return InvoiceFormScreen(invoiceId: id, type: 'avoir');
      },
    ),
    GoRoute(
      path: '/expenses/new',
      builder: (context, state) => const ExpenseFormScreen(),
    ),
    GoRoute(
      path: '/expenses/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return ExpenseDetailScreen(expenseId: id ?? '');
      },
    ),
    GoRoute(
      path: '/expenses/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return ExpenseFormScreen(expenseId: id);
      },
    ),
    GoRoute(
      path: '/payments',
      builder: (context, state) => const PaymentListScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListScreen(),
    ),
    GoRoute(
      path: '/products/new',
      builder: (context, state) => const ProductFormScreen(),
    ),
    GoRoute(
      path: '/products/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return ProductFormScreen(productId: id);
      },
    ),
    GoRoute(path: '/export', builder: (context, state) => const ExportScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/templates',
      builder: (context, state) => const TemplatesScreen(),
    ),
    GoRoute(
      path: '/team/members',
      builder: (context, state) => const TeamMembersScreen(),
    ),
    GoRoute(
      path: '/team/invite',
      builder: (context, state) => const InviteMemberScreen(),
    ),
    GoRoute(
      path: '/team/permissions',
      builder: (context, state) => const PermissionsScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);
