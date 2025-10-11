import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/user_service.dart';
import '../../../shared/widgets/app_logo.dart';

class UserOnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;

  const UserOnboardingPage({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<UserOnboardingPage> createState() => _UserOnboardingPageState();
}

class _UserOnboardingPageState extends State<UserOnboardingPage>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  late AnimationController _pulseController;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _submitName() async {
    print('=== SUBMIT NAME BUTTON CLICKED ===');
    print('Form is valid: ${_formKey.currentState?.validate()}');

    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    print('Setting isSubmitting to true');
    setState(() => _isSubmitting = true);

    try {
      // Animation de soumission
      print('Waiting for animation delay...');
      await Future.delayed(const Duration(milliseconds: 1500));

      print('Saving user name: ${_nameController.text}');
      await UserService.setUserName(_nameController.text);

      print('Marking first launch complete');
      await UserService.markFirstLaunchComplete();

      print('User data saved successfully, proceeding to next screen');

      if (mounted) {
        print('Widget is mounted, calling onComplete()');
        widget.onComplete();
      } else {
        print('WARNING: Widget is not mounted!');
      }
    } catch (e) {
      print('Error in _submitName: $e');
      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            gradient: AppTheme.onboardingGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXXL),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo et titre animés
                  _buildHeader(),

                  const Spacer(flex: 2),

                  // Formulaire
                  _buildForm(),

                  const Spacer(flex: 1),

                  // Bouton de soumission
                  _buildSubmitButton(),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icône principale avec animation de pulse
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.overlay30,
                      AppTheme.overlay10,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.overlay30,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: AppLogo(
                  size: 60,
                  withShadow: false,
                  withAnimation: false,
                ),
              ),
            );
          },
        ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms),

        const SizedBox(height: 32),

        // Titre principal
        const Text(
          'Bienvenue dans\nHordricWeather !',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textOnPrimary,
            height: 1.2,
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

        const SizedBox(height: 16),

        // Sous-titre
        Text(
          'Pour personnaliser votre expérience,\ncomment puis-je vous appeler ?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.textOnPrimary.withOpacity(0.9),
            height: 1.4,
          ),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
          gradient: LinearGradient(
            colors: [
              AppTheme.overlay25,
              AppTheme.overlay20,
            ],
          ),
          border: Border.all(
            color: AppTheme.textOnPrimary.withOpacity(0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkOverlay10,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextFormField(
          cursorColor: AppTheme.textOnPrimary,
          cursorWidth: 3,
          controller: _nameController,
          style: const TextStyle(
            color: AppTheme.textOnPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submitName(),
          decoration: InputDecoration(
            hintText: 'Votre prénom...',
            hintStyle: TextStyle(
              color: AppTheme.textOnPrimary.withOpacity(0.9),
              fontSize: 19,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingXXL,
              vertical: AppTheme.spacingXL,
            ),
            prefixIcon: Icon(
              Icons.person_outline,
              color: AppTheme.textOnPrimary.withOpacity(0.8),
              size: 34,
            ),
            suffixIcon: _nameController.text.isNotEmpty
                ? Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.success.withOpacity(0.8),
                    size: 24,
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer votre prénom';
            }
            if (value.trim().length < 2) {
              return 'Le prénom doit contenir au moins 2 caractères';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {});
          },
        ),
      ).animate().fadeIn(delay: 800.ms).slideY().scale(),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: AppTheme.animationFast,
      width: _isSubmitting ? 60 : double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitName,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.cardBackground,
          foregroundColor: AppTheme.gradientDeep,
          elevation: 8,
          shadowColor: AppTheme.darkOverlay20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_isSubmitting ? 30 : 15),
          ),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(
                color: AppTheme.gradientDeep,
                strokeWidth: 3,
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Commencer l\'aventure !',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY().scale();
  }
}
