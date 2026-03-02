import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/activities/domain/entities/activity_entity.dart';
import '../../features/activities/domain/entities/activity_params.dart';
import '../../features/activities/presentation/cubit/activities_cubit.dart';
import '../../features/activities/presentation/cubit/activities_state.dart';
import '../dashboard/widgets/shared_widgets.dart';

class AddActivityPage extends StatefulWidget {
  final String tripId;
  final Color tripColor;

  const AddActivityPage({
    super.key,
    required this.tripId,
    required this.tripColor,
  });

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  late DateTime _selectedDate;
  int _duration = 60; // minutes
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedIconName = 'monument';
  Color _selectedColor = const Color(0xFF6C63FF);

  // ── Available icons (keys from ActivityEntity.iconMap) ──
  final List<Map<String, dynamic>> _icons = ActivityEntity.iconMap.entries
      .map((e) => {'name': e.key, 'icon': e.value})
      .toList();

  // ── Available colors ──
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
  void initState() {
    super.initState();
    _selectedColor = widget.tripColor;
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00BCD4),
            onPrimary: Colors.white,
            surface: Color(0xFF1A2E38),
            onSurface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF1A2E38),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String get _formattedTime {
    final h = _selectedTime.hourOfPeriod == 0 ? 12 : _selectedTime.hourOfPeriod;
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    final period = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
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

  String get _durationString {
    if (_duration < 60) return '$_duration min';
    final h = _duration ~/ 60;
    final m = _duration % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }

  String get _timeString => '${_fmtDate(_selectedDate)} · $_formattedTime';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00BCD4),
            onPrimary: Colors.white,
            surface: Color(0xFF1A2E38),
            onSurface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF1A2E38),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String get _hexColor {
    final argb = _selectedColor.toARGB32();
    return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ActivitiesCubit>().createActivity(
      CreateActivityParams(
        tripId: widget.tripId,
        title: _titleCtrl.text.trim(),
        date: _selectedDate,
        startTime: _formattedTime,
        duration: _duration,
        location: _locationCtrl.text.trim(),
        iconName: _selectedIconName,
        colorHex: _hexColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivitiesCubit, ActivitiesState>(
      listener: (context, state) {
        if (state is ActivityActionSuccess) {
          Navigator.pop(context);
        } else if (state is ActivityActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFFF6B6B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
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
                            // Preview card
                            _buildPreviewCard(),
                            const SizedBox(height: 24),

                            // Title
                            _Label('Activity Title'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _titleCtrl,
                              hint: 'e.g. Visit Eiffel Tower',
                              icon: Icons.event_note_outlined,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter an activity title'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Location
                            _Label('Location'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _locationCtrl,
                              hint: 'e.g. Champ de Mars, Paris',
                              icon: Icons.location_on_outlined,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter a location'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Date, Time & Duration
                            _Label('Schedule'),
                            const SizedBox(height: 10),
                            _buildScheduleRow(),
                            const SizedBox(height: 12),
                            _buildDurationRow(),
                            const SizedBox(height: 24),

                            // Icon picker
                            _Label('Activity Icon'),
                            const SizedBox(height: 10),
                            _buildIconGrid(),
                            const SizedBox(height: 24),

                            // Color picker
                            _Label('Accent Color'),
                            const SizedBox(height: 10),
                            _buildColorRow(),
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

  // ── Sub-widgets ──

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
            'Add Activity',
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

  Widget _buildPreviewCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([_titleCtrl, _locationCtrl]),
      builder: (context, _) {
        final title = _titleCtrl.text.isNotEmpty
            ? _titleCtrl.text
            : 'Activity Name';
        final location = _locationCtrl.text.isNotEmpty
            ? _locationCtrl.text
            : 'Location';
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _selectedColor.withValues(alpha: 0.35),
                _selectedColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _selectedColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _selectedColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  ActivityEntity.iconMap[_selectedIconName] ??
                      Icons.event_note_outlined,
                  color: _selectedColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _timeString,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            overflow: TextOverflow.ellipsis,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
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

  Widget _buildScheduleRow() {
    return Row(
      children: [
        // Date picker
        Expanded(
          child: GestureDetector(
            onTap: _pickDate,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: _selectedColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _fmtDate(_selectedDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Time selector
        Expanded(
          child: GestureDetector(
            onTap: _pickTime,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: _selectedColor,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formattedTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationRow() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.timelapse_rounded, size: 18, color: _selectedColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duration',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _durationString,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_duration > 15) setState(() => _duration -= 15);
                },
                child: Icon(
                  Icons.remove_circle_outline_rounded,
                  size: 24,
                  color: _duration > 15
                      ? _selectedColor
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => setState(() => _duration += 15),
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 24,
                  color: _selectedColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconGrid() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _icons.map((item) {
          final icon = item['icon'] as IconData;
          final name = item['name'] as String;
          final isSelected = name == _selectedIconName;
          return GestureDetector(
            onTap: () => setState(() => _selectedIconName = name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
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
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? _selectedColor
                    : Colors.white.withValues(alpha: 0.45),
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

  Widget _buildSubmitButton() {
    return BlocBuilder<ActivitiesCubit, ActivitiesState>(
      builder: (context, state) {
        final isLoading = state is ActivityActionLoading;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submit,
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
            child: isLoading
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
                        'Add Activity',
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
      },
    );
  }
}

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
