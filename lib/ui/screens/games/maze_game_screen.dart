import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/logic/app_state.dart';
import 'package:safezone_ultra/ui/theme/app_theme.dart';
import 'package:safezone_ultra/ui/widgets/popping_arrow_button.dart';

/// Generates a fully-connected, guaranteed-solvable maze using randomized
/// depth-first search (recursive backtracker) on a doubled grid, where
/// even coordinates are rooms and odd coordinates are the walls between
/// them that get carved open as the algorithm visits new rooms.
List<List<int>> _generateMaze(int mazeRows, int mazeCols, Random rng) {
  final gridRows = mazeRows * 2 + 1;
  final gridCols = mazeCols * 2 + 1;
  final grid = List.generate(gridRows, (_) => List.filled(gridCols, 0));
  final visited = List.generate(mazeRows, (_) => List.filled(mazeCols, false));

  const dirs = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1],
  ];

  final stack = <List<int>>[
    [0, 0],
  ];
  visited[0][0] = true;
  grid[1][1] = 1;

  while (stack.isNotEmpty) {
    final r = stack.last[0];
    final c = stack.last[1];
    final options = <List<int>>[];
    for (final d in dirs) {
      final nr = r + d[0];
      final nc = c + d[1];
      if (nr >= 0 &&
          nr < mazeRows &&
          nc >= 0 &&
          nc < mazeCols &&
          !visited[nr][nc]) {
        options.add([nr, nc, d[0], d[1]]);
      }
    }
    if (options.isEmpty) {
      stack.removeLast();
      continue;
    }
    final chosen = options[rng.nextInt(options.length)];
    final nr = chosen[0], nc = chosen[1], dr = chosen[2], dc = chosen[3];
    visited[nr][nc] = true;
    final gr = r * 2 + 1, gc = c * 2 + 1;
    grid[gr + dr][gc + dc] = 1;
    grid[nr * 2 + 1][nc * 2 + 1] = 1;
    stack.add([nr, nc]);
  }
  return grid;
}

class MazeGameScreen extends StatefulWidget {
  const MazeGameScreen({super.key});

  @override
  State<MazeGameScreen> createState() => _MazeGameScreenState();
}

class _MazeGameScreenState extends State<MazeGameScreen> {
  static const int _mazeRows = 6;
  static const int _mazeCols = 5;
  final _rng = Random();

  late List<List<int>> _grid;
  late int _gridRows;
  late int _gridCols;
  late int _playerR;
  late int _playerC;
  late int _goalR;
  late int _goalC;
  final Set<String> _visited = {};
  int _moves = 0;
  bool _wonHandled = false;

  @override
  void initState() {
    super.initState();
    _newMaze();
  }

  void _newMaze() {
    _gridRows = _mazeRows * 2 + 1;
    _gridCols = _mazeCols * 2 + 1;
    setState(() {
      _grid = _generateMaze(_mazeRows, _mazeCols, _rng);
      _playerR = 1;
      _playerC = 1;
      _goalR = _gridRows - 2;
      _goalC = _gridCols - 2;
      _visited
        ..clear()
        ..add('$_playerR,$_playerC');
      _moves = 0;
      _wonHandled = false;
    });
  }

  void _move(int dr, int dc) {
    if (_wonHandled) return;
    final nr = _playerR + dr;
    final nc = _playerC + dc;
    if (nr < 0 || nr >= _gridRows || nc < 0 || nc >= _gridCols) return;
    if (_grid[nr][nc] == 0) return;
    setState(() {
      _playerR = nr;
      _playerC = nc;
      _visited.add('$nr,$nc');
      _moves++;
    });
    if (_playerR == _goalR && _playerC == _goalC) _onWin();
  }

  int get _stars => _moves <= 26 ? 3 : (_moves <= 40 ? 2 : 1);

  void _onWin() {
    if (_wonHandled) return;
    _wonHandled = true;
    final appState = context.read<AppState>();
    final child = appState.activeChild!;
    final newBadge = appState.completeMazeGame(child);
    Future.delayed(const Duration(milliseconds: 300), () {
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
            const Text('🏠', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              t ? 'তুমি বাসায় পৌঁছে গেছো!' : 'You made it home!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              t ? '$_moves টি পদক্ষেপ লেগেছে' : '$_moves steps',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _stars,
                (_) => const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 32,
                ),
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
              _newMaze();
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
        title: Text(t ? 'বাসার পথ খুঁজো 🧩' : 'Find Your Way Home 🧩'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _newMaze,
            tooltip: t ? 'নতুন গোলকধাঁধা' : 'New maze',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              t ? 'পদক্ষেপ: $_moves' : 'Steps: $_moves',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: _gridCols / _gridRows,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GridView.count(
                    crossAxisCount: _gridCols,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (int r = 0; r < _gridRows; r++)
                        for (int c = 0; c < _gridCols; c++) _buildCell(r, c),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _DPad(onMove: _move),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int r, int c) {
    final isWall = _grid[r][c] == 0;
    final isPlayer = r == _playerR && c == _playerC;
    final isGoal = r == _goalR && c == _goalC;
    final isVisited = _visited.contains('$r,$c');

    Color color;
    if (isWall) {
      color = const Color(0xFF1B4E86);
    } else if (isVisited) {
      color = const Color(0xFFBFE0FF);
    } else {
      color = Colors.white;
    }

    Widget? content;
    if (isPlayer) {
      content = const FittedBox(fit: BoxFit.scaleDown, child: Text('🧒'));
    } else if (isGoal) {
      content = const FittedBox(fit: BoxFit.scaleDown, child: Text('🏠'));
    }

    return Container(
      margin: const EdgeInsets.all(0.6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.center,
      child: content,
    );
  }
}

class _DPad extends StatelessWidget {
  final void Function(int dr, int dc) onMove;
  const _DPad({required this.onMove});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PoppingArrowButton(
          icon: Icons.keyboard_arrow_up_rounded,
          onTap: () => onMove(-1, 0),
          size: 48,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PoppingArrowButton(
              icon: Icons.keyboard_arrow_left_rounded,
              onTap: () => onMove(0, -1),
              size: 48,
            ),
            const SizedBox(width: 56),
            PoppingArrowButton(
              icon: Icons.keyboard_arrow_right_rounded,
              onTap: () => onMove(0, 1),
              size: 48,
            ),
          ],
        ),
        const SizedBox(height: 8),
        PoppingArrowButton(
          icon: Icons.keyboard_arrow_down_rounded,
          onTap: () => onMove(1, 0),
          size: 48,
        ),
      ],
    );
  }
}
