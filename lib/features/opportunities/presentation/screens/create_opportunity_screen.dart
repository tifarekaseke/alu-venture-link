import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/app_user.dart';
import '../cubit/opportunity_cubit.dart';

class CreateOpportunityScreen extends StatefulWidget {
  final AppUser user;
  final String startupName;

  const CreateOpportunityScreen({
    required this.user,
    required this.startupName,
    super.key,
  });

  @override
  State<CreateOpportunityScreen> createState() =>
      _CreateOpportunityScreenState();
}

class _CreateOpportunityScreenState extends State<CreateOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillsController = TextEditingController();
  final _hoursController = TextEditingController(text: '8');

  String _opportunityType = 'Internship';
  String _workMode = 'On-campus';

  DateTime _deadline = DateTime.now().add(const Duration(days: 14));

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _deadline = selectedDate;
    });
  }

  List<String> _parseSkills(String input) {
    return input
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await context.read<OpportunityCubit>().createOpportunity(
      ownerId: widget.user.uid,
      startupName: widget.startupName,
      title: _titleController.text,
      description: _descriptionController.text,
      requiredSkills: _parseSkills(_skillsController.text),
      opportunityType: _opportunityType,
      workMode: _workMode,
      hoursPerWeek: _hoursController.text,
      deadline: _deadline,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opportunity created successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deadlineText = DateFormat('dd MMM yyyy').format(_deadline);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Opportunity')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Post a role for ALU students',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This opportunity will be posted under ${widget.startupName}.',
                  style: const TextStyle(
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 26),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Role title',
                    hintText: 'Example: Flutter Developer Intern',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Enter a clear role title.';
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
                    labelText: 'Description',
                    hintText: 'Explain what the student will do and learn.',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 20) {
                      return 'Write at least 20 characters.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _skillsController,
                  decoration: const InputDecoration(
                    labelText: 'Required skills',
                    hintText: 'Flutter, Firebase, UI Design',
                    prefixIcon: Icon(Icons.auto_awesome),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Add at least one skill.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _opportunityType,
                  decoration: const InputDecoration(
                    labelText: 'Opportunity type',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Internship',
                      child: Text('Internship'),
                    ),
                    DropdownMenuItem(
                      value: 'Volunteer',
                      child: Text('Volunteer'),
                    ),
                    DropdownMenuItem(
                      value: 'Project-based',
                      child: Text('Project-based'),
                    ),
                    DropdownMenuItem(
                      value: 'Part-time',
                      child: Text('Part-time'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _opportunityType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _workMode,
                  decoration: const InputDecoration(
                    labelText: 'Work mode',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'On-campus',
                      child: Text('On-campus'),
                    ),
                    DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                    DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _workMode = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Hours per week',
                    prefixIcon: Icon(Icons.schedule_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter expected weekly hours.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDeadline,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Application deadline',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    child: Text(deadlineText),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Publish opportunity'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
