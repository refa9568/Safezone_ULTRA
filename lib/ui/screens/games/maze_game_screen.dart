import 'dart:collection';
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

  // A spanning tree has exactly one path between any two rooms. Knock down
  // a fixed share of the remaining walls between neighboring rooms so
  // multiple routes to the goal exist every time - the child then has to
  // pick the shortest one, instead of leaving it to per-wall chance (which
  // could roll zero extra openings for a given maze).
  final closedWalls = <List<int>>[];
  for (int r = 0; r < mazeRows; r++) {
    for (int c = 0; c < mazeCols; c++) {
      if (c + 1 < mazeCols) {
        final wr = r * 2 + 1, wc = c * 2 + 2;
        if (grid[wr][wc] == 0) closedWalls.add([wr, wc]);
      }
      if (r + 1 < mazeRows) {
        final wr = r * 2 + 2, wc = c * 2 + 1;
        if (grid[wr][wc] == 0) closedWalls.add([wr, wc]);
      }
    }
  }
  closedWalls.shuffle(rng);
  final extraOpenings = min(
    closedWalls.length,
    max(4, (closedWalls.length * 0.3).round()),
  );
  for (int i = 0; i < extraOpenings; i++) {
    final w = closedWalls[i];
    grid[w[0]][w[1]] = 1;
  }
  return grid;
}

