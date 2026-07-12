import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/app_user.dart';
import '../../data/models/startup_profile_model.dart';
import '../cubit/startup_cubit.dart';
import '../cubit/startup_state.dart';

class CreateStartupProfileScreen extends StatefulWidget {
  final AppUser user;
  final StartupProfileModel? existingProfile;

  const CreateStartupProfileScreen({
    required this.user,
    this.existingProfile,
    super.key,
  });

  @override
  State<CreateStartupProfileScreen> createState() =>
      _CreateStartupProfileScreenState();
}

class _CreateStartupProfileScreenState
    extends State<CreateStartupProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _startupNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _recognitionReferenceController;
  late final TextEditingController _websiteController;

  late String _industry;
  late String _ventureStage;
  late String _recognitionType;

  bool _isSubmitting = false;

  final _industries = const [
    'Technology',
    'Education',
    'Agriculture',
    'Health',
    'Financial Services',
    'Creative Industries',
    'Climate and Sustainability',
    'Other',
  ];

  final _ventureStages = const [
    'Idea',
    'Prototype',
    'Early operations',
    'Early revenue',
    'Growth',
  ];

  final _recognitionTypes = const [
    'ALU Venture Lab',
    'ALU club or society',
    'ALU course project',
    'Staff or faculty endorsement',
    'Other ALU recognition',
  ];

  @override
  void initState() {
    super.initState();

    final profile = widget.existingProfile;

    _startupNameController = TextEditingController(
      text: profile?.startupName ?? '',
    );

    _descriptionController = TextEditingController(
      text: profile?.description ?? '',
    );

    _recognitionReferenceController = TextEditingController(
      text: profile?.recognitionReference ?? '',
    );

    _websiteController = TextEditingController(
      text: profile?.website ?? '',
    );

    _industry = profile?.industry.isNotEmpty == true
        ? profile!.industry
        : _industries.first;

    _ventureStage = profile?.ventureStage.isNotEmpty == true
        ? profile!.ventureStage
        : _ventureStages.first;

    _recognitionType = profile?.recognitionType.isNotEmpty == true
        ? profile!.recognitionType
        : _recognitionTypes.first;
  }

  @override
  void dispose() {
    _startupNameController.dispose();
    _descriptionController.dispose();
    _recognitionReferenceController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await context.read<StartupCubit>().submitProfile(
          owner: widget.user,
          startupName: _startupNameController.text,
          description: _descriptionController.text,
          industry: _industry,
          ventureStage: _ventureStage,
          recognitionType: _recognitionType,
          recognitionReference:
              _recognitionReferenceController.text,
          website: _websiteController.text,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Startup profile submitted for verification.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isResubmission =
        widget.existingProfile?.isRejected == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isResubmission
              ? 'Update Startup Profile'
              : 'Create Startup Profile',
        ),
      ),
      body: BlocListener<StartupCubit, StartupState>(
        listener: (context, state) {
          if (state is StartupFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              12,
              24,
              32,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ALU startup verification',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Only recognized ALU student ventures can publish opportunities.',
                    style: TextStyle(
                      height: 1.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _startupNameController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Startup name',
                      prefixIcon:
                          Icon(Icons.rocket_launch_outlined),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().length < 2) {
                        return 'Enter the startup name.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 7,
                    decoration: const InputDecoration(
                      labelText: 'Startup description',
                      hintText:
                          'Explain the problem, solution, and users served.',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().length < 40) {
                        return 'Write at least 40 characters.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _industry,
                    decoration: const InputDecoration(
                      labelText: 'Industry',
                      prefixIcon:
                          Icon(Icons.category_outlined),
                    ),
                    items: _industries.map((industry) {
                      return DropdownMenuItem<String>(
                        value: industry,
                        child: Text(industry),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _industry = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _ventureStage,
                    decoration: const InputDecoration(
                      labelText: 'Venture stage',
                      prefixIcon:
                          Icon(Icons.trending_up_outlined),
                    ),
                    items: _ventureStages.map((stage) {
                      return DropdownMenuItem<String>(
                        value: stage,
                        child: Text(stage),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _ventureStage = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _recognitionType,
                    decoration: const InputDecoration(
                      labelText: 'ALU recognition type',
                      prefixIcon:
                          Icon(Icons.verified_outlined),
                    ),
                    items:
                        _recognitionTypes.map((recognition) {
                      return DropdownMenuItem<String>(
                        value: recognition,
                        child: Text(recognition),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _recognitionType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller:
                        _recognitionReferenceController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Recognition reference',
                      hintText:
                          'Example: Venture Lab Cohort 2026, faculty name, or ALU programme reference.',
                      alignLabelWithHint: true,
                      prefixIcon:
                          Icon(Icons.badge_outlined),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().length < 5) {
                        return 'Provide an ALU recognition reference.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _websiteController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Website or social page',
                      hintText: 'Optional',
                      prefixIcon: Icon(Icons.language),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed:
                        _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isResubmission
                                ? 'Resubmit for verification'
                                : 'Submit for verification',
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
}