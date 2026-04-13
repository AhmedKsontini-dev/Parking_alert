import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'plate_utils.dart';
import 'notification_service.dart';
import 'main_view.dart';
import 'core/api_service.dart';
import 'theme_app.dart';
import 'waiting_approval_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with SingleTickerProviderStateMixin {

  final _plateCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  late final AnimationController _ctrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  bool _isLoading = false;
  
  XFile? _frontImage;
  XFile? _backImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _plateCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        if (isFront) _frontImage = image;
        else _backImage = image;
      });
    }
  }

  Future<String?> _imageToBase64(XFile? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez importer les deux images de la carte grise")),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    setState(() => _isLoading = true);

    try {
      final String matricule = _plateCtrl.text.trim();
      final String phone = _phoneCtrl.text.trim();

      final existingUser = await ApiService.getUser(matricule);
      
      if (existingUser != null) {
        final bool isApproved = existingUser['isApproved'] ?? false;
        final String savedPhone = existingUser['phone'] ?? phone;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userMatricule', matricule);
        await prefs.setString('userPhone', savedPhone);

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (!isApproved) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WaitingApprovalView()));
        } else {
          await NotificationService.updateTokenInBackend(matricule);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainView(userMatricule: matricule, userPhone: savedPhone),
            ),
          );
        }
        return;
      }

      final String? frontBase64 = await _imageToBase64(_frontImage);
      final String? backBase64 = await _imageToBase64(_backImage);

      final success = await ApiService.registerUser({
        'matricule': matricule,
        'phone': phone,
        'frontCardImage': frontBase64,
        'backCardImage': backBase64,
      });

      if (!success) throw Exception("Failed to register user on server");
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userMatricule', matricule);
      await prefs.setString('userPhone', phone);

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WaitingApprovalView()));

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context)!.error}: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceVariant : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child:
                const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: AppTheme.registerPrimary),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 36),
                  _buildStepIndicator(),
                  const SizedBox(height: 32),
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  Text(
                    "Vérification d'identité (Carte Grise)",
                    style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImagePicker(
                          label: "Recto (Front)",
                          image: _frontImage,
                          onTap: () => _pickImage(true),
                          colorScheme: colorScheme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildImagePicker(
                          label: "Verso (Back)",
                          image: _backImage,
                          onTap: () => _pickImage(false),
                          colorScheme: colorScheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildContinueButton(),
                  Center(
                    child: Text(
                      l10n.infoLocallyStored,
                      style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          letterSpacing: 0.2),
                    ),
                  ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.registerPrimary, AppTheme.registerPrimaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.registerPrimary.withAlpha(77),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.app_registration_rounded,
              color: Colors.white, size: 30),
        ),
        const SizedBox(height: 22),
        Text(
          AppLocalizations.of(context)!.registerHeader,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context)!.registerSubtitle,
          style: TextStyle(
              color: AppTheme.textMuted, fontSize: 14.5, height: 1.55),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final active = i == 0;
        final done   = i < 0;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
            height: 5,
            decoration: BoxDecoration(
              color: active || done
                  ? AppTheme.registerPrimary
                  : AppTheme.registerPrimary.withAlpha(38),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFormCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildLabel(Icons.badge_outlined, AppLocalizations.of(context)!.licensePlateLabel),
          const SizedBox(height: 10),
            TextFormField(
              controller: _plateCtrl,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [TunisianPlateFormatter()],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
              decoration: _inputDecoration(
                hint: AppLocalizations.of(context)!.matriculeHint,
                icon: Icons.directions_car_filled_rounded,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? AppLocalizations.of(context)!.errorLicensePlateEmpty
                      : null,
            ),
          const SizedBox(height: 24),
          _buildLabel(Icons.phone_outlined, AppLocalizations.of(context)!.phoneNumberLabel),
          const SizedBox(height: 10),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [TunisianPhoneFormatter()],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            decoration: _inputDecoration(
              hint: '+216 XX XXX XXX',
              icon: Icons.phone_rounded,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return AppLocalizations.of(context)!.errorPhoneNumberEmpty;
              }
              if (v.trim().length < 15) {
                return AppLocalizations.of(context)!.errorPhoneNumberShort;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.registerPrimary, size: 17),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: AppTheme.textMuted.withAlpha(180),
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          fontSize: 15),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Icon(icon, color: AppTheme.registerPrimary.withAlpha(isDark ? 255 : 180), size: 22),
      ),
      filled: true,
      fillColor: isDark ? Colors.black26 : const Color(0xFFF5F8FF),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDE3F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.registerPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
      ),
    );
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _onContinue,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        height: 58,
        decoration: AppTheme.getRegisterBtnGradient(_isLoading),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.continueText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required XFile? image,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null ? Colors.green : colorScheme.outline,
            width: 2,
          ),
        ),
        child: image != null
            ? Stack(
                children: [
                   ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: kIsWeb
                        ? Image.network(image.path, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                        : Image.file(File(image.path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, color: colorScheme.primary, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}
