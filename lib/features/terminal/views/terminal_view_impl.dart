import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

class TerminalViewImpl extends StatefulWidget {
  const TerminalViewImpl({super.key});

  @override
  State<TerminalViewImpl> createState() => _TerminalViewImplState();
}

class _TerminalViewImplState extends State<TerminalViewImpl> {
  final terminal = Terminal();

  @override
  void initState() {
    super.initState();
    terminal.write('Welcome to FluxGit Terminal\r\n');
    terminal.write(r'$ ');
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
        child: TerminalView(
          terminal,
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }
}
