import 'dart:math' as math;

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
///    is nearest the touch; a tap in your own zone hops one anchor toward
///    the tap side, so a tap is never a silent no-op.
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
    // The aim guide can be turned off in Settings — keep the line hidden then.
    game.trajectory.visible = _dragOrigin != null && game.gameFeel.aimGuide;
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

    // Tapping your own zone must never be a silent no-op: hop one anchor
    // toward the tap side instead (tap left of you = dash left). Only an
    // outward tap at an edge anchor stays put — there's nowhere to go.
    final current = game.player.anchorIndex;
    if (best == current) {
      if (x < anchors[current].x) {
        best = math.max(0, current - 1);
      } else {
        best = math.min(anchors.length - 1, current + 1);
      }
    }

    game.player.dashTo(best);
  }
}
