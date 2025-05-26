// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:mime/mime.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/generated/l10n.dart';
import 'package:stories_editor/src/domain/models/editable_items.dart';
import 'package:stories_editor/src/domain/models/geo_point.dart';
import 'package:stories_editor/src/domain/models/painting_model.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/gradient_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/scroll_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:stories_editor/src/presentation/bar_tools/bottom_tools.dart';
import 'package:stories_editor/src/presentation/bar_tools/top_tools.dart';
import 'package:stories_editor/src/presentation/draggable_items/delete_item.dart';
import 'package:stories_editor/src/presentation/draggable_items/draggable_widget.dart';
import 'package:stories_editor/src/presentation/painting_view/painting.dart';
import 'package:stories_editor/src/presentation/painting_view/widgets/sketcher.dart';
import 'package:stories_editor/src/presentation/text_editor_view/text_editor.dart';
import 'package:stories_editor/src/presentation/utils/constants/app_enums.dart';
import 'package:stories_editor/src/presentation/utils/modal_sheets.dart';
import 'package:stories_editor/src/presentation/widgets/animated_onTap_button.dart';
import 'package:stories_editor/src/presentation/widgets/scrollable_pageView.dart';
import 'package:video_player/video_player.dart';

class MainView extends StatefulWidget {
  /// editor custom font families
  final List<String>? fontFamilyList;

  /// editor custom font families package
  final bool? isCustomFontList;

  /// giphy api key
  final String giphyKey;

  /// editor custom color gradients
  final List<List<Color>>? gradientColors;

  /// editor custom logo
  final Widget? middleBottomWidget;

  /// on done
  final Function(String)? onDone;

  /// on done button Text
  final Widget? onDoneButtonStyle;

  /// on back pressed
  final Future<bool>? onBackPress;

  /// editor background color
  Color? editorBackgroundColor;

  /// gallery thumbnail quality
  final int? galleryThumbnailQuality;

  /// editor custom color palette list
  List<Color>? colorList;

  /// aspect ratio of the final image
  final double storyAspectRatio;

  /// Flag che indica se l'editor deve avere elementi obbligatori
  final bool isLast;

  /// GeoPoint per l'elemento di localizzazione quando isLast è true
  final GeoPoint? location;

  /// Colore di sfondo per il testo obbligatorio quando isLast è true
  final Color? textBackgroundColor;

  /// Durata minima video (null se non applicato)
  final Duration? minVideoDuration;

  /// Durata massima video (null se non applicato)
  final Duration? maxVideoDuration;

  MainView({
    Key? key,
    required this.giphyKey,
    required this.onDone,
    this.middleBottomWidget,
    this.colorList,
    this.isCustomFontList,
    this.fontFamilyList,
    this.gradientColors,
    this.onBackPress,
    this.onDoneButtonStyle,
    this.editorBackgroundColor,
    this.galleryThumbnailQuality,
    required this.storyAspectRatio,
    this.isLast = false,
    this.location,
    this.minVideoDuration,
    this.maxVideoDuration,
    this.textBackgroundColor,
  }) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  /// content container key
  final GlobalKey contentKey = GlobalKey();

  ///Editable item
  EditableItem? _activeItem;

  /// Gesture Detector listen changes
  Offset _initPos = const Offset(0, 0);
  Offset _currentPos = const Offset(0, 0);
  double _currentScale = 1;
  double _currentRotation = 0;

  /// delete position
  bool _isDeletePosition = false;
  bool _inAction = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var control = Provider.of<ControlNotifier>(context, listen: false);
      var itemProvider =
          Provider.of<DraggableWidgetNotifier>(context, listen: false);

      /// initialize control variable provider
      control.giphyKey = widget.giphyKey;
      control.middleBottomWidget = widget.middleBottomWidget;
      if (widget.isCustomFontList != null) {
        control.isCustomFontList = widget.isCustomFontList!;
      }

      /// check whether the user has provided custom colors and fonts
      if (widget.fontFamilyList != null) {
        control.fontList = widget.fontFamilyList;
      }
      if (widget.colorList != null) {
        control.colorList = widget.colorList;
      }
      if (widget.gradientColors != null) {
        control.gradientColors = widget.gradientColors;
      }

