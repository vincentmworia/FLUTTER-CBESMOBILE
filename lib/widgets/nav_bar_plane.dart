import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../providers/login_user_data.dart';

class NavBarPlane extends StatefulWidget {
  const NavBarPlane(
      {Key? key, required this.switchPage, required this.pageTitle})
      : super(key: key);
  final PageTitle pageTitle;
  final Function switchPage;

  @override
  State<NavBarPlane> createState() => _NavBarPlaneState();
}

class _NavBarPlaneState extends State<NavBarPlane> {
  @override
  void initState() {
    super.initState();
    _activePage = widget.pageTitle;
  }

  PageTitle? _activePage;

  Widget _planeItem(PageTitle page, IconData icon) {
    final activeClr = Theme.of(context).colorScheme.primary;
    final inactiveClr = Theme.of(context).colorScheme.secondary.withOpacity(0.75);
    // final inactiveClr = Theme.of(context).colorScheme.primary.withOpacity(0.2);
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color:_activePage == page ? activeClr : inactiveClr,
          ),
          title: Text(
            HomeScreen.pageTitle(page),
            textAlign: TextAlign.start,
            overflow: TextOverflow.clip,
            style: TextStyle(
              // fontSize: 1,
              color: _activePage == page ? activeClr : inactiveClr,
            ),
          ),
          onTap: () {
            setState(() {
              _activePage = page;
            });

            widget.switchPage(page, HomeScreen.pageTitle(page));
            Navigator.pop(context);
          },
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<PageTitle, IconData>> planeData = [
      {PageTitle.dashboard: Icons.dashboard},
      {PageTitle.solarHeaterMeter: Icons.heat_pump},
      {PageTitle.flowMeter: Icons.water_drop},
      {PageTitle.ductMeter: Icons.credit_card},
      {PageTitle.ambientMeter: Icons.device_thermostat},
      {PageTitle.shedMeter: Icons.home},
      {PageTitle.electricalEnergyMeter: Icons.electric_bolt},
      {PageTitle.thermalEnergyMeter: Icons.electric_meter},
      {PageTitle.firewoodMoisture: Icons.water_drop},
      {PageTitle.profile: Icons.settings}
    ];
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                '${LoginUserData.getLoggedUser!.firstname[0]} ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            accountName: Text(
                "${LoginUserData.getLoggedUser!.firstname} ${LoginUserData.getLoggedUser!.lastname}"),
            accountEmail: Text(LoginUserData.getLoggedUser!.email),
          ),
          ...planeData
              .map((e) => _planeItem(e.keys.first, e.values.first))
              .toList()
        ],
      ),
    );
  }
}
