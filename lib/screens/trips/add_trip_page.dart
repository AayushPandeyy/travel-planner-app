import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/trips/domain/entities/trip_params.dart';
import '../../features/trips/presentation/cubit/trips_cubit.dart';
import '../../features/trips/presentation/cubit/trips_state.dart';
import '../dashboard/widgets/shared_widgets.dart';

class AddTripPage extends StatefulWidget {
  const AddTripPage({super.key});

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  // Selections
  String _selectedEmoji = '✈️';
  Color _selectedColor = const Color(0xFF6C63FF);
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isSubmitting = false;

  // Options
  final List<String> _emojis = [
    '✈️',
    '🏝️',
    '🗼',
    '⛩️',
    '🗽',
    '🎡',
    '🏔️',
    '🌴',
    '🏖️',
    '🌋',
    '🏛️',
    '🗺️',
    '🚢',
    '🚂',
    '🏕️',
    '🌃',
  ];

  final List<Color> _colors = [
    const Color(0xFF6C63FF),
    const Color(0xFFFF6B6B),
    const Color(0xFF00BFA5),
    const Color(0xFFFFB74D),
    const Color(0xFF4DD0E1),
    const Color(0xFF5C6BC0),
    const Color(0xFFAB47BC),
    const Color(0xFF26A69A),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _destinationCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: _darkDatePickerTheme,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Reset end date if it's before the new start
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _endDate ??
          (_startDate ?? DateTime.now()).add(const Duration(days: 7)),
      firstDate: _startDate ?? DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: _darkDatePickerTheme,
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Widget _darkDatePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00BCD4),
          onPrimary: Colors.white,
          surface: Color(0xFF1A2E38),
          onSurface: Colors.white,
        ),
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1A2E38)),
      ),
      child: child!,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      _showError('Please select both start and end dates.');
      return;
    }

    // Convert Color to hex string for API (skip alpha channel)
    final argb = _selectedColor.toARGB32();
    final colorHex =
        '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

    context.read<TripsCubit>().createTrip(
      CreateTripParams(
        name: _nameCtrl.text.trim(),
        destination: _destinationCtrl.text.trim(),
        emoji: _selectedEmoji,
        colorHex: colorHex,
        startDate: _startDate!,
        endDate: _endDate!,
        totalBudget: double.tryParse(_budgetCtrl.text.trim()) ?? 0,
      ),
    );
    setState(() => _isSubmitting = true);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripsCubit, TripsState>(
      listener: (context, state) {
        if (state is TripActionSuccess) {
          setState(() => _isSubmitting = false);
          if (mounted) Navigator.pop(context);
        } else if (state is TripActionFailure) {
          setState(() => _isSubmitting = false);
          _showError(state.message);
        } else if (state is TripActionLoading) {
          setState(() => _isSubmitting = true);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: DashboardGradient(
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Emoji preview + name
                            _buildEmojiPreviewCard(),
                            const SizedBox(height: 24),

                            // Trip name
                            _Label('Trip Name'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _nameCtrl,
                              hint: 'e.g. Paris Adventure',
                              icon: Icons.label_outline_rounded,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter a trip name'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Destination
                            _Label('Destination'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _destinationCtrl,
                              hint: 'e.g. Paris, France',
                              icon: Icons.location_on_outlined,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter a destination'
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            // Emoji picker
                            _Label('Trip Icon'),
                            const SizedBox(height: 10),
                            _buildEmojiGrid(),
                            const SizedBox(height: 24),

                            // Color picker
                            _Label('Accent Color'),
                            const SizedBox(height: 10),
                            _buildColorRow(),
                            const SizedBox(height: 24),

                            // Date range
                            _Label('Travel Dates'),
                            const SizedBox(height: 10),
                            _buildDateRow(),
                            const SizedBox(height: 24),

                            // Budget
                            _Label('Total Budget (USD)'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _budgetCtrl,
                              hint: 'e.g. 2500',
                              icon: Icons.attach_money_rounded,
                              inputType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 36),

                            // Submit
                            _buildSubmitButton(),
                          ],
                        ),
                      ),
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

  // ── Sub-builders ──

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'New Trip',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPreviewCard() {
    final tripName = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Your Trip';
    final destination = _destinationCtrl.text.isNotEmpty
        ? _destinationCtrl.text
        : 'Destination';
    final budget = _budgetCtrl.text.isNotEmpty
        ? '\$${_budgetCtrl.text}'
        : 'No budget set';
    final dateText = (_startDate != null && _endDate != null)
        ? '${_fmtDate(_startDate!)} — ${_fmtDate(_endDate!)}'
        : 'No dates selected';

    return AnimatedBuilder(
      animation: Listenable.merge([_nameCtrl, _destinationCtrl, _budgetCtrl]),
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _selectedColor.withValues(alpha: 0.35),
                _selectedColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _selectedColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _selectedColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _selectedEmoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tripName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            destination,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            dateText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money_rounded,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 1),
                        Text(
                          budget,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmojiGrid() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _emojis.map((emoji) {
          final isSelected = emoji == _selectedEmoji;
          return GestureDetector(
            onTap: () => setState(() => _selectedEmoji = emoji),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? _selectedColor.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? _selectedColor.withValues(alpha: 0.6)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorRow() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _colors.map((color) {
          final isSelected = color == _selectedColor;
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 36 : 30,
              height: isSelected ? 36 : 30,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 10,
                        ),
                      ]
                    : [],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        Expanded(
          child: _DateField(
            label: 'Start Date',
            date: _startDate,
            onTap: _pickStartDate,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DateField(
            label: 'End Date',
            date: _endDate,
            onTap: _pickEndDate,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _selectedColor.withValues(alpha: 0.4),
          elevation: 8,
          shadowColor: _selectedColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Create Trip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ── Helpers ──

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.5),
        letterSpacing: 0.4,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? inputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.inputType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: const Color(0xFF4DD0E1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.28),
          fontSize: 15,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.35),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4DD0E1), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: date != null
                ? const Color(0xFF4DD0E1).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: date != null
                  ? const Color(0xFF4DD0E1)
                  : Colors.white.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? '${months[date!.month - 1]} ${date!.day}, ${date!.year}'
                        : 'Select',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: date != null
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
