import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hy.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hy'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Авто Армения'**
  String get appTitle;

  /// No description provided for @parts.
  ///
  /// In ru, this message translates to:
  /// **'Запчасти'**
  String get parts;

  /// No description provided for @repair.
  ///
  /// In ru, this message translates to:
  /// **'Ремонт'**
  String get repair;

  /// No description provided for @selectCar.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать авто'**
  String get selectCar;

  /// No description provided for @partsCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории запчастей'**
  String get partsCategories;

  /// No description provided for @partSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Артикул или OEM-номер'**
  String get partSearchHint;

  /// No description provided for @locationFallback.
  ///
  /// In ru, this message translates to:
  /// **'Местоположение недоступно. Используем Ереван как центр поиска.'**
  String get locationFallback;

  /// No description provided for @locationSettingsHelp.
  ///
  /// In ru, this message translates to:
  /// **'Разрешите доступ к местоположению в настройках для точного поиска.'**
  String get locationSettingsHelp;

  /// No description provided for @generationNotSpecified.
  ///
  /// In ru, this message translates to:
  /// **'Поколение не указано'**
  String get generationNotSpecified;

  /// No description provided for @categoriesLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить категории'**
  String get categoriesLoadError;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @selectMake.
  ///
  /// In ru, this message translates to:
  /// **'Выберите марку'**
  String get selectMake;

  /// No description provided for @makeSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск марки...'**
  String get makeSearchHint;

  /// No description provided for @makesLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить марки'**
  String get makesLoadError;

  /// No description provided for @makeNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Марка не найдена. Проверьте написание.'**
  String get makeNotFound;

  /// No description provided for @modelSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск модели...'**
  String get modelSearchHint;

  /// No description provided for @modelsLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить модели'**
  String get modelsLoadError;

  /// No description provided for @modelNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Модель не найдена. Проверьте написание.'**
  String get modelNotFound;

  /// No description provided for @generationsLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить поколения'**
  String get generationsLoadError;

  /// No description provided for @skipGeneration.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить (поколение не важно)'**
  String get skipGeneration;

  /// No description provided for @fromYear.
  ///
  /// In ru, this message translates to:
  /// **'с {year}'**
  String fromYear(int year);

  /// No description provided for @yourCar.
  ///
  /// In ru, this message translates to:
  /// **'Ваше авто'**
  String get yourCar;

  /// No description provided for @make.
  ///
  /// In ru, this message translates to:
  /// **'Марка'**
  String get make;

  /// No description provided for @model.
  ///
  /// In ru, this message translates to:
  /// **'Модель'**
  String get model;

  /// No description provided for @generation.
  ///
  /// In ru, this message translates to:
  /// **'Поколение'**
  String get generation;

  /// No description provided for @confirmSelection.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить выбор'**
  String get confirmSelection;

  /// No description provided for @connectionHelp.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте подключение и попробуйте снова'**
  String get connectionHelp;

  /// No description provided for @serviceCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории услуг'**
  String get serviceCategories;

  /// No description provided for @serviceCategoriesLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить категории услуг'**
  String get serviceCategoriesLoadError;

  /// No description provided for @serviceCategoryOpenError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть категорию'**
  String get serviceCategoryOpenError;

  /// No description provided for @serviceCategoryNoLocation.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось определить местоположение'**
  String get serviceCategoryNoLocation;

  /// No description provided for @results.
  ///
  /// In ru, this message translates to:
  /// **'Результаты'**
  String get results;

  /// No description provided for @searchResultsFor.
  ///
  /// In ru, this message translates to:
  /// **'Поиск: {query}'**
  String searchResultsFor(String query);

  /// No description provided for @sortAndFilters.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка и фильтры'**
  String get sortAndFilters;

  /// No description provided for @sort.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get sort;

  /// No description provided for @filters.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters;

  /// No description provided for @sortDistance.
  ///
  /// In ru, this message translates to:
  /// **'По расстоянию'**
  String get sortDistance;

  /// No description provided for @sortPrice.
  ///
  /// In ru, this message translates to:
  /// **'По цене'**
  String get sortPrice;

  /// No description provided for @sortRating.
  ///
  /// In ru, this message translates to:
  /// **'По рейтингу'**
  String get sortRating;

  /// No description provided for @radiusKm.
  ///
  /// In ru, this message translates to:
  /// **'Радиус: {value} км'**
  String radiusKm(int value);

  /// No description provided for @distanceMeters.
  ///
  /// In ru, this message translates to:
  /// **'{value} м'**
  String distanceMeters(int value);

  /// No description provided for @distanceKilometers.
  ///
  /// In ru, this message translates to:
  /// **'{value} км'**
  String distanceKilometers(String value);

  /// No description provided for @availabilityOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только в наличии'**
  String get availabilityOnly;

  /// No description provided for @priceAmd.
  ///
  /// In ru, this message translates to:
  /// **'Цена, AMD'**
  String get priceAmd;

  /// No description provided for @priceValueAmd.
  ///
  /// In ru, this message translates to:
  /// **'{value} AMD'**
  String priceValueAmd(num value);

  /// No description provided for @priceFromAmd.
  ///
  /// In ru, this message translates to:
  /// **'от {value} AMD'**
  String priceFromAmd(num value);

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// No description provided for @list.
  ///
  /// In ru, this message translates to:
  /// **'Список'**
  String get list;

  /// No description provided for @map.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get map;

  /// No description provided for @mapUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Карта недоступна'**
  String get mapUnavailable;

  /// No description provided for @nothingNearby.
  ///
  /// In ru, this message translates to:
  /// **'Поблизости ничего не найдено'**
  String get nothingNearby;

  /// No description provided for @nothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get nothingFound;

  /// No description provided for @nothingFoundHelp.
  ///
  /// In ru, this message translates to:
  /// **'Поблизости нет подходящих продавцов. Попробуйте изменить категорию или фильтры.'**
  String get nothingFoundHelp;

  /// No description provided for @backToCategories.
  ///
  /// In ru, this message translates to:
  /// **'Назад к категориям'**
  String get backToCategories;

  /// No description provided for @resultsLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить результаты'**
  String get resultsLoadError;

  /// No description provided for @locationDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Геолокация выключена'**
  String get locationDisabled;

  /// No description provided for @locationDisabledHelp.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы показать ближайших продавцов, разрешите доступ к местоположению. Пока показываем результаты для центра Еревана.'**
  String get locationDisabledHelp;

  /// No description provided for @openSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get openSettings;

  /// No description provided for @partsShop.
  ///
  /// In ru, this message translates to:
  /// **'Магазин запчастей'**
  String get partsShop;

  /// No description provided for @repairShop.
  ///
  /// In ru, this message translates to:
  /// **'Автосервис'**
  String get repairShop;

  /// No description provided for @itemCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} позиция} few{{count} позиции} many{{count} позиций} other{{count} позиций}}'**
  String itemCount(int count);

  /// No description provided for @serviceCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} услуга} few{{count} услуги} many{{count} услуг} other{{count} услуг}}'**
  String serviceCount(int count);

  /// No description provided for @vendor.
  ///
  /// In ru, this message translates to:
  /// **'Продавец'**
  String get vendor;

  /// No description provided for @verifiedVendor.
  ///
  /// In ru, this message translates to:
  /// **'Проверенный продавец'**
  String get verifiedVendor;

  /// No description provided for @ratingOutOfFive.
  ///
  /// In ru, this message translates to:
  /// **'{rating} из 5'**
  String ratingOutOfFive(String rating);

  /// No description provided for @openingHours.
  ///
  /// In ru, this message translates to:
  /// **'Часы работы'**
  String get openingHours;

  /// No description provided for @weekdaysShort.
  ///
  /// In ru, this message translates to:
  /// **'Пн–Пт'**
  String get weekdaysShort;

  /// No description provided for @saturdayShort.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get sundayShort;

  /// No description provided for @call.
  ///
  /// In ru, this message translates to:
  /// **'Позвонить'**
  String get call;

  /// No description provided for @route.
  ///
  /// In ru, this message translates to:
  /// **'Маршрут'**
  String get route;

  /// No description provided for @openAppError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть приложение'**
  String get openAppError;

  /// No description provided for @vendorLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить продавца'**
  String get vendorLoadError;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @russian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @armenian.
  ///
  /// In ru, this message translates to:
  /// **'Հայերեն'**
  String get armenian;

  /// No description provided for @english.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get english;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hy', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hy':
      return AppLocalizationsHy();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
