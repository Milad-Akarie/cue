import 'package:cue/cue.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gooey/gooey.dart';

// Uses hover and mouse position, so only works on mouse supported platforms
class OneKFollowers extends StatefulWidget {
  const OneKFollowers({super.key});

  @override
  State<OneKFollowers> createState() => _OneKFollowersState();
}

class _OneKFollowersState extends State<OneKFollowers> with SingleTickerProviderStateMixin {
  late final _offset = CueValueAnimator<Offset>(.zero, vsync: this, motion: .wobbly());
  bool _follow = false;
  final oKey = GlobalKey();
  bool _showNumber = false;

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) async {
          if (_follow) {
            setState(() {
              _showNumber = true;
              _follow = false;
            });
            _offset.animateTo(Offset.zero);
          }
        },
        onPointerHover: (details) {
          if (!_follow || _showNumber) return;
          final renderBox = oKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox == null) return;
          final oPosition = renderBox.localToGlobal(Offset.zero);
          final oSize = renderBox.size;
          final oCenter = oPosition + oSize.center(Offset.zero);
          final newOffset = (details.position - oCenter) / (oSize.shortestSide / 3);
          _offset.value = newOffset;
        },
        child: Cue.onToggle(
          toggled: _follow,
          motion: .linear(150.ms),
          reverseMotion: .linear(300.ms),
          child: TweenActor.value(
            from: 16.0,
            to: 60.0,
            builder: (context, value, _) {
              return GooeyZone(
                color: Colors.black,
                gooiness: value,
                child: Center(
                  child: GooeyBlob(
                    shape: .rounded(24),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        overlayColor: _follow ? Colors.transparent : null,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        if (_follow) return;
                        setState(() {
                          _follow = true;
                          _showNumber = false;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_showNumber ? '1' : 'F'),
                          TranslateTransition(
                            offset: _offset,
                            child: GooeyBlob(
                              child: Text(_showNumber ? 'O' : 'o', key: oKey),
                            ),
                          ),
                          Text(_showNumber ? 'O' : 'll'),
                          TranslateTransition(
                            offset: _offset,
                            child: GooeyBlob(
                              child: Text(_showNumber ? 'O' : 'o'),
                            ),
                          ),
                          Text(_showNumber ? 'K' : 'w'),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
