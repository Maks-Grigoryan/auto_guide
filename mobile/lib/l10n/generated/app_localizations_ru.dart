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
  String get skipGeneration => 'Пропустить';

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

  @override
  String get noModelsForMake => 'Для этой марки пока нет моделей.';

  @override
  String get noMakesInCatalog => 'Каталог марок пуст.';

  @override
  String get authTitle => 'Вход в приложение';

  @override
  String get authSubtitle => 'Запчасти и автосервисы рядом с вами';

  @override
  String get authSignInTab => 'Вход';

  @override
  String get authSignUpTab => 'Регистрация';

  @override
  String get authIdentifierLabel => 'Телефон или e-mail';

  @override
  String get authIdentifierInvalid => 'Это не похоже на телефон или e-mail';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authPasswordRepeatLabel => 'Повторите пароль';

  @override
  String get authSignInButton => 'Войти';

  @override
  String get authSignUpButton => 'Зарегистрироваться';

  @override
  String get authIdentifierRequired => 'Введите телефон или e-mail';

  @override
  String get authPasswordRequired => 'Введите пароль';

  @override
  String get authPasswordTooShort => 'Пароль должен быть не короче 8 символов';

  @override
  String get authPasswordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get authInvalidCredentials => 'Неверный телефон, e-mail или пароль';

  @override
  String get authAccountExists => 'Аккаунт с такими данными уже существует';

  @override
  String get authTooManyAttempts => 'Слишком много попыток. Подождите минуту';

  @override
  String get authNetworkError => 'Сервер недоступен. Проверьте соединение';

  @override
  String get authUnknownError =>
      'Не удалось выполнить вход. Попробуйте ещё раз';

  @override
  String authSignedInAs(String name) {
    return 'Вы вошли как $name';
  }

  @override
  String get authAdminBadge => 'Администратор';

  @override
  String get authSignOut => 'Выйти';

  @override
  String get authCodeTitle => 'Подтвердите контакт';

  @override
  String authCodeSentTo(String target) {
    return 'Код отправлен на $target';
  }

  @override
  String get authCodeLabel => 'Код из 6 цифр';

  @override
  String get authConfirmButton => 'Подтвердить';

  @override
  String get authResendCode => 'Отправить код ещё раз';

  @override
  String get authCodeResent => 'Код отправлен повторно';

  @override
  String get authChangeContact => 'Изменить контакт';

  @override
  String get authCodeRequired => 'Введите код из 6 цифр';

  @override
  String get authCodeInvalid => 'Неверный код';

  @override
  String get authCodeExpired => 'Код устарел. Запросите новый';

  @override
  String get hubSectionsLabel => 'Разделы';

  @override
  String get hubParts => 'Запчасти';

  @override
  String get hubPartsHint => 'Магазины рядом с вами';

  @override
  String get hubRepair => 'Ремонт';

  @override
  String get hubRepairHint => 'Автосервисы рядом с вами';

  @override
  String get hubPartsRepair => 'Запчасти и ремонт';

  @override
  String get hubPartsRepairHint => 'Магазины и автосервисы рядом с вами';

  @override
  String get hubRoadside => 'Помощь на дороге';

  @override
  String get hubRoadsideHint => 'Эвакуатор и помощь на месте';

  @override
  String get hubComingSoon => 'Скоро';

  @override
  String get hubComingSoonMessage => 'Раздел скоро появится';

  @override
  String get aiChatBarPrompt => 'Спросите помощника о машине';

  @override
  String get aiChatTitle => 'Помощник';

  @override
  String get aiChatInputHint => 'Опишите проблему...';

  @override
  String get aiChatSend => 'Отправить';

  @override
  String get aiChatGreeting => 'Что случилось с машиной?';

  @override
  String get aiChatGreetingHint =>
      'Опишите проблему своими словами — помогу понять причину и найти нужную деталь рядом с вами.';

  @override
  String get aiChatExamplesLabel => 'Например';

  @override
  String get aiChatExampleKnock => 'Стучит спереди на кочках';

  @override
  String get aiChatExamplePads => 'Нужны тормозные колодки';

  @override
  String get aiChatExampleOil => 'Какое масло заливать?';

  @override
  String get aiChatDisclaimer =>
      'Помощник называет вероятные причины и не заменяет осмотр на сервисе.';

  @override
  String get aiChatNotConnected =>
      'Помощник пока не подключён — готов только интерфейс. Скоро он сможет искать детали в каталоге и отвечать на вопросы.';

  @override
  String get yearLabel => 'Год выпуска';

  @override
  String get yearNotSpecified => 'Не указан';

  @override
  String get selectYear => 'Выберите год';

  @override
  String get yearSkip => 'Не указывать год';
}
