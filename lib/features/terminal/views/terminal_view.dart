import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart' as xterm;

class TerminalView extends StatefulWidget {
  const TerminalView({super.key});

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  late final xterm.Terminal terminal;

  @override
  void initState() {
    super.initState();
    terminal = xterm.Terminal();
    terminal.write('Welcome to FluxGit Terminal\r\n');
    terminal.write('\$ ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: xterm.TerminalView(
          terminal,
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }
}
