// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Авто Армения';

  @override
  String get parts => 'Запчасти';

  @override
  String get repair => 'Ремонт';

  @override
  String get selectCar => 'Выбрать авто';

  @override
  String get partsCategories => 'Категории запчастей';

  @override
  String get partSearchHint => 'Артикул или OEM-номер';

  @override
  String get locationFallback =>
      'Местоположение недоступно. Используем Ереван как центр поиска.';

  @override
  String get locationSettingsHelp =>
      'Разрешите доступ к местоположению в настройках для точного поиска.';

  @override
  String get generationNotSpecified => 'Поколение не указано';

  @override
  String get categoriesLoadError => 'Не удалось загрузить категории';

  @override
  String get retry => 'Повторить';

  @override
  String get selectMake => 'Выберите марку';

  @override
  String get makeSearchHint => 'Поиск марки...';

  @override
  String get makesLoadError => 'Не удалось загрузить марки';

  @override
  String get makeNotFound => 'Марка не найдена. Проверьте написание.';

  @override
  String get modelSearchHint => 'Поиск модели...';

  @override
  String get modelsLoadError => 'Не удалось загрузить модели';

  @override
  String get modelNotFound => 'Модель не найдена. Проверьте написание.';

  @override
  String get generationsLoadError => 'Не удалось загрузить поколения';

  @override
  String get skipGeneration => 'Пропустить (поколение не важно)';

  @override
  String fromYear(int year) {
    return 'с $year';
  }

  @override
  String get yourCar => 'Ваше авто';

  @override
  String get make => 'Марка';

  @override
  String get model => 'Модель';

  @override
  String get generation => 'Поколение';

  @override
  String get confirmSelection => 'Подтвердить выбор';

  @override
  String get connectionHelp => 'Проверьте подключение и попробуйте снова';

  @override
  String get serviceCategories => 'Категории услуг';

  @override
  String get serviceCategoriesLoadError =>
      'Не удалось загрузить категории услуг';

  @override
  String get serviceCategoryOpenError => 'Не удалось открыть категорию';

  @override
  String get serviceCategoryNoLocation =>
      'Не удалось определить местоположение';

  @override
  String get results => 'Результаты';

  @override
  String searchResultsFor(String query) {
    return 'Поиск: $query';
  }

  @override
  String get sortAndFilters => 'Сортировка и фильтры';

  @override
  String get sort => 'Сортировка';

  @override
  String get filters => 'Фильтры';

  @override
  String get sortDistance => 'По расстоянию';

  @override
  String get sortPrice => 'По цене';

  @override
  String get sortRating => 'По рейтингу';

  @override
  String radiusKm(int value) {
    return 'Радиус: $value км';
  }

  @override
  String distanceMeters(int value) {
    return '$value м';
  }

  @override
  String distanceKilometers(String value) {
    return '$value км';
  }

  @override
  String get availabilityOnly => 'Только в наличии';

  @override
  String get priceAmd => 'Цена, AMD';

  @override
  String priceValueAmd(num value) {
    return '$value AMD';
  }

  @override
  String priceFromAmd(num value) {
    return 'от $value AMD';
  }

  @override
  String get reset => 'Сбросить';

  @override
  String get list => 'Список';

  @override
  String get map => 'Карта';

  @override
  String get mapUnavailable => 'Карта недоступна';

  @override
  String get nothingNearby => 'Поблизости ничего не найдено';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get nothingFoundHelp =>
      'Поблизости нет подходящих продавцов. Попробуйте изменить категорию или фильтры.';

  @override
  String get backToCategories => 'Назад к категориям';

  @override
  String get resultsLoadError => 'Не удалось загрузить результаты';

  @override
  String get locationDisabled => 'Геолокация выключена';

  @override
  String get locationDisabledHelp =>
      'Чтобы показать ближайших продавцов, разрешите доступ к местоположению. Пока показываем результаты для центра Еревана.';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get partsShop => 'Магазин запчастей';

  @override
  String get repairShop => 'Автосервис';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count позиций',
      many: '$count позиций',
      few: '$count позиции',
      one: '$count позиция',
    );
    return '$_temp0';
  }

  @override
  String serviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count услуг',
      many: '$count услуг',
      few: '$count услуги',
      one: '$count услуга',
    );
    return '$_temp0';
  }

  @override
  String get vendor => 'Продавец';

  @override
  String get verifiedVendor => 'Проверенный продавец';

  @override
  String ratingOutOfFive(String rating) {
    return '$rating из 5';
  }

  @override
  String get openingHours => 'Часы работы';

  @override
  String get weekdaysShort => 'Пн–Пт';

  @override
  String get saturdayShort => 'Сб';

  @override
  String get sundayShort => 'Вс';

  @override
  String get call => 'Позвонить';

  @override
  String get route => 'Маршрут';

  @override
  String get openAppError => 'Не удалось открыть приложение';

  @override
  String get vendorLoadError => 'Не удалось загрузить продавца';

  @override
  String get language => 'Язык';

  @override
  String get russian => 'Русский';

  @override
  String get armenian => 'Հայերեն';

  @override
  String get english => 'English';
}
