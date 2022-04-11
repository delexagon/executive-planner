import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/pages/calendar.dart';
import 'package:flutter/material.dart';

class NavBarDisplay extends StatefulWidget {
  const NavBarDisplay({
    required this.events,
    required this.selectedIndex,
    Key? key,
  }) : super(key: key);

  final EventList events;
  final int selectedIndex;

  @override
  _NavBarDisplayState createState() => _NavBarDisplayState();
}

class _NavBarDisplayState extends State<NavBarDisplay> {
  void _onNavItemTap(int index) {
    // TODO: Carry over ExecutiveHomePage for calendar view
    /*
    // If we select Calendar
    if (index == 1) {
      // Move to Calendar view
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CalendarView(
            events: widget.events,
          ),
        ),
      );
    }
    */
    // If we select Home
    if (index == 0) {
      // Go to Homepage
      Navigator.pop(context);
    }
    if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings coming soon!'),
        ),
      );
    }
  }

  Widget _navBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: widget.selectedIndex,
      onTap: _onNavItemTap,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      // Because we are not updating the navbar, it is fixed
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _navBar();
  }
}
