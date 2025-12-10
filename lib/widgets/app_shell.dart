import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// A simple app shell that shows a shared bottom navigation bar and
/// renders the provided pages inside an IndexedStack so each page keeps its state.
class AppShell extends StatefulWidget {
  final List<Widget> pages;
  final int initialIndex;

  const AppShell({super.key, required this.pages, this.initialIndex = 0})
    : assert(pages.length > 0);

  @override
  State<AppShell> createState() => _AppShellState();
}

class TabData {
  final String pageLabel;
  final IconData iconName;

  TabData({required this.pageLabel, required this.iconName});
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex = 0;
  late CupertinoTabController _tabController;
  final List<TabData> _tabs = [
    TabData(pageLabel: 'Home', iconName: CupertinoIcons.home),
    TabData(pageLabel: 'Feed', iconName: CupertinoIcons.square_list),
    TabData(pageLabel: 'Search', iconName: CupertinoIcons.search),
    TabData(pageLabel: 'Settings', iconName: CupertinoIcons.settings),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController(initialIndex: widget.initialIndex);
    _tabController.addListener(updateTabIndex);
  }

  void updateTabIndex() {
    if (_tabController.index != _selectedIndex) {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    }
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _tabController.index = index;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: CupertinoTabScaffold(
              controller: _tabController,
              tabBar: CupertinoTabBar(
                items: _tabs
                    .map(
                      (tab) => BottomNavigationBarItem(
                        label: tab.pageLabel,
                        icon: Icon(tab.iconName),
                      ),
                    )
                    .toList(),
              ),
              tabBuilder: (context, index) => widget.pages[index],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CNTabBar(
              items: _tabs
                  .map(
                    (tab) => CNTabBarItem(
                      label: tab.pageLabel,
                      icon: CNSymbol(tab.iconName.fontFamily ?? ''),
                    ),
                  )
                  .toList(),
              currentIndex: _selectedIndex,
              tint: CupertinoColors.destructiveRed,
              height: 85,
              onTap: _onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class ImageTabPage extends StatelessWidget {
  final String label;

  const ImageTabPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/wall.png', fit: BoxFit.cover),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.black.withAlpha(51), // 20% opacity
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: 18, color: CupertinoColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
