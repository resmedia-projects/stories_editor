import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/models/editable_items.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:stories_editor/src/presentation/text_editor_view/widgets/animation_selector.dart';
import 'package:stories_editor/src/presentation/text_editor_view/widgets/background_color_selector.dart';
import 'package:stories_editor/src/presentation/text_editor_view/widgets/font_selector.dart';
import 'package:stories_editor/src/presentation/text_editor_view/widgets/text_field_widget.dart';
import 'package:stories_editor/src/presentation/text_editor_view/widgets/top_last_text_tools.dart';
import 'package:stories_editor/src/presentation/text_editor_view/widgets/top_text_tools.dart';
import 'package:stories_editor/src/presentation/utils/constants/app_enums.dart';
import 'package:stories_editor/src/presentation/widgets/color_selector.dart';
import 'package:stories_editor/src/presentation/widgets/size_slider_selector.dart';

class TextEditor extends StatefulWidget {
  final BuildContext context;
  final bool isMandatory;

  const TextEditor({
    Key? key,
    required this.context,
    this.isMandatory = false,
  }) : super(key: key);

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> with WidgetsBindingObserver {
  List<String> splitList = [];
  String sequenceList = '';
  String lastSequenceList = '';

  double bottomInset = 0.0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final editorNotifier =
          Provider.of<TextEditingNotifier>(widget.context, listen: false);
      editorNotifier
        ..textController.text = editorNotifier.text
        ..fontFamilyController = PageController(viewportFraction: .125);
    });

    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((final Duration timeStamp) {
      setState(() {
        bottomInset = EdgeInsets.fromWindowPadding(
                    WidgetsBinding.instance.window.viewInsets,
                    WidgetsBinding.instance.window.devicePixelRatio)
                .bottom -
            45.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = ScreenUtil();
    return Material(
        color: Colors.transparent,
        child: Consumer2<ControlNotifier, TextEditingNotifier>(
          builder: (_, controlNotifier, editorNotifier, __) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              body: GestureDetector(
                /// onTap => Close view and create/modify item object
                onTap: () => _onTap(context, controlNotifier, editorNotifier),
                child: Container(
                    decoration:
                        BoxDecoration(color: Colors.black.withOpacity(0.5)),
                    height: screenUtil.screenHeight,
                    width: screenUtil.screenWidth,
                    child: Stack(
                      children: [
                        /// text field
                        const Align(
                          alignment: Alignment.center,
                          child: TextFieldWidget(),
                        ),

                        /// text size
                        Visibility(
                          visible: !widget.isMandatory,
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: SizeSliderWidget(),
                          ),
                        ),

                        /// top tools - choose between regular or mandatory text tools
                        SafeArea(
                          child: Align(
                              alignment: Alignment.topCenter,
                              child: widget.isMandatory
                                  ? TopLastTextTools(
                                      onDone: () => _onTap(context,
                                          controlNotifier, editorNotifier),
                                    )
                                  : TopTextTools(
                                      onDone: () => _onTap(context,
                                          controlNotifier, editorNotifier),
                                    )),
                        ),

                        /// font family selector (bottom)
                        Positioned(
                          bottom: bottomInset,
                          child: Visibility(
                            visible: editorNotifier.isFontFamily &&
                                !widget.isMandatory,
                            child: const Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 0),
                                child: FontSelector(),
                              ),
                            ),
                          ),
                        ),

                        /// font color selector (bottom) - only for non-mandatory texts
                        Positioned(
                          bottom: bottomInset,
                          child: Visibility(
                              visible: !editorNotifier.isFontFamily &&
                                  !editorNotifier.isTextAnimation &&
                                  !editorNotifier.isBackgroundColorSelection,
                              child: const Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: ColorSelector(),
                                ),
                              )),
                        ),

                        /// background color selector for mandatory text
                        Positioned(
                          bottom: bottomInset,
                          child: Visibility(
                              visible:
                                  editorNotifier.isBackgroundColorSelection &&
                                      widget.isMandatory,
                              child: const Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: BackgroundColorSelector(),
                                ),
                              )),
                        ),

                        /// font animation selector (bottom) - only show for non-mandatory text
                        Positioned(
                          bottom: bottomInset,
                          child: Visibility(
                              visible: editorNotifier.isTextAnimation &&
                                  !widget.isMandatory,
                              child: const Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: AnimationSelector(),
                                ),
                              )),
                        ),
                      ],
                    )),
              ),
            );
          },
        ));
  }

  void _onTap(context, ControlNotifier controlNotifier,
      TextEditingNotifier editorNotifier) {
    final editableItemNotifier =
        Provider.of<DraggableWidgetNotifier>(context, listen: false);

    // Per i testi obbligatori, se il campo è vuoto impostiamo un testo di default
    if (widget.isMandatory && editorNotifier.text.trim().isEmpty) {
      editorNotifier.text = "La tua last";
      editorNotifier.textController.text = "La tua last";
    }

    /// create text list
    if (editorNotifier.text.trim().isNotEmpty) {
      splitList = editorNotifier.text.split(' ');
      for (int i = 0; i < splitList.length; i++) {
        if (i == 0) {
          editorNotifier.textList.add(splitList[0]);
          sequenceList = splitList[0];
        } else {
          lastSequenceList = sequenceList;
          editorNotifier.textList.add('$lastSequenceList ${splitList[i]}');
          sequenceList = '$lastSequenceList ${splitList[i]}';
        }
      }

      /// create Text Item with different settings for regular vs mandatory text
      editableItemNotifier.editableItems.add(EditableItem(
          type: ItemType.text,
          position: const Offset(0.0, 0.0),
          isMandatory: widget.isMandatory)
        ..text = editorNotifier.text.trim()
        ..backGroundColor = editorNotifier.backGroundColor
        ..textColor = widget.isMandatory
            ? editorNotifier
                .getTextColorForBackground() // Colore automatico per testi obbligatori
            : controlNotifier.colorList![
                editorNotifier.textColor] // Colore scelto per testi normali
        ..fontFamily = editorNotifier.fontFamilyIndex
        ..fontSize = editorNotifier.textSize
        ..fontAnimationIndex = widget.isMandatory
            ? 0
            : editorNotifier
                .fontAnimationIndex // Nessuna animazione per testi obbligatori
        ..textAlign = editorNotifier.textAlign
        ..textList = editorNotifier.textList
        ..animationType = widget.isMandatory
            ? TextAnimationType.none
            : editorNotifier.animationList[editorNotifier.fontAnimationIndex]);

      editorNotifier.setDefaults();
      controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
    } else if (widget.isMandatory) {
      // Se il testo è obbligatorio e il campo è vuoto, aggiungiamo comunque il testo di default
      editorNotifier.text = "La tua last";
      editorNotifier.textController.text = "La tua last";

      // Richiama ricorsivamente il metodo per creare l'elemento con il testo di default
      _onTap(context, controlNotifier, editorNotifier);
    } else {
      editorNotifier.setDefaults();
      controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }
}