      /// Aggiungi elementi obbligatori se isLast è true
      if (widget.isLast) {
        // Aggiungi il testo obbligatorio
        final textItem = EditableItem(
          type: ItemType.text,
          position: const Offset(0.0, 0.0),
          isMandatory: true,
        );
        textItem.text = "Il tuo Last";
        textItem.textColor = Colors.white;
        textItem.backGroundColor = Colors.pink;
        textItem.fontSize = 30;
        textItem.fontFamily = 1;
        itemProvider.editableItems.add(textItem);

        // Aggiungi il widget di localizzazione obbligatorio (se c'è il geoPoint)
        if (widget.location != null) {
          final locationItem = EditableItem(
            type: ItemType.location,
            position: const Offset(0.0, 0.2),
            isMandatory: true,
          );
          locationItem.location = widget.location;
          locationItem.scale = 1.5;
          itemProvider.editableItems.add(locationItem);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = ScreenUtil();
    return WillPopScope(
      onWillPop: _popScope,
      child: Material(
        color: widget.editorBackgroundColor == Colors.transparent
            ? Colors.black
            : widget.editorBackgroundColor ?? Colors.black,
        child: Consumer6<
            ControlNotifier,
            DraggableWidgetNotifier,
            ScrollNotifier,
            GradientNotifier,
            PaintingNotifier,
            TextEditingNotifier>(
          builder: (context, controlNotifier, itemProvider, scrollProvider,
              colorProvider, paintingProvider, editingProvider, child) {
            return SafeArea(
              //top: false,
              child: ScrollablePageView(
                scrollPhysics: controlNotifier.mediaPath.isEmpty &&
                    itemProvider.editableItems.isEmpty &&
                    !controlNotifier.isPainting &&
                    !controlNotifier.isTextEditing,
                pageController: scrollProvider.pageController,
                gridController: scrollProvider.gridController,
                mainView: Column(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: widget.storyAspectRatio,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ///gradient container
                            /// this container will contain all widgets(image/texts/draws/sticker)
                            /// wrap this widget with coloredFilter
                            GestureDetector(
                              onTap: () {
                                if (!controlNotifier.isPainting &&
                                    !controlNotifier.isTextEditing) {
                                  controlNotifier.isLast = false;
                                  controlNotifier.isTextEditing =
                                      !controlNotifier.isTextEditing;
                                }
                              },
                              onScaleStart: _onScaleStart,
                              onScaleUpdate: _onScaleUpdate,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: SizedBox(
                                    width: screenUtil.screenWidth,
                                    child: RepaintBoundary(
                                      key: contentKey,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                          gradient: controlNotifier
                                                  .mediaPath.isEmpty
                                              ? LinearGradient(
                                                  colors: controlNotifier
                                                          .gradientColors![
                                                      controlNotifier
                                                          .gradientIndex],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : LinearGradient(
                                                  colors: [
                                                    colorProvider.color1,
                                                    colorProvider.color2
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                        ),
                                        child: GestureDetector(
                                          onScaleStart: _onScaleStart,
                                          onScaleUpdate: _onScaleUpdate,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              /// in this case photo view works as a main background container to manage
                                              /// the gestures of all movable items.
                                              PhotoView.customChild(
                                                backgroundDecoration:
                                                    const BoxDecoration(
                                                        color:
                                                            Colors.transparent),
                                                child: Container(),
                                              ),

                                              ///list items
                                              ...itemProvider.editableItems
                                                  .map((editableItem) {
                                                return DraggableWidget(
                                                  context: context,
                                                  draggableWidget: editableItem,
                                                  onPointerDown: (details) {
                                                    _updateItemPosition(
                                                      editableItem,
                                                      details,
                                                    );
                                                  },
                                                  onPointerUp: (details) {
                                                    _deleteItemOnCoordinates(
                                                      editableItem,
                                                      details,
                                                    );
                                                  },
                                                  onPointerMove: (details) {
                                                    _deletePosition(
                                                      editableItem,
                                                      details,
                                                    );
                                                  },
                                                );
                                              }),

                                              /// finger paint
                                              IgnorePointer(
                                                ignoring: true,
                                                child: Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                    child: RepaintBoundary(
                                                      child: SizedBox(
                                                        width: screenUtil
                                                            .screenWidth,
                                                        child: StreamBuilder<
                                                            List<
                                                                PaintingModel>>(
                                                          stream: paintingProvider
                                                              .linesStreamController
                                                              .stream,
                                                          builder: (context,
                                                              snapshot) {
                                                            return CustomPaint(
                                                              painter: Sketcher(
                                                                lines:
                                                                    paintingProvider
                                                                        .lines,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            /// middle text
                            if (itemProvider.editableItems.isEmpty &&
                                !controlNotifier.isTextEditing &&
                                paintingProvider.lines.isEmpty &&
                                canEdit(itemProvider.editableItems))
                              IgnorePointer(
                                ignoring: true,
                                child: Align(
                                  alignment: const Alignment(0, -0.1),
                                  child: Text(S.of(context).tapToType,
                                      style: TextStyle(
                                          fontFamily: 'Alegreya',
                                          package: 'stories_editor',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 30,
                                          color: Colors.white.withOpacity(0.5),
                                          shadows: <Shadow>[
                                            Shadow(
                                                offset: const Offset(1.0, 1.0),
                                                blurRadius: 3.0,
                                                color: Colors.black45
                                                    .withOpacity(0.3))
                                          ])),
                                ),
                              ),

                            /// top tools
                            Visibility(
                              visible: !controlNotifier.isTextEditing &&
                                  !controlNotifier.isPainting,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: TopTools(
                                  contentKey: contentKey,
                                  context: context,
                                  canEdit: canEdit(itemProvider.editableItems),
                                ),
                              ),
                            ),

                            /// delete item when the item is in position
                            DeleteItem(
                              activeItem: _activeItem,
                              animationsDuration:
                                  const Duration(milliseconds: 300),
                              isDeletePosition: _isDeletePosition,
                            ),

                            /// show text editor
                            Visibility(
                              visible: controlNotifier.isTextEditing,
                              child: TextEditor(
                                context: context,
                                isMandatory: controlNotifier.isLast,
                              ),
                            ),

                            /// show painting sketch
                            Visibility(
                              visible: controlNotifier.isPainting,
                              child: const Painting(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// bottom tools
                    if (!kIsWeb)
                      BottomTools(
                        contentKey: contentKey,
                        editableItems: itemProvider.editableItems,
                        onDone: widget.onDone!,
                        onDoneButtonStyle: widget.onDoneButtonStyle,
                        editorBackgroundColor: widget.editorBackgroundColor,
                        mediaPath: controlNotifier.mediaPath,
                      ),
                  ],
                ),
                gallery: GalleryMediaPicker(
                  gridViewController: scrollProvider.gridController,
                  thumbnailQuality: widget.galleryThumbnailQuality,
                  singlePick: true,
                  requestType: widget.isLast
                      ? RequestType.image
                      : RequestType.common,
                  appBarColor: widget.editorBackgroundColor ?? Colors.black,
                  gridViewPhysics: itemProvider.editableItems.isEmpty
                      ? const NeverScrollableScrollPhysics()
                      : const ScrollPhysics(),
                  pathList: (final List<PickedAssetModel> pickedAssets) async {
                    final pickedAsset = pickedAssets.single;
                    final String? mimeType = lookupMimeType(pickedAsset.path!);
                    if (mimeType == null) {
                      throw Exception(
                          'Mime type per path: ${pickedAsset.path} è null');
                    }
                    late final ItemType type;
                    if (mimeType.startsWith('image')) {
                      type = ItemType.image;
                    } else if (mimeType.startsWith('video')) {
                      type = ItemType.video;
                      // Non permettere video in modalità isLast
                      if (widget.isLast) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Non puoi caricare video nell'ultimo story")),
                        );
                        return;
                      }
                      // Filtro durata minima e massima
                      if (widget.minVideoDuration != null ||
                          widget.maxVideoDuration != null) {
                        final controller =
                            VideoPlayerController.file(File(pickedAsset.path!));
                        await controller.initialize();
                        final duration = controller.value.duration;
                        await controller.dispose();
                        if (widget.minVideoDuration != null &&
                            duration < widget.minVideoDuration!) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Il video deve durare almeno ${widget.minVideoDuration!.inSeconds} secondi")),
                          );
                          return;
                        }
                        if (widget.maxVideoDuration != null &&
                            duration > widget.maxVideoDuration!) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Il video deve durare massimo ${widget.maxVideoDuration!.inSeconds} secondi")),
                          );
                          return;
                        }
                      }
                    } else {
                      throw Exception(
                          'Mime type $mimeType per path: ${pickedAsset.path} non supportato');
                    }
                    controlNotifier.mediaPath = pickedAsset.path!;
                    if (controlNotifier.mediaPath.isNotEmpty) {
                      itemProvider.editableItems.insert(
                        0,
                        EditableItem(type: type, position: const Offset(0.0, 0)),
                      );
                    }
                    scrollProvider.pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  appBarLeadingWidget: Padding(
                    padding: const EdgeInsets.only(bottom: 15, right: 15),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: AnimatedOnTapButton(
                        onTap: () {
                          scrollProvider.pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.2,
                              )),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool canEdit(final List<EditableItem> items) =>
      !items.any((final EditableItem item) => item.type == ItemType.video);

  /// validate pop scope gesture
  Future<bool> _popScope() async {
    final controlNotifier =
        Provider.of<ControlNotifier>(context, listen: false);

    /// change to false text editing
    if (controlNotifier.isTextEditing) {
      controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
      return false;
    }

    /// change to false painting
    else if (controlNotifier.isPainting) {
      controlNotifier.isPainting = !controlNotifier.isPainting;
      return false;
    }

    /// show close dialog
    else if (!controlNotifier.isTextEditing && !controlNotifier.isPainting) {
      return widget.onBackPress ??
          exitDialog(context: context, contentKey: contentKey);
    }
    return false;
  }

  /// start item scale
  void _onScaleStart(ScaleStartDetails details) {
    if (_activeItem == null) {
      return;
    }
    _initPos = details.focalPoint;
    _currentPos = _activeItem!.position;
    _currentScale = _activeItem!.scale;
    _currentRotation = _activeItem!.rotation;
  }

  /// update item scale
  void _onScaleUpdate(ScaleUpdateDetails details) {
    final ScreenUtil screenUtil = ScreenUtil();
    if (_activeItem == null) {
      return;
    }
    final delta = details.focalPoint - _initPos;

    final left = (delta.dx / screenUtil.screenWidth) + _currentPos.dx;
    final top = (delta.dy / screenUtil.screenHeight) + _currentPos.dy;

    setState(() {
      _activeItem!.position = Offset(left, top);
      _activeItem!.rotation = details.rotation + _currentRotation;
      _activeItem!.scale = details.scale * _currentScale;
    });
  }

  /// active delete widget with offset position
  void _deletePosition(EditableItem item, PointerMoveEvent details) {
    // Non rimpicciolire o eliminare elementi obbligatori
    if (item.isMandatory) {
      setState(() {
        _isDeletePosition = false;
        item.deletePosition = false;
      });
      return;
    }
    if (item.type == ItemType.text &&
        item.position.dy >= 0.75.h &&
        item.position.dx >= -0.4.w &&
        item.position.dx <= 0.2.w) {
      setState(() {
        _isDeletePosition = true;
        item.deletePosition = true;
      });
    } else if (item.type == ItemType.gif &&
        item.position.dy >= 0.62.h &&
        item.position.dx >= -0.35.w &&
        item.position.dx <= 0.15) {
      setState(() {
        _isDeletePosition = true;
        item.deletePosition = true;
      });
    } else {
      setState(() {
        _isDeletePosition = false;
        item.deletePosition = false;
      });
    }
  }

  /// delete item widget with offset position
  void _deleteItemOnCoordinates(EditableItem item, PointerUpEvent details) {
    var itemProvider =
        Provider.of<DraggableWidgetNotifier>(context, listen: false)
            .editableItems;
    _inAction = false;

    // Verificare se l'elemento è obbligatorio (isMandatory)
    // Se è obbligatorio, non permettere l'eliminazione
    if (item.isMandatory) {
      setState(() {
        _activeItem = null;
        _isDeletePosition = false;
      });
      return;
    }

    if (item.type == ItemType.image) {
    } else if (item.type == ItemType.text &&
            item.position.dy >= 0.75.h &&
            item.position.dx >= -0.4.w &&
            item.position.dx <= 0.2.w ||
        item.type == ItemType.gif &&
            item.position.dy >= 0.62.h &&
            item.position.dx >= -0.35.w &&
            item.position.dx <= 0.15) {
      setState(() {
        itemProvider.removeAt(itemProvider.indexOf(item));
        HapticFeedback.heavyImpact();
      });
    } else {
      setState(() {
        _activeItem = null;
      });
    }
    setState(() {
      _activeItem = null;
    });
  }

  /// update item position, scale, rotation
  void _updateItemPosition(EditableItem item, PointerDownEvent details) {
    if (_inAction) {
      return;
    }

    _inAction = true;
    _activeItem = item;
    _initPos = details.position;
    _currentPos = item.position;
    _currentScale = item.scale;
    _currentRotation = item.rotation;

    /// set vibrate
    HapticFeedback.lightImpact();
  }
}
