import 'package:flutter/material.dart';
import 'package:pakeeza_pos/core/constants/app_constants.dart';
import 'package:pakeeza_pos/core/theme/app_theme.dart';
import 'package:pakeeza_pos/data/repositories/auth_repository.dart';
import 'package:pakeeza_pos/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _loginForm = GlobalKey<FormState>();
  final _signupForm = GlobalKey<FormState>();

  final _loginUser = TextEditingController();
  final _loginPass = TextEditingController();
  final _signupName = TextEditingController();
  final _signupUser = TextEditingController();
  final _signupPass = TextEditingController();
  final _signupConfirm = TextEditingController();

  bool _obscureLogin = true;
  bool _obscureSignup = true;
  bool _busy = false;
  String? _error;

  bool _tabsReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tabsReady) {
      final needsSetup = context.read<AuthProvider>().needsSetup;
      _tabs = TabController(
        length: 2,
        vsync: this,
        initialIndex: needsSetup ? 1 : 0,
      );
      _tabsReady = true;
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    _loginUser.dispose();
    _loginPass.dispose();
    _signupName.dispose();
    _signupUser.dispose();
    _signupPass.dispose();
    _signupConfirm.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_loginForm.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().login(
            _loginUser.text,
            _loginPass.text,
          );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitSignup() async {
    if (!_signupForm.currentState!.validate()) return;
    if (_signupPass.text != _signupConfirm.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().signUp(
            username: _signupUser.text,
            password: _signupPass.text,
            displayName: _signupName.text,
          );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Sign up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_tabsReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final needsSetup = context.watch<AuthProvider>().needsSetup;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Fast Food & Pizza Point',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                if (needsSetup) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: const Text(
                      'First time setup: create your owner account to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.goldLight, fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                TabBar(
                  controller: _tabs,
                  indicatorColor: AppColors.gold,
                  labelColor: AppColors.goldLight,
                  unselectedLabelColor: AppColors.textMuted,
                  tabs: const [
                    Tab(text: 'Login'),
                    Tab(text: 'Sign Up'),
                  ],
                ),
                const SizedBox(height: 20),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.danger),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  height: 340,
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _buildLoginForm(),
                      _buildSignupForm(needsSetup),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginForm,
      child: Column(
        children: [
          TextFormField(
            controller: _loginUser,
            decoration: const InputDecoration(labelText: 'Username'),
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().length < 3) ? 'Enter username' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _loginPass,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLogin ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureLogin = !_obscureLogin),
              ),
            ),
            obscureText: _obscureLogin,
            onFieldSubmitted: (_) => _submitLogin(),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter password' : null,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : _submitLogin,
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm(bool isFirstUser) {
    return Form(
      key: _signupForm,
      child: Column(
        children: [
          TextFormField(
            controller: _signupName,
            decoration: const InputDecoration(labelText: 'Display name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _signupUser,
            decoration: const InputDecoration(labelText: 'Username'),
            validator: (v) => (v == null || v.trim().length < 3)
                ? 'At least 3 characters'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _signupPass,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignup ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureSignup = !_obscureSignup),
              ),
            ),
            obscureText: _obscureSignup,
            validator: (v) => (v == null || v.length < 6)
                ? 'At least 6 characters'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _signupConfirm,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            obscureText: _obscureSignup,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Confirm password' : null,
          ),
          if (isFirstUser)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'First account becomes Owner (full access).',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : _submitSignup,
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isFirstUser ? 'Create owner account' : 'Sign up'),
            ),
          ),
        ],
      ),
    );
  }
}
