import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/application_model.dart';
import '../cubit/application_cubit.dart';
import '../cubit/application_state.dart';

class ScheduleInterviewScreen
    extends StatefulWidget {
  final ApplicationModel application;

  const ScheduleInterviewScreen({
    required this.application,
    super.key,
  });

  @override
  State<ScheduleInterviewScreen> createState() =>
      _ScheduleInterviewScreenState();
}

class _ScheduleInterviewScreenState
    extends State<ScheduleInterviewScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  late final TextEditingController
      _locationController;

  late final TextEditingController
      _notesController;

  String _interviewMode = 'Google Meet';
  bool _isSaving = false;

  final _modes = const [
    'Google Meet',
    'Microsoft Teams',
    'Zoom',
    'In-person',
    'Phone call',
  ];

  @override
  void initState() {
    super.initState();

    final existingDate =
        widget.application.interviewDateTime;

    final initialDate = existingDate ??
        DateTime.now().add(
          const Duration(days: 1),
        );

    _selectedDate = DateTime(
      initialDate.year,
      initialDate.month,
      initialDate.day,
    );

    _selectedTime = TimeOfDay.fromDateTime(
      initialDate,
    );

    final existingMode =
        widget.application.interviewMode;

    if (_modes.contains(existingMode)) {
      _interviewMode = existingMode;
    }

    _locationController =
        TextEditingController(
      text: widget
          .application.interviewLocationOrLink,
    );

    _notesController = TextEditingController(
      text: widget.application.interviewNotes,
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DateTime get _combinedDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedDate = selected;
    });
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedTime = selected;
    });
  }

  String get _locationLabel {
    switch (_interviewMode) {
      case 'In-person':
        return 'Interview location';

      case 'Phone call':
        return 'Phone number or instructions';

      default:
        return 'Meeting link';
    }
  }

  String get _locationHint {
    switch (_interviewMode) {
      case 'In-person':
        return 'Example: ALU Campus, Room 204';

      case 'Phone call':
        return 'Example: The startup will call your registered number';

      default:
        return 'Example: https://meet.google.com/...';
    }
  }

  Future<void> _saveInterview() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final interviewDateTime =
        _combinedDateTime;

    if (interviewDateTime.isBefore(
      DateTime.now(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Choose a future interview date and time.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await context
        .read<ApplicationCubit>()
        .scheduleInterview(
          applicationId:
              widget.application.id,
          interviewDateTime:
              interviewDateTime,
          interviewMode: _interviewMode,
          locationOrLink:
              _locationController.text,
          notes: _notesController.text,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (!success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Interview scheduled for ${widget.application.studentName}.',
        ),
      ),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateText =
        DateFormat('EEE, dd MMM yyyy')
            .format(_selectedDate);

    final selectedTimeText =
        _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.application.hasInterview
              ? 'Update Interview'
              : 'Schedule Interview',
        ),
      ),
      body: BlocListener<
          ApplicationCubit,
          ApplicationState>(
        listener: (context, state) {
          if (state is ApplicationFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              16,
              24,
              32,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius:
                          BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.video_call_outlined,
                          color: AppTheme.gold,
                          size: 32,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.application
                              .opportunityTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Candidate: ${widget.application.studentName}',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          widget.application.studentEmail,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  const Text(
                    'Interview format',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    initialValue: _interviewMode,
                    decoration:
                        const InputDecoration(
                      prefixIcon:
                          Icon(Icons.meeting_room_outlined),
                    ),
                    items: _modes.map((mode) {
                      return DropdownMenuItem<String>(
                        value: mode,
                        child: Text(mode),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _interviewMode = value;
                      });
                    },
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Date and time',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          borderRadius:
                              BorderRadius.circular(16),
                          child: InputDecorator(
                            decoration:
                                const InputDecoration(
                              labelText: 'Date',
                              prefixIcon: Icon(
                                Icons
                                    .calendar_month_outlined,
                              ),
                            ),
                            child: Text(
                              selectedDateText,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _selectTime,
                          borderRadius:
                              BorderRadius.circular(16),
                          child: InputDecorator(
                            decoration:
                                const InputDecoration(
                              labelText: 'Time',
                              prefixIcon: Icon(
                                Icons.access_time,
                              ),
                            ),
                            child: Text(
                              selectedTimeText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _locationController,
                    keyboardType:
                        _interviewMode ==
                                    'In-person' ||
                                _interviewMode ==
                                    'Phone call'
                            ? TextInputType.text
                            : TextInputType.url,
                    decoration: InputDecoration(
                      labelText: _locationLabel,
                      hintText: _locationHint,
                      prefixIcon: Icon(
                        _interviewMode ==
                                'In-person'
                            ? Icons
                                .location_on_outlined
                            : _interviewMode ==
                                    'Phone call'
                                ? Icons.phone_outlined
                                : Icons
                                    .link_outlined,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().length < 3) {
                        return 'Enter the interview location, link, or instructions.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _notesController,
                    minLines: 4,
                    maxLines: 7,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Interview instructions',
                      hintText:
                          'Explain what the candidate should prepare, who they will meet, and the expected duration.',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(
                        Icons.notes_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : _saveInterview,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.event_available,
                          ),
                    label: Text(
                      widget.application.hasInterview
                          ? 'Update interview'
                          : 'Schedule interview',
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