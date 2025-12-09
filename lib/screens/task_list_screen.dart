import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../services/weather_service.dart';
import 'task_edit_screen.dart';
import 'dart:ui';

import 'glass_effects.dart';
import 'search_screen.dart';
import 'feed_screen.dart';
import 'settings_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  DateTime selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  // track which nav item is selected to render highlight
  int _selectedIndex = 0;

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildTabBody(ColorScheme color) {
    switch (_selectedIndex) {
      case 0:
        // original task list content
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(color: color)),
            SliverToBoxAdapter(
              child: _DateChips(
                color: color,
                selectedDate: selectedDate,
                onDateSelected: (d) => setState(() => selectedDate = d),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Day tasks',
                        style: TextStyle(
                          color: color.onPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        )),
                    _PillButton(
                      label: 'Add task',
                      onTap: () async {
                        final newTask = await Navigator.of(context).push<Task?>(
                          MaterialPageRoute(builder: (_) => const TaskEditScreen()),
                        );
                        if (!mounted) return;
                        if (newTask != null) {
                          await Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _TasksScroller(
                  tasks: Provider.of<TaskProvider>(context, listen: false)
                      .tasks
                      .where((t) {
                        final d = t.dueDate;
                        if (d == null) return false;
                        return _isSameDate(d, selectedDate);
                      })
                      .toList(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Text('Inventory',
                    style: TextStyle(
                      color: color.onPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverToBoxAdapter(child: _InventoryGrid()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 88)),
          ],
        );
      case 1:
        return const FeedScreen();
      case 2:
        return const SearchScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      // Use a very dark base to let the liquid + glass stand out
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedLiquidBackground()),
          // Foreground content
          SafeArea(child: _buildTabBody(color)),
        ],
      ),
      // Custom floating nav like the image (now without center Create button)
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, isTablet ? 24 : 20),
        child: SizedBox(
          height: isTablet ? 106 : 92,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pill background with blur and shadow
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      // stronger blur for a frosted glass look
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        height: isTablet ? 88 : 76,
                        decoration: BoxDecoration(
                          // darker glass gradient similar to the reference
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF2A2D30),
                              Color(0xFF1E2124),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.12), width: 1),
                          boxShadow: const [
                            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.35), blurRadius: 32, offset: Offset(0, 22)),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Four items laid out evenly: Home, Feed, Search, Settings
                            _SelectableNavItem(
                              index: 0,
                              icon: Icons.home_outlined,
                              label: 'Home',
                              selected: _selectedIndex == 0,
                              onTap: () => setState(() => _selectedIndex = 0),
                            ),
                            _SelectableNavItem(
                              index: 1,
                              icon: Icons.list_alt_outlined,
                              label: 'Feed',
                              selected: _selectedIndex == 1,
                              onTap: () => setState(() => _selectedIndex = 1),
                            ),
                            _SelectableNavItem(
                              index: 2,
                              icon: Icons.search_outlined,
                              label: 'Search',
                              selected: _selectedIndex == 2,
                              onTap: () => setState(() => _selectedIndex = 2),
                            ),
                            _SelectableNavItem(
                              index: 3,
                              icon: Icons.settings_outlined,
                              label: 'Settings',
                              selected: _selectedIndex == 3,
                              onTap: () => setState(() => _selectedIndex = 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  final ColorScheme color;
  const _Header({required this.color});

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  WeatherData? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await WeatherService.getCurrentWeather();
      if (mounted) {
        setState(() {
          weatherData = weather;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  IconData _getWeatherIcon() {
    if (weatherData == null) return Icons.cloud;

    final condition = weatherData!.condition.toLowerCase();
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return Icons.grain;
    } else if (condition.contains('cloud')) {
      return Icons.cloud;
    } else if (condition.contains('sun') || condition.contains('clear')) {
      return Icons.wb_sunny;
    } else if (condition.contains('snow')) {
      return Icons.ac_unit;
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return Icons.foggy;
    } else if (condition.contains('thunder')) {
      return Icons.thunderstorm;
    }
    return Icons.cloud;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(26),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_getWeatherIcon(), color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              isLoading
                ? '...'
                : '${weatherData?.temperature.round() ?? '--'}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isLoading
                  ? 'Loading weather...'
                  : weatherData?.description ?? 'Weather unavailable',
                style: const TextStyle(color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.color.onPrimary.withValues(alpha: 0.2),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateChips extends StatelessWidget {
  final ColorScheme color;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  const _DateChips({required this.color, required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final items = List.generate(7, (i) => now.add(Duration(days: i - 2)));
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return SizedBox(
      height: isTablet ? 110 : 96,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final d = items[i];
          final isToday = d.day == now.day && d.month == now.month && d.year == now.year;
          final isSelected = d.year == selectedDate.year && d.month == selectedDate.month && d.day == selectedDate.day;
          final dayFont = isTablet ? 22.0 : 20.0;
           return GestureDetector(
            onTap: () => onDateSelected(DateTime(d.year, d.month, d.day)),
            child: Container(
              width: isTablet ? 80 : 70,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : (isToday ? const Color(0xFF2E332C) : const Color(0xFF2E332C)),
                borderRadius: BorderRadius.circular(18),
                border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.day.toString(), style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: dayFont, fontWeight: FontWeight.bold)),
                  Text(_shortWeekday(d.weekday), style: TextStyle(color: isSelected ? Colors.black54 : Colors.white70)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _shortWeekday(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(w + 6) % 7];
  }
}

class _TasksScroller extends StatelessWidget {
  final List<Task> tasks;
  const _TasksScroller({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No tasks for today', style: TextStyle(color: Colors.white70)),
      );
    }
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
     return SizedBox(
       height: isTablet ? 240 : 220,
       child: ListView.separated(
         scrollDirection: Axis.horizontal,
         padding: const EdgeInsets.only(right: 12),
         itemCount: tasks.length,
         separatorBuilder: (context, index) => const SizedBox(width: 12),
         itemBuilder: (context, index) => _TaskCard(task: tasks[index], width: isTablet ? size.width * 0.32 : 280),
       ),
     );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final double? width;
  const _TaskCard({required this.task, this.width});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
     return GestureDetector(
       onTap: () async {
         final updated = await Navigator.of(context).push<Task?>(
           MaterialPageRoute(builder: (_) => TaskEditScreen(task: task)),
         );
         if (!context.mounted) return;
         if (updated != null) {
           await Provider.of<TaskProvider>(context, listen: false).updateTask(updated);
         }
       },
       child: GlassContainer(
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: width ?? (isTablet ? MediaQuery.of(context).size.width * 0.32 : 280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(_timeRange(task), style: TextStyle(color: Colors.black54, fontSize: isTablet ? 17 : 16, letterSpacing: 0.2)),
             const SizedBox(height: 4), // Reduced from 8
            Text(task.title, style: TextStyle(fontSize: isTablet ? 24 : 22, fontWeight: FontWeight.w700, height: 1.15)),
            if (task.description != null && task.description!.isNotEmpty) ...[
               const SizedBox(height: 4), // Reduced from 6
               Text(task.description!, style: const TextStyle(color: Colors.black54)),
             ],
             const SizedBox(height: 8), // Reduced from 12
            Text('Priority', style: TextStyle(color: Colors.black54, fontSize: isTablet ? 15 : 14)),
             const SizedBox(height: 4), // Reduced from 6
             _PriorityChip(priority: _priorityFor(task)),
           ],
         ),
        ),
       ),
      );
   }

  String _timeRange(Task t) {
    final start = t.dueDate;
    final end = t.reminderDate; // use reminder as end when available
    if (start == null && end == null) return 'Anytime';
    String f(DateTime d) {
      final hasMinutes = d.minute != 0;
      return DateFormat(hasMinutes ? 'h:mm a' : 'h a').format(d).toUpperCase();
    }
    if (start != null && end != null) return '${f(start)} – ${f(end)}';
    final base = start ?? end!;
    final oneHourLater = base.add(const Duration(hours: 1));
    return '${f(base)} – ${f(oneHourLater)}';
  }

  String _priorityFor(Task t) {
    // Use the stored priority instead of calculating it
    return t.priority;
  }
}

class _PriorityChip extends StatelessWidget {
  final String priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg;
    switch (priority) {
      case 'High':
        bg = const Color(0xFFFF6D3F); // Orange-red for high
        break;
      case 'Medium':
        bg = const Color(0xFFFFB800); // Bright orange/yellow for medium
        break;
      case 'Low':
      default:
        bg = const Color(0xFF6B7280); // Neutral grey for low
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(22)),
      child: Text(priority, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}

class _InventoryGrid extends StatelessWidget {
  const _InventoryGrid();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _InventoryCard(title: 'Regularly changing the engine oil', subtitle: 'John Deere 6M', icon: Icons.inventory),
        _InventoryCard(title: 'Tire inspection and replacement', subtitle: 'John Deere T560', icon: Icons.construction),
      ],
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _InventoryCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _SelectableNavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _SelectableNavItem({
    required this.index,
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    const iconColor = Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 12.0 : 10.0, vertical: isTablet ? 8 : 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          // Slightly smaller capsule to avoid overflow in tight widths
          width: selected ? (isTablet ? 110 : 92) : (isTablet ? 52 : 44),
          height: selected ? (isTablet ? 54 : 48) : (isTablet ? 40 : 34),
          decoration: selected
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3A3D40),
                      Color(0xFF2A2D30),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.28), width: 1.2),
                  boxShadow: const [
                    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.4), blurRadius: 20, offset: Offset(0, 10)),
                  ],
                )
              : const BoxDecoration(),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: isTablet ? 26 : 22),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                  child: selected
                      ? Padding(
                          key: ValueKey(label),
                          padding: EdgeInsets.only(left: isTablet ? 10 : 8),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 13 : 12,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(label),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: color.onPrimary, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            const Icon(Icons.add, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
