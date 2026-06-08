import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart' as xterm;

class TerminalView extends StatefulWidget {
  const TerminalView({super.key});

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  late final xterm.Terminal terminal;
  Pty? _pty;
  bool _ptySupported = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    terminal = xterm.Terminal(maxLines: 10000);
    _startPty();
  }

  bool get _isDesktop =>
      Platform.isLinux || Platform.isMacOS || Platform.isWindows;

  String _resolveShell() {
    if (Platform.isWindows) {
      return Platform.environment['COMSPEC'] ?? 'cmd.exe';
    }
    final shell = Platform.environment['SHELL'];
    if (shell != null && shell.isNotEmpty) return shell;
    // Android ships a minimal shell under /system/bin.
    if (Platform.isAndroid) return '/system/bin/sh';
    return '/bin/bash';
  }

  Future<void> _startPty() async {
    // PTY (forkpty) is only available on POSIX desktops and Android.
    if (Platform.isWindows) {
      _ptySupported = true; // ConPTY supported by flutter_pty
    }

    try {
      await _detectGit();

      final pty = Pty.start(
        _resolveShell(),
        columns: terminal.viewWidth,
        rows: terminal.viewHeight,
        environment: {
          ...Platform.environment,
          'TERM': 'xterm-256color',
        },
      );

      pty.output
          .cast<List<int>>()
          .transform(const Utf8Decoder())
          .listen(terminal.write);

      pty.exitCode.then((code) {
        if (!mounted) return;
        terminal.write('\r\n\x1b[90m[process exited with code $code]\x1b[0m\r\n');
      });

      terminal.onOutput = (data) {
        pty.write(const Utf8Encoder().convert(data));
      };

      terminal.onResize = (w, h, pw, ph) {
        pty.resize(h, w);
      };

      _pty = pty;
    } on Exception catch (e) {
      _ptySupported = false;
      _initError = e.toString();
      _writeFallbackBanner();
    } on Error catch (e) {
      // flutter_pty throws a plain Error if the platform lacks PTY support.
      _ptySupported = false;
      _initError = e.toString();
      _writeFallbackBanner();
    }

    if (mounted) setState(() {});
  }

  /// Detects whether the `git` CLI is available and informs the user.
  Future<void> _detectGit() async {
    if (!_isDesktop) return;
    try {
      final which = Platform.isWindows ? 'where' : 'which';
      final result = await Process.run(which, ['git']);
      if (result.exitCode != 0) {
        terminal.write(
          '\x1b[33m[FluxGit] git CLI not found on PATH. '
          'Install git for full terminal support.\x1b[0m\r\n',
        );
      }
    } catch (_) {
      // Non-fatal: detection is best-effort.
    }
  }

  void _writeFallbackBanner() {
    terminal.write('\x1b[1;36mFluxGit Terminal\x1b[0m\r\n');
    terminal.write(
      '\x1b[33mAn interactive shell is not available on this platform.\x1b[0m\r\n',
    );
    if (Platform.isAndroid) {
      terminal.write(
        'Install \x1b[1mTermux\x1b[0m for a full shell, then use it alongside FluxGit.\r\n',
      );
    }
    if (_initError != null) {
      terminal.write('\x1b[90m$_initError\x1b[0m\r\n');
    }
  }

  Future<void> _launchTermux() async {
    const channel = MethodChannel('com.fluxgit/termux');
    try {
      await channel.invokeMethod('openTermux');
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Termux is not installed. Install it from F-Droid.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pty?.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
        backgroundColor: Colors.black,
        actions: [
          if (Platform.isAndroid && !_ptySupported)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Open Termux',
              onPressed: _launchTermux,
            ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: xterm.TerminalView(
          terminal,
          padding: const EdgeInsets.all(8),
          autofocus: true,
        ),
      ),
    );
  }
}
