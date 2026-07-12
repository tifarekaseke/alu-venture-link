import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/app_user.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class EditStudentProfileScreen extends StatefulWidget {
  final AppUser user;

  const EditStudentProfileScreen({required this.user, super.key});

  @override
  State<EditStudentProfileScreen> createState() =>
      _EditStudentProfileScreenState();
}

class _EditStudentProfileScreenState extends State<EditStudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _campusController;
  late final TextEditingController _programController;
  late final TextEditingController _bioController;
  late final TextEditingController _skillsController;
  late final TextEditingController _availabilityController;
  late final TextEditingController _portfolioController;
  late final TextEditingController _linkedInController;
  late final TextEditingController _githubController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.user.fullName);

    _campusController = TextEditingController(text: widget.user.campus);

    _programController = TextEditingController(text: widget.user.program);

    _bioController = TextEditingController(text: widget.user.bio);

    _skillsController = TextEditingController(
      text: widget.user.skills.join(', '),
    );

    _availabilityController = TextEditingController(
      text: widget.user.availabilityHours > 0
          ? widget.user.availabilityHours.toString()
          : '',
    );

    _portfolioController = TextEditingController(
      text: widget.user.portfolioUrl,
    );

    _linkedInController = TextEditingController(text: widget.user.linkedInUrl);

    _githubController = TextEditingController(text: widget.user.githubUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _campusController.dispose();
    _programController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _availabilityController.dispose();
    _portfolioController.dispose();
    _linkedInController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  List<String> _parseSkills(String value) {
    return value
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();
  }

  String? _validateOptionalUrl(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(text);

    if (uri == null ||
        !uri.hasScheme ||
        !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return 'Use a full link beginning with http:// or https://';
    }

    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final availability = int.tryParse(_availabilityController.text.trim()) ?? 0;

    context.read<ProfileCubit>().updateStudentProfile(
      userId: widget.user.uid,
      fullName: _nameController.text,
      campus: _campusController.text,
      program: _programController.text,
      bio: _bioController.text,
      skills: _parseSkills(_skillsController.text),
      availabilityHours: availability,
      portfolioUrl: _portfolioController.text,
      linkedInUrl: _linkedInController.text,
      githubUrl: _githubController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Student Profile')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully.')),
            );

            context.read<ProfileCubit>().reset();
            Navigator.of(context).pop();
          }

          if (state is ProfileFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isSaving = state is ProfileSaving;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Build your opportunity profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your skills and availability help startups understand whether you are a good match.',
                      style: TextStyle(
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 26),

                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'Enter your full name.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _programController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Academic program',
                        hintText: 'Example: Software Engineering',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'Enter your academic program.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _campusController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Campus',
                        hintText: 'Example: ALU Rwanda',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'Enter your campus.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _bioController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Professional bio',
                        hintText:
                            'Describe your interests, experience, and the value you can contribute.',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 30) {
                          return 'Write at least 30 characters.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(
                        labelText: 'Skills',
                        hintText: 'Flutter, Firebase, UI Design',
                        prefixIcon: Icon(Icons.auto_awesome_outlined),
                      ),
                      validator: (value) {
                        if (_parseSkills(value ?? '').isEmpty) {
                          return 'Enter at least one skill.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _availabilityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Available hours per week',
                        prefixIcon: Icon(Icons.schedule_outlined),
                      ),
                      validator: (value) {
                        final hours = int.tryParse(value?.trim() ?? '');

                        if (hours == null || hours < 1 || hours > 60) {
                          return 'Enter a value between 1 and 60.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _portfolioController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Portfolio link',
                        hintText: 'Optional',
                        prefixIcon: Icon(Icons.language_outlined),
                      ),
                      validator: _validateOptionalUrl,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _linkedInController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'LinkedIn link',
                        hintText: 'Optional',
                        prefixIcon: Icon(Icons.business_center_outlined),
                      ),
                      validator: _validateOptionalUrl,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _githubController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'GitHub link',
                        hintText: 'Optional',
                        prefixIcon: Icon(Icons.code),
                      ),
                      validator: _validateOptionalUrl,
                    ),

                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: isSaving ? null : _submit,
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save profile'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