/// Finds the shortest walkable route between [start] and [goal] on the
/// carved [grid] using breadth-first search, returning the cells along it
/// (inclusive of both ends), or an empty list if unreachable.
List<List<int>> _shortestPath(
  List<List<int>> grid,
  int gridRows,
  int gridCols,
  List<int> start,
  List<int> goal,
) {
  final visited = List.generate(gridRows, (_) => List.filled(gridCols, false));
  final prevIndex = List.generate(gridRows, (_) => List.filled(gridCols, -1));
  const dirs = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1],
  ];

  final queue = Queue<List<int>>()..add(start);
  visited[start[0]][start[1]] = true;

  while (queue.isNotEmpty) {
    final cur = queue.removeFirst();
    if (cur[0] == goal[0] && cur[1] == goal[1]) break;
    for (final d in dirs) {
      final nr = cur[0] + d[0];
      final nc = cur[1] + d[1];
      if (nr < 0 || nr >= gridRows || nc < 0 || nc >= gridCols) continue;
      if (grid[nr][nc] == 0 || visited[nr][nc]) continue;
      visited[nr][nc] = true;
      prevIndex[nr][nc] = cur[0] * gridCols + cur[1];
      queue.add([nr, nc]);
    }
  }

  if (!visited[goal[0]][goal[1]]) return const [];
  final path = <List<int>>[];
  var cr = goal[0], cc = goal[1];
  path.add([cr, cc]);
  while (cr != start[0] || cc != start[1]) {
    final idx = prevIndex[cr][cc];
    cr = idx ~/ gridCols;
    cc = idx % gridCols;
    path.add([cr, cc]);
  }
  return path.reversed.toList();
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
  final List<String> _path = [];
  int _moves = 0;
  bool _wonHandled = false;
  Set<String> _shortestPathCells = {};
  int _optimalMoves = 0;
  bool _showShortestPath = false;
  bool _newBadge = false;

  // Accumulates raw drag distance between swipe-triggered moves, so a single
  // continuous finger drag across the board can step the player multiple
  // cells - the same gesture feel as the D-pad buttons, just via touch.
  Offset _dragAccumulator = Offset.zero;
  static const double _swipeStep = 28;

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
      _path
        ..clear()
        ..add('$_playerR,$_playerC');
      _moves = 0;
      _wonHandled = false;
      _showShortestPath = false;
      _dragAccumulator = Offset.zero;
      final path = _shortestPath(
        _grid,
        _gridRows,
        _gridCols,
        [_playerR, _playerC],
        [_goalR, _goalC],
      );
      _shortestPathCells = path.map((p) => '${p[0]},${p[1]}').toSet();
      _optimalMoves = path.isEmpty ? 0 : path.length - 1;
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
      // Stepping back onto the cell we just came from is a backtrack, not a
      // new visit - pop it off the trail so it stops showing as visited.
      final isBacktrack =
          _path.length >= 2 && _path[_path.length - 2] == '$nr,$nc';
      if (isBacktrack) {
        _path.removeLast();
      } else {
        _path.add('$nr,$nc');
      }
      _moves++;
    });
    if (_playerR == _goalR && _playerC == _goalC) _onWin();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_wonHandled) return;
    _dragAccumulator += details.delta;
    // Consume the accumulator one step at a time so fast/long drags queue up
    // several moves, same as repeatedly tapping a direction button.
    while (_dragAccumulator.dx.abs() >= _swipeStep ||
        _dragAccumulator.dy.abs() >= _swipeStep) {
      if (_dragAccumulator.dx.abs() > _dragAccumulator.dy.abs()) {
        final dc = _dragAccumulator.dx > 0 ? 1 : -1;
        _dragAccumulator -= Offset(_swipeStep * dc, 0);
        _move(0, dc);
      } else {
        final dr = _dragAccumulator.dy > 0 ? 1 : -1;
        _dragAccumulator -= Offset(0, _swipeStep * dr);
        _move(dr, 0);
      }
    }
  }

  int get _stars => _moves <= 26 ? 3 : (_moves <= 40 ? 2 : 1);

  void _onWin() {
    if (_wonHandled) return;
    final appState = context.read<AppState>();
    final child = appState.activeChild!;
    final newBadge = appState.completeMazeGame(child);
    setState(() {
      _wonHandled = true;
      _showShortestPath = true;
      _newBadge = newBadge;
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
            const SizedBox(height: 4),
            Text(
              t
                  ? 'সবচেয়ে সংক্ষিপ্ত পথ ছিল $_optimalMoves টি পদক্ষেপ (সোনালি রঙে দেখানো হয়েছে)'
                  : 'Shortest path was $_optimalMoves steps (shown in gold)',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
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
            child: Column(
              children: [
                Text(
                  t ? 'পদক্ষেপ: $_moves' : 'Steps: $_moves',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (_showShortestPath) ...[
                  const SizedBox(height: 4),
                  Text(
                    t
                        ? 'সোনালি পথটি সবচেয়ে সংক্ষিপ্ত ছিল'
                        : 'The gold path was the shortest way',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB8860B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: _onPanUpdate,
              onPanEnd: (_) => _dragAccumulator = Offset.zero,
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
          ),
          Padding(
            // Lift the controls clear of the phone's on-screen navigation
            // bar/gesture area, which otherwise overlaps taps near the
            // bottom edge.
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
            // Keep the shortest path visible on screen instead of rushing
            // straight to the win dialog - the child only moves on once they
            // press End.
            child: _wonHandled
                ? ElevatedButton.icon(
                    onPressed: () => _showWinDialog(_newBadge),
                    icon: const Icon(Icons.flag_rounded),
                    label: Text(t ? 'শেষ করো' : 'End'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  )
                : _DPad(onMove: _move),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int r, int c) {
    final isWall = _grid[r][c] == 0;
    final isPlayer = r == _playerR && c == _playerC;
    final isGoal = r == _goalR && c == _goalC;
    final isVisited = _path.contains('$r,$c');
    final isOnShortestPath =
        _showShortestPath && _shortestPathCells.contains('$r,$c');
    // Once the child has won, _path holds their actual final route (dead-end
    // detours were popped off as they backtracked), so highlight it darker.
    final isOnFinalRoute = _wonHandled && isVisited;

    Color color;
    if (isWall) {
      color = const Color(0xFF1B4E86);
    } else if (isOnShortestPath) {
      color = const Color(0xFFFFD54F);
    } else if (isOnFinalRoute) {
      color = const Color(0xFF4A90D2);
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
