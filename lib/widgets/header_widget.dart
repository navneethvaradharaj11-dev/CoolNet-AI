import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const HeaderWidget({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final veryCompact = constraints.maxWidth < 430;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: veryCompact ? 12 : 20, vertical: 13),
          decoration: const BoxDecoration(
            color: Color(0xFF0C1726),
            border: Border(bottom: BorderSide(color: Color(0xFF23334A), width: 1)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withAlpha(24),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFF38BDF8).withAlpha(45)),
                ),
                child: const Icon(Icons.hub_rounded, color: Color(0xFF38BDF8), size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'CoolNet AI',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    if (!compact)
                      const Text(
                        'HEAT  ·  GRID  ·  COMMUNITY RISK',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Color(0xFF71839B), fontSize: 9, letterSpacing: 1.15, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              if (!veryCompact) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withAlpha(18),
                    border: Border.all(color: const Color(0xFFFBBF24).withAlpha(60)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: Color(0xFFFBBF24), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        compact ? 'DEMO DATA' : 'SIMULATED INPUTS',
                        style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 9, letterSpacing: 0.7, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(width: 6),
              IconButton(
                onPressed: onRefresh,
                tooltip: 'Refresh demo view',
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFFCBD5E1), size: 21),
              ),
            ],
          ),
        );
      },
    );
  }
}
