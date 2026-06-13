import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'package:deadbounce_flutter_app/core/config/game_balance.dart';

import '../components/deadbounce_game.dart';

/// One-thumb input over the whole arena:
///  - DRAG = relative slingshot aim (vector from drag origin, so the
///    thumb never covers the action). Past the deadzone, the trajectory
///    preview goes live; drag length maps to launch power. Release fires.
///    Dragging back under the deadzone dims the line = cancel affordance.
///  - TAP (or a release under the deadzone) = dash to the anchor whose x
///    is nearest the touch.
class InputController extends PositionComponent
    with HasGameReference<DeadbounceGame>, DragCallbacks, TapCallbacks {
  InputController()
      : super(
          size: Vector2(DeadbounceGame.arenaWidth, DeadbounceGame.arenaHeight),
          position: Vector2.zero(),
          priority: 100,
        );

  Vector2? _dragOrigin;
  final Vector2 _aim = Vector2.zero();

  bool get _aiming =>
      _dragOrigin != null && _aim.length > GameBalance.I.input.aimDeadzone;

  @override
  void onTapUp(TapUpEvent event) {
    _dashToward(event.localPosition.x);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (game.runEnded) return;
    _dragOrigin = event.localPosition.clone();
    _aim.setZero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragOrigin == null) return;
    _aim.add(event.localDelta);
    _updatePreview();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final origin = _dragOrigin;
    _dragOrigin = null;
    game.trajectory.visible = false;
    if (origin == null || game.runEnded) return;

    if (_aim.length <= GameBalance.I.input.aimDeadzone) {
      // Sloppy tap → still a dash; both paths converge.
      _dashToward(origin.x);
      return;
    }

    final direction = _aim.normalized();
    final powerT = _powerT();
    game.player.fire(direction, powerT);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _dragOrigin = null;
    game.trajectory.visible = false;
  }

  void _updatePreview() {
    final aiming = _aiming;
    game.trajectory.visible = _dragOrigin != null;
    game.trajectory.dimmed = !aiming;
    if (!aiming || !game.player.fireReady) {
      if (!game.player.fireReady) game.trajectory.dimmed = true;
      if (!aiming) return;
    }

    game.refreshTrajectory(_aim.normalized(), _powerT());
  }

  double _powerT() => ((_aim.length - GameBalance.I.input.aimDeadzone) /
          (GameBalance.I.input.maxDragLength - GameBalance.I.input.aimDeadzone))
      .clamp(0.0, 1.0);

  void _dashToward(double x) {
    final anchors = game.player.anchors;
    var best = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < anchors.length; i++) {
      final d = (anchors[i].x - x).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    game.player.dashTo(best);
  }
}
