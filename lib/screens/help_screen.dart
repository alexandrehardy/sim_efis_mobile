import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/screens/image_viewer.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/accept_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';

IconData getIconForName(String name) {
  if (name == 'question') {
    return CupertinoIcons.question;
  } else if (name == 'compass') {
    return CupertinoIcons.compass;
  } else if (name == 'question_circle') {
    return CupertinoIcons.question_circle;
  } else if (name == 'zoom_out_map') {
    return Icons.zoom_out_map;
  } else if (name == 'settings') {
    return Icons.settings;
  } else if (name == 'zoom_out_map') {
    return Icons.zoom_out_map;
  } else if (name == 'view_sidebar') {
    return Icons.view_sidebar;
  } else if (name == 'stop') {
    return Icons.stop;
  } else if (name == 'play_arrow') {
    return Icons.play_arrow;
  } else if (name == 'remove_circle') {
    return Icons.remove_circle;
  } else if (name == 'remove_circle_outline') {
    return Icons.remove_circle_outline;
  } else if (name == 'add_circle') {
    return Icons.add_circle;
  } else if (name == 'add_circle_outline') {
    return Icons.add_circle_outline;
  } else if (name == 'arrow_circle_down') {
    return Icons.arrow_circle_down;
  } else if (name == 'arrow_circle_up') {
    return Icons.arrow_circle_up;
  } else if (name == 'check') {
    return Icons.check;
  } else if (name == 'edit') {
    return Icons.edit;
  } else if (name == 'delete') {
    return Icons.delete;
  } else if (name == 'wifi') {
    return Icons.wifi;
  } else if (name == 'three_g_mobiledata') {
    return Icons.three_g_mobiledata;
  } else if (name == 'arrow_back') {
    return Icons.arrow_back;
  } else if (name == 'aircraft') {
    return Icons.airplanemode_active;
  } else if (name == 'location_north') {
    return CupertinoIcons.location_north_fill;
  } else if (name == 'location_pin') {
    return Icons.location_pin;
  } else if (name == 'info_outline') {
    return Icons.info_outline;
  } else {
    return Icons.local_fire_department;
  }
}

class LazyInsertIcons extends StatelessWidget {
  final Widget child;
  const LazyInsertIcons({Key? key, required this.child}) : super(key: key);

  TextSpan insertIconsInSpan(InlineSpan span) {
    if (span is TextSpan) {
      List<InlineSpan> children = [];
      String? text = span.text;
      if ((text != null) && (text.contains('@(icon:'))) {
        RegExp regex = RegExp(r'@\(icon:([a-zA-Z_0-9:])+\)');
        int last = 0;
        for (Match match in regex.allMatches(text)) {
          if (last != match.start) {
            children.add(
              TextSpan(
                text: text.substring(last, match.start),
              ),
            );
          }
          String iconSpec = text.substring(match.start + 7, match.end - 1);
          String icon;
          Color color;
          if (iconSpec.contains(':')) {
            List<String> parts = iconSpec.split(':');
            icon = parts[0];
            color = Color(int.tryParse(parts[1], radix: 16) ?? 0);
          } else {
            icon = iconSpec;
            color = Colors.white;
          }
          children.add(
            WidgetSpan(
              child: Icon(
                getIconForName(icon),
                size: 24,
                color: color,
              ),
            ),
          );
          last = match.end;
        }
        if (last != text.length) {
          children.add(
            TextSpan(
              text: text.substring(last),
            ),
          );
        }
        text = null;
      }
      for (InlineSpan child in span.children ?? []) {
        children.add(insertIconsInSpan(child));
      }
      return TextSpan(
        text: text,
        children: children,
        style: span.style,
        recognizer: span.recognizer,
        mouseCursor: span.mouseCursor,
        onEnter: span.onEnter,
        onExit: span.onExit,
        semanticsLabel: span.semanticsLabel,
        locale: span.locale,
        spellOut: span.spellOut,
      );
    } else {
      return TextSpan(children: [span]);
    }
  }

