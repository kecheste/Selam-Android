import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/auth.dart';
import 'package:selam/presentation/screens/auth/login.dart';
import 'package:selam/presentation/widgets/buttons/rectangular_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class SettingsScreen extends StatefulWidget {
  final MyUser user;

  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AuthRepository authRepository = AuthRepository();

  bool _isAppLockEnabled = false;
  bool _isFingerprintEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadAppLockSettings();
  }

  Future<void> _loadAppLockSettings() async {
    final storedPasscode = await _secureStorage.read(key: 'user_passcode');
    final isFingerprintEnabled =
        await _secureStorage.read(key: 'is_fingerprint_enabled');
    setState(() {
      _isAppLockEnabled = storedPasscode != null && storedPasscode.isNotEmpty;
      _isFingerprintEnabled = isFingerprintEnabled == 'true';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('App Lock'),
            _buildSwitchTile(
              title: 'Enable App Lock',
              value: _isAppLockEnabled,
              onChanged: (bool value) async {
                if (value) {
                  final passcode = await _showSetPasscodeDialog(context);
                  if (passcode != null && passcode.isNotEmpty) {
                    await _secureStorage.write(
                        key: 'user_passcode', value: passcode);
                    setState(() {
                      _isAppLockEnabled = true;
                    });
                  }
                } else {
                  await _secureStorage.delete(key: 'user_passcode');
                  await _secureStorage.delete(key: 'is_fingerprint_enabled');
                  setState(() {
                    _isAppLockEnabled = false;
                    _isFingerprintEnabled = false;
                  });
                }
              },
            ),
            if (_isAppLockEnabled) ...[
              _buildSwitchTile(
                title: 'Enable Fingerprint',
                value: _isFingerprintEnabled,
                onChanged: (bool value) async {
                  if (value) {
                    final canAuthenticate = await _checkBiometrics();
                    if (canAuthenticate) {
                      await _secureStorage.write(
                          key: 'is_fingerprint_enabled', value: 'true');
                      setState(() {
                        _isFingerprintEnabled = true;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Fingerprint not available')),
                      );
                    }
                  } else {
                    await _secureStorage.write(
                        key: 'is_fingerprint_enabled', value: 'false');
                    setState(() {
                      _isFingerprintEnabled = false;
                    });
                  }
                },
              ),
              _buildListTile(
                title: 'Change Passcode',
                icon: Icons.lock,
                onTap: () async {
                  final newPasscode = await _showSetPasscodeDialog(context);
                  if (newPasscode != null && newPasscode.isNotEmpty) {
                    await _secureStorage.write(
                        key: 'user_passcode', value: newPasscode);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Passcode updated successfully!')),
                    );
                  }
                },
              ),
            ],
            const SizedBox(height: 20),

            _buildSectionHeader('Notifications'),
            _buildSwitchTile(
              title: 'Enable Notifications',
              value: true,
              onChanged: (bool value) {
                // Add logic to enable/disable notifications
              },
            ),
            const SizedBox(height: 20),

            // Device Settings
            _buildSectionHeader('Device Settings'),
            _buildListTile(
              title: 'Sound & Vibration',
              icon: Icons.volume_up,
              onTap: () {
                // Add logic for sound and vibration settings
              },
            ),
            _buildListTile(
              title: 'Storage Usage',
              icon: Icons.storage,
              onTap: () {
                // Add logic for storage usage settings
              },
            ),
            const SizedBox(height: 20),

            // Privacy Settings
            _buildSectionHeader('Privacy'),
            _buildSwitchTile(
              title: 'Private Account',
              value: false,
              onChanged: (bool value) {
                // Add logic to toggle private account
              },
            ),
            _buildListTile(
              title: 'Blocked Users',
              icon: Icons.block,
              onTap: () {
                // Add logic to view blocked users
              },
            ),
            const SizedBox(height: 20),

            // Theme Settings
            _buildSectionHeader('Appearance'),
            _buildSwitchTile(
              title: 'Dark Mode',
              value: false,
              onChanged: (bool value) {
                // Add logic to toggle dark mode
              },
            ),
            const SizedBox(height: 20),

            // Account Settings
            _buildSectionHeader('Account'),
            _buildListTile(
              title: 'Delete Account',
              icon: Icons.delete,
              onTap: () {
                // Add logic to delete account
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: rectangularButton(
                context,
                const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                () => _showLogoutConfirmationDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      leading: const Icon(Icons.notifications, color: Colors.white),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.pinkAccent,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      leading: Icon(icon, color: Colors.white),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to logout?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                await authRepository.signOut();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully!')),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showSetPasscodeDialog(BuildContext context) async {
    String? passcode;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title:
              const Text('Set Passcode', style: TextStyle(color: Colors.white)),
          content: PinCodeTextField(
            appContext: context,
            length: 4,
            obscureText: true,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(5),
              fieldHeight: 50,
              fieldWidth: 40,
              activeFillColor: Colors.black,
              inactiveFillColor: Colors.black,
              selectedFillColor: Colors.black,
              activeColor: Colors.pinkAccent,
              inactiveColor: Colors.grey,
              selectedColor: Colors.pinkAccent,
            ),
            animationDuration: const Duration(milliseconds: 300),
            enableActiveFill: true,
            onCompleted: (value) {
              passcode = value;
              Navigator.pop(context);
            },
            onChanged: (value) {},
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    return passcode;
  }

  Future<bool> _checkBiometrics() async {
    final canAuthenticate = await _localAuth.canCheckBiometrics;
    return canAuthenticate;
  }
}
