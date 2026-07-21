import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_bubbles.dart';

const List<String> _pairSymbols = ['🔥', '🌊', '🌍', '🚸', '🧯', '🚨', '🛡️', '⛑️'];
const Duration _peekDuration = Duration(seconds: 4);

class MindGameScreen extends StatefulWidget {
  const MindGameScreen({super.key});

  @override
  State<MindGameScreen> createState() => _MindGameScreenState();
}

class _MindGameScreenState extends State<MindGameScreen> {
  late List<String> _symbols;
  late List<bool> _revealed;
  late List<bool> _cleared;
  late List<bool> _showMatch;
  int? _firstIndex;
  bool _busy = false;
  bool _peeking = true;
  int _moves = 0;
  bool _wonHandled = false;
  Timer? _peekTimer;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _peekTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _peekTimer?.cancel();
    final tiles = [..._pairSymbols, ..._pairSymbols];
    tiles.shuffle(Random());
    setState(() {
      _symbols = tiles;
      _revealed = List.filled(tiles.length, true);
      _cleared = List.filled(tiles.length, false);
      _showMatch = List.filled(tiles.length, false);
      _firstIndex = null;
      _busy = true;
      _peeking = true;
      _moves = 0;
      _wonHandled = false;
    });
    _peekTimer = Timer(_peekDuration, () {
      if (!mounted) return;
      setState(() {
        _revealed = List.filled(_symbols.length, false);
        _peeking = false;
        _busy = false;
      });
    });
  }

  void _onTapCard(int index) {
    if (_peeking || _busy || _cleared[index] || _revealed[index]) return;

    if (_firstIndex == null) {
      setState(() {
        _revealed[index] = true;
        _firstIndex = index;
      });
      return;
    }

    final first = _firstIndex!;
    setState(() {
      _revealed[index] = true;
      _moves++;
    });

    if (_symbols[first] == _symbols[index]) {
      setState(() {
        _showMatch[first] = true;
        _showMatch[index] = true;
        _firstIndex = null;
        _busy = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _cleared[first] = true;
          _cleared[index] = true;
          _showMatch[first] = false;
          _showMatch[index] = false;
          _busy = false;
        });
        if (_cleared.every((c) => c)) _onWin();
      });
    } else {
      _busy = true;
      _firstIndex = null;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _revealed[first] = false;
          _revealed[index] = false;
          _busy = false;
        });
      });
    }
  }

  int get _stars => _moves <= 10 ? 3 : (_moves <= 14 ? 2 : 1);

  void _onWin() {
    if (_wonHandled) return;
    _wonHandled = true;
    final appState = context.read<AppState>();
    final child = appState.activeChild!;
    final newBadge = appState.completeMindGame(child);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _showWinDialog(newBadge);
    });
  }

  void _showWinDialog(bool newBadge) {
    final t = context.read<AppState>().bengali;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              t ? 'দারুণ! তুমি সব মিলিয়েছ!' : 'Great job! You matched them all!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              t ? '$_moves টি চাল লেগেছে' : '$_moves moves',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _stars,
                (_) => const Icon(Icons.star_rounded, color: Colors.amber, size: 32),
              ),
            ),
            if (newBadge) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏅', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Text(t ? 'নতুন ব্যাজ অর্জিত!' : 'New Badge Unlocked!'),
                  ],
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: Text(t ? 'হোমে ফিরুন' : 'Back to Home'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _startNewGame();
            },
            child: Text(t ? 'আবার খেলো' : 'Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;

    return Scaffold(
      appBar: AppBar(
        title: Text(t ? 'মেমরি গেম 🧠' : 'Mind Game 🧠'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _startNewGame,
            tooltip: t ? 'নতুন খেলা' : 'New game',
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: FloatingBubbles(count: 8, emojis: ['🧠', '✨', '⭐', '🎈', '🌟']),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _peeking
                      ? (t ? 'ছবিগুলো মনে রাখো!' : 'Memorize the pictures!')
                      : (t
                          ? 'একই ছবির জোড়া খুঁজে বের করো!'
                          : 'Find the matching picture pairs!'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  t ? 'চাল: $_moves' : 'Moves: $_moves',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _symbols.length,
                        itemBuilder: (context, index) => _MemoryCard(
                          faceUp: _revealed[index],
                          matched: _showMatch[index],
                          cleared: _cleared[index],
                          symbol: _symbols[index],
                          onTap: () => _onTapCard(index),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final bool faceUp;
  final bool matched;
  final bool cleared;
  final String symbol;
  final VoidCallback onTap;

  const _MemoryCard({
    required this.faceUp,
    required this.matched,
    required this.cleared,
    required this.symbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (cleared) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Container(
          key: ValueKey('$faceUp-$symbol-$matched'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: faceUp
                  ? (matched
                      ? [const Color(0xFFC8E6C9), const Color(0xFFA5D6A7)]
                      : [const Color(0xFFE1BEE7), const Color(0xFFCE93D8)])
                  : [AppTheme.primary, const Color(0xFF1E5FA8)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            faceUp ? symbol : '❓',
            style: const TextStyle(fontSize: 26),
          ),
        ),
      ),
    );
  }
}
