import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../features/auth/services/auth_service.dart';
import '../features/auth/services/user_profile_service.dart';
import '../features/auth/services/avatar_upload_service.dart';
import '../features/auth/services/pin_security_service.dart';
import '../core/theme/app_theme.dart';
import 'pin_setup_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _avatarUploadService = AvatarUploadService();
  final _pinService = PinSecurityService();

  late TabController _tabController;
  bool _isLoading = true;
  bool _isUploadingAvatar = false;

  // Avatar
  File? _selectedImageFile;
  String? _currentAvatarUrl;

  // Learning Aim
  String? _selectedLearningAim;

  // Settings
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;
  String _languagePreference = 'en';
  int _dailyGoal = 20;

  // PIN Security
  bool _pinEnabled = false;
  bool _hasPinSet = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final profileService =
        Provider.of<UserProfileService>(context, listen: false);
    final userId = authService.currentUser?.uid;

    if (userId == null) return;

    setState(() => _isLoading = true);

    // Load user data from Firestore
    final userData = await profileService.getUserData(userId);

    // Load PIN security settings
    final pinEnabled = await _pinService.isPinEnabled();
    final hasPinSet = await _pinService.hasPinSet();

    if (userData != null && mounted) {
      setState(() {
        _nameController.text = userData.displayName;
        _phoneController.text = userData.profile?.phoneNumber ?? '';
        _bioController.text = userData.profile?.bio ?? '';
        _currentAvatarUrl = userData.photoUrl;
        _selectedLearningAim = userData.profile?.learningAim;

        // Settings
        _notificationsEnabled = userData.settings.notificationsEnabled;
        _soundEnabled = userData.settings.soundEnabled;
        _darkModeEnabled = userData.settings.darkModeEnabled;
        _languagePreference = userData.settings.languagePreference;
        _dailyGoal = userData.settings.dailyGoal;

        // PIN Security
        _pinEnabled = pinEnabled;
        _hasPinSet = hasPinSet;

        _isLoading = false;
      });
    } else {
      // Load from Firebase Auth if Firestore data doesn't exist
      final user = authService.currentUser;
      if (user != null && mounted) {
        setState(() {
          _nameController.text = user.displayName ?? '';
          _currentAvatarUrl = user.photoURL;
          _pinEnabled = pinEnabled;
          _hasPinSet = hasPinSet;
          _isLoading = false;
        });

        // Create initial user document in Firestore if it doesn't exist
        try {
          await authService.loadUserData();
        } catch (e) {
          // Ignore error, document will be created on first save
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final profileService =
        Provider.of<UserProfileService>(context, listen: false);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      _showMessage('No user logged in', isError: true);
      return;
    }

    // Upload avatar if new image selected
    String? newAvatarUrl = _currentAvatarUrl;
    if (_selectedImageFile != null) {
      setState(() => _isUploadingAvatar = true);
      try {
        newAvatarUrl = await _avatarUploadService.uploadAvatar(
          userId: userId,
          imageFile: _selectedImageFile!,
        );

        // Immediately update the UI with new avatar URL
        if (mounted) {
          setState(() {
            _currentAvatarUrl = newAvatarUrl;
            _selectedImageFile = null;
            _isUploadingAvatar = false;
          });
          debugPrint('✅ Avatar uploaded! New URL: $newAvatarUrl');
        }

        // Delete old avatar if exists
        if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty && _currentAvatarUrl != newAvatarUrl) {
          await _avatarUploadService.deleteOldAvatar(_currentAvatarUrl!);
        }
      } catch (e) {
        if (mounted) {
          _showMessage('Failed to upload avatar: $e', isError: true);
          setState(() => _isUploadingAvatar = false);
        }
        return;
      }
    }

    debugPrint('📝 Saving profile to Firestore with photoUrl: $newAvatarUrl');
    final success = await profileService.updateProfile(
      userId: userId,
      displayName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      bio: _bioController.text.trim().isNotEmpty
          ? _bioController.text.trim()
          : null,
      photoUrl: newAvatarUrl,
      learningAim: _selectedLearningAim,
    );

    if (mounted) {
      if (success) {
        debugPrint('✅ Profile saved to Firestore successfully!');
        _showMessage('Profile updated successfully!');
        // Reload user data to sync with Firestore and notify all listeners
        debugPrint('🔄 Reloading user data from Firestore...');
        await authService.loadUserData();
        debugPrint('✅ User data reloaded! photoUrl: ${authService.currentUserData?.photoUrl}');
      } else {
        debugPrint('❌ Failed to save profile: ${profileService.errorMessage}');
        _showMessage(
          profileService.errorMessage ?? 'Failed to update profile',
          isError: true,
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final profileService =
        Provider.of<UserProfileService>(context, listen: false);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      _showMessage('No user logged in', isError: true);
      return;
    }

    final success = await profileService.updateSettings(
      userId: userId,
      notificationsEnabled: _notificationsEnabled,
      soundEnabled: _soundEnabled,
      darkModeEnabled: _darkModeEnabled,
      languagePreference: _languagePreference,
      dailyGoal: _dailyGoal,
    );

    if (mounted) {
      if (success) {
        _showMessage('Settings updated successfully!');
      } else {
        _showMessage(
          profileService.errorMessage ?? 'Failed to update settings',
          isError: true,
        );
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ==================== AVATAR PICKER ====================

  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryBlue),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryBlue),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            if (_currentAvatarUrl != null || _selectedImageFile != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.errorRed),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _removeAvatar();
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final imageFile = await _avatarUploadService.pickImageFromGallery();
      if (imageFile != null) {
        setState(() {
          _selectedImageFile = imageFile;
        });
      }
    } catch (e) {
      _showMessage('Failed to pick image: $e', isError: true);
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final imageFile = await _avatarUploadService.pickImageFromCamera();
      if (imageFile != null) {
        setState(() {
          _selectedImageFile = imageFile;
        });
      }
    } catch (e) {
      _showMessage('Failed to take photo: $e', isError: true);
    }
  }

  void _removeAvatar() {
    setState(() {
      _selectedImageFile = null;
      _currentAvatarUrl = null;
    });
  }

  // ==================== PIN SECURITY ====================

  Future<void> _setupOrChangePin() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PinSetupScreen(isChanging: _hasPinSet),
      ),
    );

    if (result == true) {
      // Reload PIN status
      final pinEnabled = await _pinService.isPinEnabled();
      final hasPinSet = await _pinService.hasPinSet();
      setState(() {
        _pinEnabled = pinEnabled;
        _hasPinSet = hasPinSet;
      });
    }
  }

  Future<void> _togglePinEnabled(bool value) async {
    if (value && !_hasPinSet) {
      // User wants to enable PIN but hasn't set one up yet
      _showMessage('Please set up a PIN first', isError: true);
      return;
    }

    if (value) {
      await _pinService.enablePin();
    } else {
      await _pinService.disablePin();
    }

    setState(() {
      _pinEnabled = value;
    });

    _showMessage(
      value ? 'PIN authentication enabled' : 'PIN authentication disabled',
    );
  }

  Future<void> _deletePin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.warningYellow),
            SizedBox(width: 12),
            Text('Delete PIN?'),
          ],
        ),
        content: const Text(
          'This will permanently remove your PIN. You will need to set up a new one if you want to use PIN authentication again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _pinService.deletePin();
      setState(() {
        _pinEnabled = false;
        _hasPinSet = false;
      });
      if (mounted) {
        _showMessage('PIN deleted successfully');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: AppTheme.textDark),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textGrey,
          indicatorColor: AppTheme.primaryBlue,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(user),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  // ==================== PROFILE TAB ====================
  Widget _buildProfileTab(dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar
            Center(
              child: GestureDetector(
                onTap: _showImageSourceOptions,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.paleBlue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryBlue,
                          width: 4,
                        ),
                        image: _selectedImageFile != null
                            ? DecorationImage(
                                image: FileImage(_selectedImageFile!),
                                fit: BoxFit.cover,
                              )
                            : _currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(_currentAvatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: (_selectedImageFile == null &&
                             (_currentAvatarUrl == null || _currentAvatarUrl!.isEmpty))
                          ? Center(
                              child: Text(
                                user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            )
                          : null,
                    ),
                    if (_isUploadingAvatar)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Email (Read-only)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.paleBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: AppTheme.primaryBlue),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Display Name
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                if (value.trim().length < 2) {
                  return 'Name is too short';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+84 xxx xxx xxx',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell us about yourself...',
                prefixIcon: Icon(Icons.edit_note),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Learning Aim Section
            const Text(
              'Learning Aim',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'What\'s your main goal for learning English?',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textGrey,
              ),
            ),
            const SizedBox(height: 16),

            // Learning Aim Options
            _buildLearningAimOption(
              'pronunciation',
              'Pronunciation',
              Icons.record_voice_over,
              'Master English pronunciation',
            ),
            _buildLearningAimOption(
              'communication',
              'Communication',
              Icons.chat_bubble_outline,
              'Improve daily conversation',
            ),
            _buildLearningAimOption(
              'toeic',
              'TOEIC',
              Icons.school_outlined,
              'Prepare for TOEIC exam',
            ),
            _buildLearningAimOption(
              'ielts',
              'IELTS',
              Icons.military_tech,
              'Prepare for IELTS exam',
            ),
            _buildLearningAimOption(
              'business',
              'Business',
              Icons.business_center,
              'Business English skills',
            ),
            _buildLearningAimOption(
              'travel',
              'Travel',
              Icons.flight_takeoff,
              'English for traveling',
            ),
            const SizedBox(height: 24),

            // Save Button
            Consumer<UserProfileService>(
              builder: (context, profileService, child) {
                return ElevatedButton(
                  onPressed: profileService.isLoading ? null : _saveProfile,
                  child: profileService.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save Changes'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SETTINGS TAB ====================
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),

          // Notifications
          _buildSettingTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Receive daily reminders',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),

          // Sound
          _buildSettingTile(
            icon: Icons.volume_up_outlined,
            title: 'Sound Effects',
            subtitle: 'Play sounds during lessons',
            trailing: Switch(
              value: _soundEnabled,
              onChanged: (value) {
                setState(() => _soundEnabled = value);
              },
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),

          // Dark Mode
          _buildSettingTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Switch to dark theme',
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() => _darkModeEnabled = value);
              },
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),

          const Divider(height: 32),

          // ==================== PIN SECURITY ====================
          const Text(
            'Security',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),

          // PIN Toggle
          _buildSettingTile(
            icon: Icons.lock_outline,
            title: 'PIN Authentication',
            subtitle: _hasPinSet
                ? (_pinEnabled ? 'Enabled' : 'Disabled')
                : 'Not set up',
            trailing: Switch(
              value: _pinEnabled,
              onChanged: _togglePinEnabled,
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),

          // PIN Setup/Change Button
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton.icon(
              onPressed: _setupOrChangePin,
              icon: Icon(_hasPinSet ? Icons.edit : Icons.add),
              label: Text(_hasPinSet ? 'Change PIN' : 'Set Up PIN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),

          // Delete PIN Button (only show if PIN exists)
          if (_hasPinSet)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: _deletePin,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete PIN'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorRed,
                  side: const BorderSide(color: AppTheme.errorRed, width: 2),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),

          const Divider(height: 32),

          const Text(
            'Learning Goals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),

          // Daily Goal
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.paleBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: AppTheme.warningYellow),
                    const SizedBox(width: 12),
                    const Text(
                      'Daily XP Goal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '$_dailyGoal XP per day',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _dailyGoal.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 9,
                  label: '$_dailyGoal XP',
                  activeColor: AppTheme.primaryBlue,
                  onChanged: (value) {
                    setState(() => _dailyGoal = value.toInt());
                  },
                ),
                const Text(
                  'Slide to set your daily learning goal',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          const Text(
            'Language',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),

          // Language Selection
          _buildLanguageOption('en', 'English', '🇺🇸'),
          _buildLanguageOption('vi', 'Tiếng Việt', '🇻🇳'),
          _buildLanguageOption('es', 'Español', '🇪🇸'),
          _buildLanguageOption('fr', 'Français', '🇫🇷'),

          const SizedBox(height: 32),

          // Save Settings Button
          Consumer<UserProfileService>(
            builder: (context, profileService, child) {
              return ElevatedButton(
                onPressed: profileService.isLoading ? null : _saveSettings,
                child: profileService.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save Settings'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag) {
    final isSelected = _languagePreference == code;

    return GestureDetector(
      onTap: () {
        setState(() => _languagePreference = code);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.paleBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryBlue,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningAimOption(
    String value,
    String title,
    IconData icon,
    String description,
  ) {
    final isSelected = _selectedLearningAim == value;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedLearningAim = value);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.paleBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryBlue.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryBlue,
              ),
          ],
        ),
      ),
    );
  }
}
