// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Annullare le modifiche?`
  String get discardEdits {
    return Intl.message(
      'Annullare le modifiche?',
      name: 'discardEdits',
      desc: '',
      args: [],
    );
  }

  /// `Se si esce ora, tutte le modifiche apportate alle feature non salvate andranno perse.`
  String get discardEditsExtended {
    return Intl.message(
      'Se si esce ora, tutte le modifiche apportate alle feature non salvate andranno perse.',
      name: 'discardEditsExtended',
      desc: '',
      args: [],
    );
  }

  /// `Annulla`
  String get discard {
    return Intl.message(
      'Annulla',
      name: 'discard',
      desc: '',
      args: [],
    );
  }

  /// `Salvato con successo`
  String get successfullySaved {
    return Intl.message(
      'Salvato con successo',
      name: 'successfullySaved',
      desc: '',
      args: [],
    );
  }

  /// `Errore`
  String get error {
    return Intl.message(
      'Errore',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Nulla da salvare`
  String get nothingToSave {
    return Intl.message(
      'Nulla da salvare',
      name: 'nothingToSave',
      desc: '',
      args: [],
    );
  }

  /// `Salva bozza`
  String get saveDraft {
    return Intl.message(
      'Salva bozza',
      name: 'saveDraft',
      desc: '',
      args: [],
    );
  }

  /// `Cancella`
  String get cancel {
    return Intl.message(
      'Cancella',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Fatto`
  String get done {
    return Intl.message(
      'Fatto',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Toccare per digitare`
  String get tapToType {
    return Intl.message(
      'Toccare per digitare',
      name: 'tapToType',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'it'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
