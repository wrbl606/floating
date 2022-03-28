part of floating;

// Widget switching utility.
//
// Depending on current PiP status will render [childWhenEnabled]
// or [childWhenDisabled] widget.
class PiPSwitcher extends StatefulWidget {
  // Child to render when PiP is enabled
  final Widget childWhenEnabled;

  // Child to render when PiP is disabled or unavailable.
  final Widget childWhenDisabled;

  // PiP status probe interval.
  //
  // By default it's set to 100 milliseconds since the system
  // applies a transition when the activity is switching modes
  // so there's plenty of time for this widget to act on that change.
  // Shorter duration will result with snappier widget switching
  // with a small performance impact.
  final Duration probeInterval;

  const PiPSwitcher({
    Key? key,
    this.probeInterval = const Duration(milliseconds: 100),
    required this.childWhenEnabled,
    required this.childWhenDisabled,
  }) : super(key: key);

  @override
  State<PiPSwitcher> createState() => _PipAwareState();
}

class _PipAwareState extends State<PiPSwitcher> {
  final _floating = Floating();

  @override
  void dispose() {
    _floating.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: _floating.pipStatus$,
        initialData: PiPStatus.disabled,
        builder: (context, snapshot) => snapshot.data == PiPStatus.enabled
            ? widget.childWhenEnabled
            : widget.childWhenDisabled,
      );
}