  Widget insertIcons(Widget widget) {
    if (widget is SelectableText) {
      return SelectableText.rich(
        insertIconsInSpan(widget.textSpan!),
        key: widget.key,
        focusNode: widget.focusNode,
        style: widget.style,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        textScaler: widget.textScaler,
        showCursor: widget.showCursor,
        autofocus: widget.autofocus,
        contextMenuBuilder: widget.contextMenuBuilder,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        cursorWidth: widget.cursorWidth,
        cursorHeight: widget.cursorHeight,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor,
        selectionHeightStyle: widget.selectionHeightStyle,
        selectionWidthStyle: widget.selectionWidthStyle,
        dragStartBehavior: widget.dragStartBehavior,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        selectionControls: widget.selectionControls,
        onTap: widget.onTap,
        scrollPhysics: widget.scrollPhysics,
        semanticsLabel: widget.semanticsLabel,
        textHeightBehavior: widget.textHeightBehavior,
        textWidthBasis: widget.textWidthBasis,
        onSelectionChanged: widget.onSelectionChanged,
      );
    } else if (widget is RichText) {
      return RichText(
        key: widget.key,
        text: insertIconsInSpan(widget.text),
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        softWrap: widget.softWrap,
        overflow: widget.overflow,
        textScaler: widget.textScaler,
        maxLines: widget.maxLines,
        locale: widget.locale,
        strutStyle: widget.strutStyle,
        textWidthBasis: widget.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior,
      );
    } else if (widget is Column) {
      return Column(
        key: widget.key,
        mainAxisAlignment: widget.mainAxisAlignment,
        mainAxisSize: widget.mainAxisSize,
        crossAxisAlignment: widget.crossAxisAlignment,
        textDirection: widget.textDirection,
        verticalDirection: widget.verticalDirection,
        textBaseline: widget.textBaseline,
        children: [for (Widget child in widget.children) insertIcons(child)],
      );
    } else if (widget is Row) {
      return Row(
        key: widget.key,
        mainAxisAlignment: widget.mainAxisAlignment,
        mainAxisSize: widget.mainAxisSize,
        crossAxisAlignment: widget.crossAxisAlignment,
        textDirection: widget.textDirection,
        verticalDirection: widget.verticalDirection,
        textBaseline: widget.textBaseline,
        children: [for (Widget child in widget.children) insertIcons(child)],
      );
    } else if (widget is Wrap) {
      return Wrap(
        key: widget.key,
        direction: widget.direction,
        alignment: widget.alignment,
        spacing: widget.spacing,
        runSpacing: widget.runSpacing,
        runAlignment: widget.runAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        textDirection: widget.textDirection,
        verticalDirection: widget.verticalDirection,
        clipBehavior: widget.clipBehavior,
        children: [for (Widget child in widget.children) insertIcons(child)],
      );
    } else if (widget is Padding) {
      return Padding(
        key: widget.key,
        padding: widget.padding,
        child: widget.child == null ? null : insertIcons(widget.child!),
      );
    } else if (widget is Expanded) {
      return Expanded(
        key: widget.key,
        flex: widget.flex,
        child: insertIcons(widget.child),
      );
    } else if (widget is Flexible) {
      return Flexible(
        key: widget.key,
        flex: widget.flex,
        fit: widget.fit,
        child: insertIcons(widget.child),
      );
    } else {
      return widget;
    }
  }

  @override
  Widget build(BuildContext context) {
    return insertIcons(child);
  }
}

