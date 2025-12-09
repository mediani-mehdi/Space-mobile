import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskEditScreen extends StatefulWidget {
  final Task? task;
  const TaskEditScreen({super.key, this.task});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String? _description;
  DateTime? _startDate;
  DateTime? _dueDate;
  bool _reminder = false;
  DateTime? _reminderDate;
  String _priority = 'Medium';

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = t?.title ?? '';
    _description = t?.description;
    _startDate = t?.dueDate;
    _dueDate = t?.dueDate;
    _reminder = t?.reminder ?? false;
    _reminderDate = t?.reminderDate;
    _priority = t?.priority ?? 'Medium';
  }

  Future<void> _pickStartDate() async {
    final date = await _showCustomDatePicker(_startDate);
    if (date == null) return;
    if (!mounted) return;
    setState(() {
      _startDate = date;
    });
  }

  Future<void> _pickDueDate() async {
    final date = await _showCustomDatePicker(_dueDate);
    if (date == null) return;
    if (!mounted) return;
    setState(() {
      _dueDate = date;
      _reminderDate = date;
      _reminder = true;
    });
  }

  Future<DateTime?> _showCustomDatePicker(DateTime? initialDate) async {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomDatePicker(initialDate: initialDate),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final task = widget.task?.copyWith(
          title: _title,
          description: _description,
          dueDate: _dueDate,
          reminder: _reminder,
          reminderDate: _reminderDate,
          priority: _priority,
        ) ??
        Task(
          title: _title,
          description: _description,
          dueDate: _dueDate,
          reminder: _reminder,
          reminderDate: _reminderDate,
          priority: _priority,
        );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMMM d, yyyy');
    return Scaffold(
      backgroundColor: const Color(0xFF4A5545), // Same green as home screen
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.task == null ? 'Add new task' : 'Edit task',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
              onPressed: _save,
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Task Name',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                initialValue: _title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  hintText: 'Enter task name',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                onSaved: (v) => _title = v!.trim(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                initialValue: _description,
                style: const TextStyle(fontSize: 16),
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Add description...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
                onSaved: (v) => _description = v,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickStartDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _startDate == null ? 'Select date' : dateFmt.format(_startDate!),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _startDate == null ? Colors.grey : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Due Date',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDueDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.event,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _dueDate == null ? 'Select date' : dateFmt.format(_dueDate!),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _dueDate == null ? Colors.grey : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Priority',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PriorityChip(
                    label: 'High',
                    isSelected: _priority == 'High',
                    color: Colors.white.withValues(alpha: 0.2),
                    selectedColor: Colors.red[400]!,
                    onTap: () => setState(() => _priority = 'High'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PriorityChip(
                    label: 'Medium',
                    isSelected: _priority == 'Medium',
                    color: Colors.white.withValues(alpha: 0.2),
                    selectedColor: Colors.orange[400]!,
                    onTap: () => setState(() => _priority = 'Medium'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PriorityChip(
                    label: 'Low',
                    isSelected: _priority == 'Low',
                    color: Colors.white.withValues(alpha: 0.2),
                    selectedColor: Colors.green[400]!,
                    onTap: () => setState(() => _priority = 'Low'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final Color selectedColor;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: selectedColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _CustomDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  const _CustomDatePicker({this.initialDate});

  @override
  State<_CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<_CustomDatePicker> {
  late DateTime selectedDate;
  late PageController monthController;
  late int currentMonthIndex;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    final now = DateTime.now();
    currentMonthIndex = (selectedDate.year - now.year) * 12 + (selectedDate.month - now.month) + 12;
    monthController = PageController(initialPage: currentMonthIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Color(0xFF4A5545),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Date',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(selectedDate),
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Calendar
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: PageView.builder(
                controller: monthController,
                onPageChanged: (index) {
                  setState(() {
                    currentMonthIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final now = DateTime.now();
                  final displayMonth = DateTime(now.year, now.month + index - 12);
                  return _buildMonthView(displayMonth);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final weekdayOfFirst = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // Month header
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  monthController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('MMMM yyyy').format(month),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () {
                  monthController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        // Weekday headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final dayIndex = index - weekdayOfFirst;
                if (dayIndex < 0 || dayIndex >= daysInMonth) {
                  return const SizedBox();
                }

                final day = dayIndex + 1;
                final date = DateTime(month.year, month.month, day);
                final isSelected = date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A5545)
                          : isToday
                              ? const Color(0xFF4A5545).withValues(alpha: 0.2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? const Color(0xFF4A5545)
                                  : Colors.black,
                          fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
