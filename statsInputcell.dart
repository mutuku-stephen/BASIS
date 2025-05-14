import 'package:flutter/material.dart';

class StatInputCell extends StatefulWidget {
  final String label;
  final int? points;
  final Function(int playerIndex, int points)? onScored;
  final bool isFoul;
  final int? playerIndex;
  final Function(int playerIndex, String statKey, int value)
  onStatChanged; // New callback
  final String statKey; // New key for the stat being tracked

  const StatInputCell({
    super.key,
    required this.label,
    this.points,
    this.onScored,
    this.isFoul = false,
    this.playerIndex,
    required this.onStatChanged, // Required callback for stat changes
    required this.statKey, // Stat key for specific stat (e.g., 'ft_made')
  });

  @override
  StatInputCellState createState() => StatInputCellState();
}

class StatInputCellState extends State<StatInputCell> {
  int _statValue = 0;

  void _updateStat(int delta) {
    setState(() {
      _statValue += delta;
      if (_statValue < 0) _statValue = 0; // Prevent negative values

      // Update the stat value in the callback
      widget.onStatChanged(
        widget.playerIndex!, // Player index
        widget.statKey, // Stat key
        _statValue, // New stat value
      );

      if (widget.points != null && widget.onScored != null) {
        widget.onScored!(widget.playerIndex!, delta * widget.points!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label, style: const TextStyle(fontSize: 8)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.remove, size: 12),
                onPressed: () => _updateStat(-1),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _statValue.toString(),
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, size: 12),
                onPressed: () => _updateStat(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
