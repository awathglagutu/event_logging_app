import 'package:flutter/material.dart';

import 'event_sheet.dart';
import 'nasa_tlx.dart';

const _ink = Color(0xFF17243A);
const _blue = Color(0xFF356AE6);
const _pale = Color(0xFFF4F7FC);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fieldwork',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _pale,
      colorScheme: ColorScheme.fromSeed(seedColor: _blue, surface: _pale),
      fontFamily: 'Roboto',
    ),
    home: const AppShell(),
  );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;
  final _pages = const [RecordsPage(), EventSheetPage()];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: _pale,
      leading: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.segment_rounded, color: _ink),
            tooltip: 'Open navigation',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      leadingWidth: 64,
      title: Text(
        _selected == 0 ? 'NASA-TLX' : 'Event-Sheet',
        style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
      ),
    ),
    drawer: Drawer(
      width: 290,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 20, 24),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.track_changes_rounded,
                      color: _blue,
                    ),
                  ),
                  const SizedBox(width: 13),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fieldwork',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Assessment tools',
                        style: TextStyle(
                          color: Color(0xFF7A8798),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 20, 10),
              child: Text(
                'WORKSPACE',
                style: TextStyle(
                  color: Color(0xFF7A8798),
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _navItem(context, 0, Icons.insights_rounded, 'NASA-TLX'),
            _navItem(context, 1, Icons.route_rounded, 'Event-Sheet'),
          ],
        ),
      ),
    ),
    body: IndexedStack(index: _selected, children: _pages),
  );

  Widget _navItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final active = _selected == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        selected: active,
        selectedTileColor: const Color(0xFFEAF0FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: active ? _blue : const Color(0xFF7A8798)),
        title: Text(
          label,
          style: TextStyle(
            color: active ? _blue : _ink,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: () {
          setState(() => _selected = index);
          Navigator.pop(context);
        },
      ),
    );
  }
}