MarkdownImageBuilder scalableImageBuilder(BuildContext context) =>
    (Uri uri, String? title, String? alt) {
      Widget image;
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        image = Image.network(uri.toString());
      } else if (uri.scheme == 'icon') {
        Color color = Colors.white;
        if ((uri.hasQuery) && (uri.queryParameters.containsKey('color'))) {
          color = Color(
            int.tryParse(uri.queryParameters['color']!, radix: 16) ?? 0,
          );
        }
        return Icon(
          getIconForName(uri.path),
          size: 24,
          color: color,
        );
      } else if (uri.scheme == 'resource') {
        image = Image.asset(uri.path);
        if ((uri.hasQuery) && (uri.queryParameters.containsKey('size'))) {
          List<String> dimensions = uri.queryParameters['size']!.split('x');
          if (dimensions.length == 2) {
            double? width = double.tryParse(dimensions[0].trim());
            double? height = double.tryParse(dimensions[1].trim());
            if ((width != null) && (height != null)) {
              image = ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width,
                  minWidth: 0,
                  maxHeight: height,
                  minHeight: 0,
                ),
                child: AspectRatio(
                  aspectRatio: width / height,
                  child: SizedBox.expand(
                    child: image,
                  ),
                ),
              );
            }
          }
        }
      } else {
        return Container();
      }
      return Center(
        child: Stack(
          children: [
            image,
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Container(
                    color: Colors.black45,
                    child: const Icon(
                      Icons.zoom_out_map,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => ImageViewerScreen(
                        title: title ?? alt ?? uri.pathSegments.last,
                        assetImage: uri.path,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    };

class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) => Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
        child: Text(
          text.text,
          style: EfisStyle.codeBlockStyle,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      );
}

class HelpScreen extends StatefulWidget {
  final String title;
  final Color background;
  Future<String> getHelpMarkDown(BuildContext context) async => '';

  String get resourcePath => 'assets';

  const HelpScreen({
    Key? key,
    required this.title,
    this.background = Colors.black45,
  }) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class IconMarkdown extends MarkdownWidget {
  // Copy of Markdown, but with extra scanning for icons
  const IconMarkdown({
    Key? key,
    required String data,
    bool selectable = false,
    MarkdownStyleSheet? styleSheet,
    MarkdownStyleSheetBaseTheme? styleSheetTheme,
    SyntaxHighlighter? syntaxHighlighter,
    MarkdownTapLinkCallback? onTapLink,
    VoidCallback? onTapText,
    String? imageDirectory,
    List<md.BlockSyntax>? blockSyntaxes,
    List<md.InlineSyntax>? inlineSyntaxes,
    md.ExtensionSet? extensionSet,
    MarkdownImageBuilder? imageBuilder,
    MarkdownCheckboxBuilder? checkboxBuilder,
    MarkdownBulletBuilder? bulletBuilder,
    Map<String, MarkdownElementBuilder> builders =
        const <String, MarkdownElementBuilder>{},
    Map<String, MarkdownPaddingBuilder> paddingBuilders =
        const <String, MarkdownPaddingBuilder>{},
    MarkdownListItemCrossAxisAlignment listItemCrossAxisAlignment =
        MarkdownListItemCrossAxisAlignment.baseline,
    this.padding = const EdgeInsets.all(16.0),
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    bool softLineBreak = false,
  }) : super(
          key: key,
          data: data,
          selectable: selectable,
          styleSheet: styleSheet,
          styleSheetTheme: styleSheetTheme,
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: onTapLink,
          onTapText: onTapText,
          imageDirectory: imageDirectory,
          blockSyntaxes: blockSyntaxes,
          inlineSyntaxes: inlineSyntaxes,
          extensionSet: extensionSet,
          imageBuilder: imageBuilder,
          checkboxBuilder: checkboxBuilder,
          builders: builders,
          paddingBuilders: paddingBuilders,
          listItemCrossAxisAlignment: listItemCrossAxisAlignment,
          bulletBuilder: bulletBuilder,
          softLineBreak: softLineBreak,
        );

  final EdgeInsets padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    return ListView(
      padding: padding,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: [
        for (Widget widget in children!) LazyInsertIcons(child: widget)
      ],
    );
  }
}

class _HelpScreenState extends State<HelpScreen> {
  final GlobalKey exportButtonKey = GlobalKey();
  Future<String> futureData = Future.value('');

  @override
  void initState() {
    super.initState();
    futureData = widget.getHelpMarkDown(context);
  }

  Rect? exportButtonRect() {
    RenderObject? renderObject =
        exportButtonKey.currentContext?.findRenderObject();
    if (renderObject == null) return null;
    RenderBox renderBox = renderObject as RenderBox;

    Size size = renderBox.size;
    Offset position = renderBox.localToGlobal(Offset.zero);

    return Rect.fromCenter(
      center: position + Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          key: exportButtonKey,
        ),
        backgroundColor: EfisColors.background,
        actions: const [],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: futureData,
          initialData: '',
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
              Container(
            color: widget.background,
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: IconMarkdown(
                imageBuilder: scalableImageBuilder(context),
                builders: {
                  'pre': CodeBlockBuilder(),
                },
                selectable: true,
                data: snapshot.requireData,
                styleSheet: MarkdownStyleSheet(
                  h1: EfisStyle.settingsTextStyle.copyWith(fontSize: 28),
                  h1Padding: const EdgeInsets.only(top: 8),
                  h2: EfisStyle.settingsTextStyle.copyWith(fontSize: 24),
                  h2Padding: const EdgeInsets.only(top: 16),
                  p: EfisStyle.settingsTextStyle
                      .copyWith(fontWeight: FontWeight.normal),
                  listBullet: EfisStyle.settingsTextStyle
                      .copyWith(fontWeight: FontWeight.normal),
                  code: EfisStyle.codeBlockStyle,
                  codeblockDecoration:
                      const BoxDecoration(color: Colors.black45),
                  a: EfisStyle.settingsTextStyle
                      .copyWith(color: Colors.lightBlueAccent),
                  tableBody: EfisStyle.settingsTextStyle,
                  tableHead: EfisStyle.settingsTextStyle,
                ),
                onTapLink: (String link, String? href, String title) async {
                  AssetBundle bundle = DefaultAssetBundle.of(context);

                  if (href != null) {
                    if (href.startsWith('http')) {
                      await launchUrlString(href);
                      return;
                    }
                  }
                  bool? result;
                  if (context.mounted) {
                    result = await showDialog(
                      context: context,
                      builder: (BuildContext context) => const AcceptDialog(
                        message: 'Use files?',
                      ),
                    );
                  }
                  if (result == null) {
                    return;
                  }
                  bool useText = !result;

                  String text =
                      await bundle.loadString('${widget.resourcePath}/$href');
                  if (useText) {
                    await Share.share(
                      text,
                      subject: link,
                      sharePositionOrigin: exportButtonRect(),
                    );
                  } else {
                    final tempDir = await getTemporaryDirectory();
                    final file = await File('${tempDir.path}/$href').create();
                    await file.writeAsString(text);

                    await Share.shareXFiles(
                      [XFile(file.path, mimeType: 'text/plain')],
                      subject: link,
                      sharePositionOrigin: exportButtonRect(),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
