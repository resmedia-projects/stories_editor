import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/models/editable_items.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:stories_editor/src/domain/sevices/save_as_image.dart';
import 'package:stories_editor/src/presentation/utils/constants/app_enums.dart';
import 'package:stories_editor/src/presentation/utils/modal_sheets.dart';
import 'package:stories_editor/src/presentation/widgets/animated_onTap_button.dart';
import 'package:stories_editor/src/presentation/widgets/tool_button.dart';

class TopTools extends StatefulWidget {
  final GlobalKey contentKey;
  final BuildContext context;
  final bool canEdit;

  const TopTools({
    Key? key,
    required this.contentKey,
    required this.context,
    this.canEdit = true,
  }) : super(key: key);

  @override
  _TopToolsState createState() => _TopToolsState();
}

class _TopToolsState extends State<TopTools> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<ControlNotifier, PaintingNotifier,
        DraggableWidgetNotifier>(
      builder: (_, controlNotifier, paintingNotifier, itemNotifier, __) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.w),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// close button
                ToolButton(
                  backGroundColor: Colors.black12,
                  onTap: () async {
                    var res = await exitDialog(
                        context: widget.context, contentKey: widget.contentKey);
                    if (res) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),

                if (widget.canEdit) ...[
                  if (controlNotifier.mediaPath.isEmpty &&
                      !controlNotifier.isLast)
                    _selectColor(
                      controlProvider: controlNotifier,
                      onTap: () {
                        if (controlNotifier.gradientIndex >=
                            controlNotifier.gradientColors!.length - 1) {
                          setState(() {
                            controlNotifier.gradientIndex = 0;
                          });
                        } else {
                          setState(() {
                            controlNotifier.gradientIndex += 1;
                          });
                        }
                      },
                    ),
                  ToolButton(
                    backGroundColor: Colors.black12,
                    onTap: () async {
                      if (paintingNotifier.lines.isNotEmpty ||
                          itemNotifier.editableItems.isNotEmpty) {
                        var response = await takePicture(
                            contentKey: widget.contentKey,
                            context: context,
                            saveToGallery: true);
                        if (response) {
                          Fluttertoast.showToast(msg: 'Successfully saved');
                        } else {
                          Fluttertoast.showToast(msg: 'Error');
                        }
                      }
                    },
                    child: const ImageIcon(
                      AssetImage('assets/icons/download.png',
                          package: 'stories_editor'),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  ToolButton(
                    backGroundColor: Colors.black12,
                    onTap: () => createGiphyItem(
                        context: context, giphyKey: controlNotifier.giphyKey),
                    child: const ImageIcon(
                      AssetImage('assets/icons/stickers.png',
                          package: 'stories_editor'),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  ToolButton(
                    backGroundColor: Colors.black12,
                    onTap: () {
                      controlNotifier.isPainting = true;
                    },
                    child: const ImageIcon(
                      AssetImage('assets/icons/draw.png',
                          package: 'stories_editor'),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  ToolButton(
                    backGroundColor: Colors.black12,
                    onTap: () => controlNotifier.isTextEditing =
                        !controlNotifier.isTextEditing,
                    child: const ImageIcon(
                      AssetImage('assets/icons/text.png',
                          package: 'stories_editor'),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  if (controlNotifier.isLast)
                    ToolButton(
                      backGroundColor: Colors.black12,
                      onTap: () => _changeLastTextBackgroundColor(
                          controlNotifier, itemNotifier),
                      child: const Icon(
                        Icons.format_color_fill,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeLastTextBackgroundColor(
      ControlNotifier controlProvider, DraggableWidgetNotifier itemProvider) {
    final mandatoryTextItems = itemProvider.editableItems
        .where((item) => item.isMandatory && item.type == ItemType.text)
        .toList();

    if (mandatoryTextItems.isNotEmpty) {
      EditableItem textItem = mandatoryTextItems.first;

      final backgroundColors = [
        Colors.pink,
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.red,
        Colors.teal,
        Colors.black.withOpacity(0.7),
      ];

      setState(() {
        int currentIndex = -1;
        for (int i = 0; i < backgroundColors.length; i++) {
          if (textItem.backGroundColor.value == backgroundColors[i].value) {
            currentIndex = i;
            break;
          }
        }

        int nextIndex = (currentIndex + 1) % backgroundColors.length;
        textItem.backGroundColor = backgroundColors[nextIndex];

        double luminance = textItem.backGroundColor.computeLuminance();
        textItem.textColor = luminance > 0.5 ? Colors.black : Colors.white;
      });
    }
  }

  Widget _selectColor(
      {required VoidCallback onTap, required ControlNotifier controlProvider}) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 8),
      child: AnimatedOnTapButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: controlProvider
                      .gradientColors![controlProvider.gradientIndex]),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
