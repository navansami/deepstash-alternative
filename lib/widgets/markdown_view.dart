import 'package:markdown/markdown.dart' as md;
import 'package:material_ui/material_ui.dart';

/// Renders the markdown subset used in lessons (headings, paragraphs, emphasis,
/// lists, blockquotes, inline code, rules) with the app's own widgets and theme.
class MarkdownView extends StatelessWidget {
  final String data;
  const MarkdownView(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final nodes = md.Document(extensionSet: md.ExtensionSet.gitHubFlavored).parseLines(data.split('\n'));
    final r = _Renderer(Theme.of(context));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: r.blocks(nodes));
  }
}

class _Renderer {
  final ThemeData theme;
  _Renderer(this.theme);

  TextStyle get _body => TextStyle(fontSize: 17, height: 1.65, color: theme.colorScheme.onSurface);

  List<Widget> blocks(List<md.Node> nodes) => [for (final n in nodes) ...block(n)];

  List<Widget> block(md.Node node) {
    if (node is md.Text) return [_para(node.text)];
    if (node is! md.Element) return const [];
    final scheme = theme.colorScheme;
    switch (node.tag) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
        final size = switch (node.tag) {
          'h1' => 26.0,
          'h2' => 21.0,
          'h3' => 18.0,
          _ => 16.0,
        };
        return [
          Padding(
            padding: const EdgeInsets.only(top: 22, bottom: 8),
            child: Text.rich(
              TextSpan(children: inline(node.children ?? const [])),
              style: TextStyle(fontSize: size, fontWeight: FontWeight.w800, height: 1.3, color: scheme.onSurface),
            ),
          ),
        ];
      case 'p':
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text.rich(TextSpan(children: inline(node.children ?? const [])), style: _body),
          ),
        ];
      case 'ul':
      case 'ol':
        final ordered = node.tag == 'ol';
        final start = int.tryParse(node.attributes['start'] ?? '') ?? 1;
        var i = 0;
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final li in (node.children ?? const []).whereType<md.Element>())
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 28,
                          child: ordered
                              ? Text('${start + i++}.', style: _body.copyWith(fontWeight: FontWeight.w700))
                              : Padding(
                                  padding: const EdgeInsets.only(top: 10, left: 6),
                                  child: Icon(Icons.circle, size: 7, color: scheme.primary),
                                ),
                        ),
                        Expanded(child: _listItem(li)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ];
      case 'blockquote':
        return [
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: Border(left: BorderSide(color: scheme.primary, width: 4)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: blocks(node.children ?? const [])),
          ),
        ];
      case 'hr':
        return [const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider())];
      case 'pre':
        return [
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
            child: Text(node.textContent, style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
          ),
        ];
      default:
        return [_para(node.textContent)];
    }
  }

  Widget _listItem(md.Element li) {
    final children = li.children ?? const [];
    // Tight lists contain inline nodes; loose lists contain <p> blocks.
    if (children.every((c) => c is md.Text || (c is md.Element && !_isBlock(c.tag)))) {
      return Text.rich(TextSpan(children: inline(children)), style: _body);
    }
    final widgets = blocks(children);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widgets);
  }

  bool _isBlock(String tag) => const {'p', 'ul', 'ol', 'blockquote', 'pre', 'h1', 'h2', 'h3', 'h4', 'hr'}.contains(tag);

  Widget _para(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(text, style: _body),
  );

  List<InlineSpan> inline(List<md.Node> nodes, [TextStyle style = const TextStyle()]) {
    final out = <InlineSpan>[];
    for (final n in nodes) {
      if (n is md.Text) {
        out.add(TextSpan(text: _unescape(n.text), style: style));
      } else if (n is md.Element) {
        final next = switch (n.tag) {
          'strong' => style.copyWith(fontWeight: FontWeight.w700),
          'em' => style.copyWith(fontStyle: FontStyle.italic),
          'del' => style.copyWith(decoration: TextDecoration.lineThrough),
          'code' => style.copyWith(fontFamily: 'monospace', backgroundColor: theme.colorScheme.surfaceContainerHighest),
          'a' => style.copyWith(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
          _ => style,
        };
        if (n.tag == 'br') {
          out.add(const TextSpan(text: '\n'));
        } else {
          out.addAll(inline(n.children ?? const [], next));
        }
      }
    }
    return out;
  }

  String _unescape(String s) => s
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');
}
