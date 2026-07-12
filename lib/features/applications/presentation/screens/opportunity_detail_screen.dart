import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../opportunities/data/models/opportunity_model.dart';
import '../cubit/application_cubit.dart';
import '../cubit/application_state.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final AppUser student;
  final OpportunityModel opportunity;

  const OpportunityDetailScreen({
    required this.student,
    required this.opportunity,
    super.key,
  });

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await context.read<ApplicationCubit>().submitApplication(
          student: widget.student,
          opportunity: widget.opportunity,
          coverLetter: _coverLetterController.text,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deadlineText = widget.opportunity.deadline == null
        ? 'No deadline'
        : DateFormat('dd MMM yyyy').format(widget.opportunity.deadline!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity Details'),
      ),
      body: BlocListener<ApplicationCubit, ApplicationState>(
        listener: (context, state) {
          if (state is ApplicationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is ApplicationActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );

            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.navy,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.rocket_launch_outlined,
                      color: AppTheme.gold,
                      size: 34,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.opportunity.title,
                      style: const TextStyle(
                        fontSize: 26,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.opportunity.startupName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _InfoRow(
                icon: Icons.category_outlined,
                label: 'Type',
                value: widget.opportunity.opportunityType,
              ),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Work mode',
                value: widget.opportunity.workMode,
              ),
              _InfoRow(
                icon: Icons.schedule_outlined,
                label: 'Hours',
                value: '${widget.opportunity.hoursPerWeek} hours/week',
              ),
              _InfoRow(
                icon: Icons.calendar_month_outlined,
                label: 'Deadline',
                value: deadlineText,
              ),
              const SizedBox(height: 22),
              const Text(
                'Role description',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.opportunity.description,
                style: const TextStyle(
                  height: 1.55,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Required skills',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.opportunity.requiredSkills
                    .map(
                      (skill) => Chip(
                        label: Text(skill),
                        backgroundColor: const Color(0xFFFFF7D6),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 28),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _coverLetterController,
                  minLines: 5,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Why are you interested?',
                    hintText:
                        'Briefly explain your skills, interest, and availability.',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 30) {
                      return 'Write at least 30 characters.';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.navy),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}