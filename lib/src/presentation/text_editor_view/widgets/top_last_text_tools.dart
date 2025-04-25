import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/generated/l10n.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:stories_editor/src/presentation/widgets/tool_button.dart';

class TopLastTextTools extends StatelessWidget {
  final void Function() onDone;
  const TopLastTextTools({Key? key, required this.onDone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TextEditingNotifier>(
      builder: (context, editorNotifier, child) {
        return Container(
          padding: const EdgeInsets.only(top: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// font family selector
              ToolButton(
                onTap: () {
                  editorNotifier.isFontFamily = !editorNotifier.isFontFamily;
                  /* WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (editorNotifier.fontFamilyController.hasClients) {
                      editorNotifier.fontFamilyController
                          .animateToPage(editorNotifier.fontFamilyIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                    }
                  }); */
                },
                child: Transform.scale(
                    scale: !editorNotifier.isFontFamily ? 0.8 : 1.3,
                    child: !editorNotifier.isFontFamily
                        ? const ImageIcon(
                            AssetImage('assets/icons/text.png',
                                package: 'stories_editor'),
                            size: 20,
                            color: Colors.white,
                          )
                        : Image.asset(
                            'assets/icons/circular_gradient.png',
                            package: 'stories_editor',
                          )),
              ),

              /// text align
              ToolButton(
                onTap: editorNotifier.onAlignmentChange,
                child: Transform.scale(
                    scale: 0.8,
                    child: Icon(
                      editorNotifier.textAlign == TextAlign.center
                          ? Icons.format_align_center
                          : editorNotifier.textAlign == TextAlign.right
                              ? Icons.format_align_right
                              : Icons.format_align_left,
                      color: Colors.white,
                    )),
              ),

              /// background color button per testo obbligatorio
              ToolButton(
                onTap: () {
                  // Toggle background color selection
                  editorNotifier.isBackgroundColorSelection =
                      !editorNotifier.isBackgroundColorSelection;
                },
                child: Transform.scale(
                    scale: 0.8,
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            editorNotifier.backGroundColor != Colors.transparent
                                ? editorNotifier.backGroundColor
                                : Colors.grey.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: editorNotifier.isBackgroundColorSelection
                                ? Colors.white
                                : Colors.transparent,
                            width: 1.5),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.format_color_fill,
                        color: Colors.white,
                        size: 16,
                      ),
                    )),
              ),

              const Spacer(),

              /// close and create item
              GestureDetector(
                onTap: onDone,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, top: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        S.of(context).done,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
