import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Animation de soumission
    await Future.delayed(const Duration(milliseconds: 1500));

    await UserService.setUserName(_nameController.text);
    await UserService.markFirstLaunchComplete();

    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E3C72),
              const Color(0xFF2A5298),
              const Color(0xFF1E3C72),
              const Color(0xFF4A90E2),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
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
        Text(
          'Bienvenue dans\nHordricWeather !',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
            color: Colors.white.withOpacity(0.9),
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
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.24),
              Colors.white.withOpacity(0.20),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextFormField(
          cursorColor: Colors.white,
          cursorWidth: 3,
          controller: _nameController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Votre prénom...',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 19,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            prefixIcon: Icon(
              Icons.person_outline,
              color: Colors.white.withOpacity(0.8),
              size: 34,
            ),
            suffixIcon: _nameController.text.isNotEmpty
                ? Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.withOpacity(0.8),
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
      duration: const Duration(milliseconds: 300),
      width: _isSubmitting ? 60 : double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitName,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E3C72),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_isSubmitting ? 30 : 15),
          ),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(
                color: Color(0xFF1E3C72),
                strokeWidth: 3,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch, size: 24),
                  const SizedBox(width: 12),
                  const Text(
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
