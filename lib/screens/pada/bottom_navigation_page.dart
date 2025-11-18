import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:deliverapp/core/colors.dart';
import 'package:deliverapp/screens/pada/home_page.dart';
import 'package:deliverapp/screens/pada/profile_page.dart';
// import 'package:deliverapp/screens/pada/wallet_page.dart';
import 'order_history_page.dart';

enum TabItem { home, orders, wallet, profile }

const Map<TabItem, dynamic> tabName = {
  TabItem.home: {
    'label': 'Home',
    'icon': 'assets/images/home.svg',
    'widget': HomePage()
  },
  TabItem.orders: {
    'label': 'Orders',
    'icon': 'assets/images/record.svg',
    'widget': OrderHistoryPage()
  },
  // TabItem.wallet: {
  //   'label': 'Wallet',
  //   'icon': 'assets/images/wallet.svg',
  //   'widget': WalletPage()
  // },
  TabItem.profile: {
    'label': 'Profile',
    'icon': 'assets/images/profile.svg',
    'widget': ProfilePage()
  }
};

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  Widget? baseWidget = const HomePage();
  var _currentTab = TabItem.home;

  void _selectTab(TabItem tabItem) {
    setState(() => _currentTab = tabItem);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    debugPrint("Disposing BottomNavPageState");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigation(
        currentTab: _currentTab,
        onSelectTab: _selectTab,
      ),
    );
  }

  Widget _buildBody() {
    // If wallet tab is selected (shouldn't happen), default to home
    TabItem displayTab = _currentTab == TabItem.wallet ? TabItem.home : _currentTab;
    return Container(
        color: pureWhite,
        alignment: Alignment.center,
        child: tabName[displayTab]['widget']);
  }
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation(
      {super.key, required this.currentTab, required this.onSelectTab});
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  bool back = false;
  int time = 0;
  int duration = 1000;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<bool> willPop() async {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (back && time >= now) {
      back = false;
      SystemNavigator.pop();
    } else {
      time = DateTime.now().millisecondsSinceEpoch + duration;
      debugPrint("again tap");
      back = true;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Press again the button to exit")));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (val) async {
        await willPop();
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 0),
        decoration: const BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18), topRight: Radius.circular(18)),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(2)),
            ),
            SafeArea(
              top: false,
              bottom: false,
              child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  currentIndex: () {
                    // Map currentTab to visible tabs index, skipping wallet
                    List<TabItem> visibleTabs = [
                      TabItem.home,
                      TabItem.orders,
                      // TabItem.wallet,
                      TabItem.profile,
                    ];
                    // If wallet is selected (shouldn't happen), default to home index
                    TabItem displayTab = widget.currentTab == TabItem.wallet 
                        ? TabItem.home 
                        : widget.currentTab;
                    int index = visibleTabs.indexOf(displayTab);
                    return index >= 0 ? index : 0; // Fallback to 0 if not found
                  }(),
                  selectedItemColor: pureWhite,
                  unselectedItemColor: pureWhite.withOpacity(0.7),
                  type: BottomNavigationBarType.fixed,
                  iconSize: 22,
                  selectedFontSize: 12.0,
                  unselectedFontSize: 12.0,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  items: [
                    _buildItem(TabItem.home),
                    _buildItem(TabItem.orders),
                    // _buildItem(TabItem.wallet),
                    _buildItem(TabItem.profile),
                  ],
                  onTap: (index) {
                    HapticFeedback.selectionClick();
                    // Map index to TabItem, skipping wallet
                    List<TabItem> visibleTabs = [
                      TabItem.home,
                      TabItem.orders,
                      // TabItem.wallet,
                      TabItem.profile,
                    ];
                    widget.onSelectTab(
                      visibleTabs[index],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildItem(TabItem tabItem) {
    final bool active = widget.currentTab == tabItem;
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: SvgPicture.asset(
              tabName[tabItem]['icon'],
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                  active ? pureWhite : pureWhite.withOpacity(0.7),
                  BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4,
            width: active ? 16 : 0,
            decoration: BoxDecoration(
                color: pureWhite, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
      label: tabName[tabItem]['label'],
    );
  }

  // removed unused _colorTabMatching helper
}
