import 'package:flutter/material.dart';
import 'package:teleprompter/teleprompter.dart';

enum OverlayLayout { creator, event }

class PictureOverlayScreen extends StatefulWidget {
  const PictureOverlayScreen({super.key});

  @override
  State<PictureOverlayScreen> createState() => _PictureOverlayScreenState();
}

class _PictureOverlayScreenState extends State<PictureOverlayScreen> {
  final headlineController = TextEditingController(text: 'Behind the scenes');
  final detailController = TextEditingController(
    text: 'Made with Teleprompter',
  );
  OverlayLayout layout = OverlayLayout.creator;
  Color accentColor = Colors.deepOrangeAccent;
  bool showLocation = true;

  @override
  void dispose() {
    headlineController.dispose();
    detailController.dispose();
    super.dispose();
  }

  void refreshPreview(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize picture overlay')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xff263238)),
                  const Center(
                    child: Icon(Icons.person, size: 120, color: Colors.white24),
                  ),
                  PictureOverlay(
                    headline: headlineController.text,
                    detail: detailController.text,
                    accentColor: accentColor,
                    layout: layout,
                    showLocation: showLocation,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            key: const Key('overlay-headline-field'),
            controller: headlineController,
            decoration: const InputDecoration(
              labelText: 'Headline',
              prefixIcon: Icon(Icons.title),
              border: OutlineInputBorder(),
            ),
            onChanged: refreshPreview,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: detailController,
            decoration: const InputDecoration(
              labelText: 'Supporting text',
              prefixIcon: Icon(Icons.short_text),
              border: OutlineInputBorder(),
            ),
            onChanged: refreshPreview,
          ),
          const SizedBox(height: 16),
          SegmentedButton<OverlayLayout>(
            segments: const [
              ButtonSegment(
                value: OverlayLayout.creator,
                icon: Icon(Icons.person_outline),
                label: Text('Creator'),
              ),
              ButtonSegment(
                value: OverlayLayout.event,
                icon: Icon(Icons.event_outlined),
                label: Text('Event'),
              ),
            ],
            selected: {layout},
            onSelectionChanged: (selection) {
              setState(() => layout = selection.first);
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show location badge'),
            value: showLocation,
            onChanged: (value) => setState(() => showLocation = value),
          ),
          const Text('Accent color'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              Colors.deepOrangeAccent,
              Colors.cyanAccent,
              Colors.purpleAccent,
              Colors.limeAccent,
            ].map((color) {
              return ChoiceChip(
                key: ValueKey(color),
                label: const SizedBox(width: 24, height: 24),
                avatar: CircleAvatar(backgroundColor: color),
                selected: accentColor == color,
                onSelected: (_) => setState(() => accentColor = color),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('open-overlay-camera'),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Open camera'),
            onPressed: () {
              final headline = headlineController.text;
              final detail = detailController.text;
              final selectedColor = accentColor;
              final selectedLayout = layout;
              final includeLocation = showLocation;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OverlayCameraWidget(
                    title: 'Picture overlay',
                    captureMode: TeleprompterCaptureMode.photo,
                    overlayBuilder: (context) => PictureOverlay(
                      headline: headline,
                      detail: detail,
                      accentColor: selectedColor,
                      layout: selectedLayout,
                      showLocation: includeLocation,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PictureOverlay extends StatelessWidget {
  const PictureOverlay({
    required this.headline,
    required this.detail,
    required this.accentColor,
    required this.layout,
    required this.showLocation,
    super.key,
  });

  final String headline;
  final String detail;
  final Color accentColor;
  final OverlayLayout layout;
  final bool showLocation;

  @override
  Widget build(BuildContext context) {
    final eventLayout = layout == OverlayLayout.event;
    return IgnorePointer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Badge(
                    color: accentColor,
                    icon: eventLayout ? Icons.event : Icons.auto_awesome,
                    label: eventLayout ? 'TODAY' : 'CREATOR STORY',
                  ),
                  const Spacer(),
                  if (showLocation)
                    const _Badge(
                      color: Colors.white,
                      icon: Icons.location_on_outlined,
                      label: 'ON LOCATION',
                      darkText: true,
                    ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(18),
                  border: Border(left: BorderSide(color: accentColor, width: 5)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 18),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: accentColor,
                      child: Icon(
                        eventLayout ? Icons.mic_none : Icons.movie_filter,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headline.isEmpty ? 'Your headline' : headline,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            detail.isEmpty ? 'Add supporting text' : detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_outward, color: accentColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.color,
    required this.icon,
    required this.label,
    this.darkText = false,
  });

  final Color color;
  final IconData icon;
  final String label;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    final foreground = darkText ? Colors.black87 : Colors.black;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
