import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../components/animated_background.dart';
import '../../../core/models/beneficiary_model.dart';
import '../../../core/services/data_service.dart';

class BeneficiaryFormPage extends StatefulWidget {
  const BeneficiaryFormPage({super.key});

  @override
  State<BeneficiaryFormPage> createState() => _BeneficiaryFormPageState();
}

class _BeneficiaryFormPageState extends State<BeneficiaryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _aadhaarCtrl;
  late TextEditingController _bankCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _fatherNameCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _genderCtrl;
  late TextEditingController _maritalStatusCtrl;
  late TextEditingController _ifscCtrl;
  late TextEditingController _scStCertificateCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _aadhaarCtrl = TextEditingController();
    _bankCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _categoryCtrl = TextEditingController();
    _fatherNameCtrl = TextEditingController();
    _districtCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
    _genderCtrl = TextEditingController();
    _maritalStatusCtrl = TextEditingController();
    _ifscCtrl = TextEditingController();
    _scStCertificateCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _aadhaarCtrl.dispose();
    _bankCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _categoryCtrl.dispose();
    _fatherNameCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    _ageCtrl.dispose();
    _genderCtrl.dispose();
    _maritalStatusCtrl.dispose();
    _ifscCtrl.dispose();
    _scStCertificateCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBeneficiary() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final random = Random();
      final randomId =
          '${random.nextInt(900000000) + 100000000}${random.nextInt(10000) + 1000}';

      final beneficiary = BeneficiaryModel(
        id: 'BEN$randomId',
        name: _nameCtrl.text.trim(),
        aadhaar: _aadhaarCtrl.text.trim(),
        bankAccount: _bankCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        fatherName: _fatherNameCtrl.text.trim(),
        district: _districtCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text.trim()),
        gender: _genderCtrl.text.trim(),
        maritalStatus: _maritalStatusCtrl.text.trim(),
        ifsc: _ifscCtrl.text.trim(),
        scStCertificate: _scStCertificateCtrl.text.trim(),
        ownerId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        registrationDate: DateTime.now(),
        status: 'pending-verification',
      );

      await DataService.createBeneficiary(beneficiary);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Beneficiary profile created successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating beneficiary: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Add Beneficiary')),
      body: Stack(
        children: [
          AnimatedBackground(isDark: isDark),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.24),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(18),
                        children: [
                          Text(
                            'Personal Details',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _field(
                            controller: _nameCtrl,
                            label: 'Full Name',
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _fatherNameCtrl,
                            label: 'Father\'s Name',
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Father\'s name is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _aadhaarCtrl,
                            label: 'Aadhaar Number',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Aadhaar is required';
                              if (value!.length != 12) {
                                return 'Aadhaar must be 12 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _twoColumnFields(
                            context,
                            first: _field(
                              controller: _phoneCtrl,
                              label: 'Phone Number',
                              keyboardType: TextInputType.phone,
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Phone is required'
                                  : null,
                            ),
                            second: _field(
                              controller: _ageCtrl,
                              label: 'Age',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Age is required';
                                final age = int.tryParse(value!);
                                if (age == null || age < 0 || age > 120) {
                                  return 'Enter a valid age';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _twoColumnFields(
                            context,
                            first: _field(
                              controller: _genderCtrl,
                              label: 'Gender',
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Gender is required'
                                  : null,
                            ),
                            second: _field(
                              controller: _maritalStatusCtrl,
                              label: 'Marital Status',
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Marital status is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Address and Identity',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _field(
                            controller: _addressCtrl,
                            label: 'Address',
                            maxLines: 3,
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Address is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _twoColumnFields(
                            context,
                            first: _field(
                              controller: _districtCtrl,
                              label: 'District',
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'District is required'
                                  : null,
                            ),
                            second: _field(
                              controller: _stateCtrl,
                              label: 'State',
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'State is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _categoryCtrl,
                            label: 'Category',
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Category is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _scStCertificateCtrl,
                            label: 'SC/ST Certificate URL',
                            hint: 'https://example.com/certificate.pdf',
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'SC/ST Certificate URL is required';
                              }
                              final urlPattern = RegExp(
                                r'^https?://[^\s/$.?#].[^\s]*$',
                              );
                              if (!urlPattern.hasMatch(value!)) {
                                return 'Enter a valid URL';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Bank Details',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _field(
                            controller: _bankCtrl,
                            label: 'Bank Account Number',
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Bank account is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _ifscCtrl,
                            label: 'IFSC Code',
                            validator: (value) => value?.isEmpty ?? true
                                ? 'IFSC code is required'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _saving ? null : _saveBeneficiary,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(
                                _saving
                                    ? 'Creating profile...'
                                    : 'Create Beneficiary Profile',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
    );
  }

  Widget _twoColumnFields(
    BuildContext context, {
    required Widget first,
    required Widget second,
  }) {
    if (MediaQuery.of(context).size.width < 680) {
      return Column(
        children: [
          first,
          const SizedBox(height: 12),
          second,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }
}
