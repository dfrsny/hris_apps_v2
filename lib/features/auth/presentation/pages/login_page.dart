import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/core/widgets/app_snackbar.dart';
import 'package:hris_apps/features/auth/presentation/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.provider});

  final AuthProvider provider;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = widget.provider;
    final success = await provider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      AppSnackbar.showSuccess(
        context,
        title: 'Login Berhasil',
        message: 'Selamat datang kembali di Portal HRIS.',
      );
    } else {
      AppSnackbar.showError(
        context,
        title: 'Login Gagal',
        message: provider.errorMessage ?? 'Email atau password tidak sesuai.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final provider = widget.provider;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.space24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimensions.maxFormWidth,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Brand Header ──
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: AppDimensions.borderRadiusMd,
                        ),
                        child: Icon(
                          Icons.badge_rounded,
                          size: 30,
                          color: colors.primary,
                        ),
                      ),
                      AppDimensions.gap16,
                      Text(
                        'Portal HRIS',
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      AppDimensions.gap4,
                      Text(
                        'Masuk menggunakan akun perusahaan Anda',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      AppDimensions.gap24,

                      // ── Login Card ──
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.space24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Email Perusahaan',
                                  style: theme.textTheme.labelMedium,
                                ),
                                AppDimensions.gap6,
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: 'nama@perusahaan.co.id',
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      size: AppDimensions.iconMd,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        !value.trim().contains('@')) {
                                      return 'Masukkan alamat email yang valid';
                                    }
                                    return null;
                                  },
                                ),
                                AppDimensions.gap16,
                                Text(
                                  'Password',
                                  style: theme.textTheme.labelMedium,
                                ),
                                AppDimensions.gap6,
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) =>
                                      provider.isLoading ? null : _submit(),
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan password',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      size: AppDimensions.iconMd,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: AppDimensions.iconMd,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                                AppDimensions.gap20,
                                FilledButton(
                                  onPressed: provider.isLoading
                                      ? null
                                      : _submit,
                                  child: provider.isLoading
                                      ? SizedBox(
                                          height: AppDimensions.iconMd,
                                          width: AppDimensions.iconMd,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colors.onPrimary,
                                          ),
                                        )
                                      : const Text('Login'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
