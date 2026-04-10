import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/settings_service.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsService>(context, listen: false);
    _phoneController = TextEditingController(text: settings.phone ?? '');
    _emailController = TextEditingController(text: settings.email ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<SettingsService>(context, listen: false)
          .saveBusinessDetails(_phoneController.text, _emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business details saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving details: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickLogo() async {
    setState(() => _isLoading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        await Provider.of<SettingsService>(context, listen: false).setLogoPath(path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logo updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeLogo() async {
    await Provider.of<SettingsService>(context, listen: false).clearLogo();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo removed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 30),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Logo',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This logo will appear on your Invoices and Quotations.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            image: settings.logoPath != null
                                ? DecorationImage(
                                    image: FileImage(File(settings.logoPath!)),
                                    fit: BoxFit.contain,
                                  )
                                : null,
                          ),
                          child: settings.logoPath == null
                              ? const Icon(Icons.image, size: 40, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _pickLogo,
                              icon: const Icon(Icons.upload),
                              label: const Text('Upload Logo'),
                            ),
                            const SizedBox(height: 10),
                            if (settings.logoPath != null)
                              TextButton.icon(
                                onPressed: _isLoading ? null : _removeLogo,
                                icon: const Icon(Icons.delete, color: AppTheme.dangerColor),
                                label: const Text('Remove Logo', style: TextStyle(color: AppTheme.dangerColor)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'These details will appear on your Invoices and Quotations.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Business Phone Number',
                        hintText: 'e.g., 071 234 5678',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Business Email',
                        hintText: 'e.g., info@etech.com',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveDetails,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Details'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
