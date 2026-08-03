// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Auto Armenia';

  @override
  String get parts => 'Parts';

  @override
  String get repair => 'Repair';

  @override
  String get selectCar => 'Select a car';

  @override
  String get partsCategories => 'Part categories';

  @override
  String get partSearchHint => 'Part or OEM number';

  @override
  String get locationFallback =>
      'Location is unavailable. Using Yerevan as the search center.';

  @override
  String get locationSettingsHelp =>
      'Allow location access in Settings for accurate nearby results.';

  @override
  String get generationNotSpecified => 'Generation not specified';

  @override
  String get categoriesLoadError => 'Could not load categories';

  @override
  String get retry => 'Try again';

  @override
  String get selectMake => 'Select make';

  @override
  String get makeSearchHint => 'Search makes...';

  @override
  String get makesLoadError => 'Could not load makes';

  @override
  String get makeNotFound => 'Make not found. Check the spelling.';

  @override
  String get modelSearchHint => 'Search models...';

  @override
  String get modelsLoadError => 'Could not load models';

  @override
  String get modelNotFound => 'Model not found. Check the spelling.';

  @override
  String get generationsLoadError => 'Could not load generations';

  @override
  String get skipGeneration => 'Skip (any generation)';

  @override
  String fromYear(int year) {
    return 'from $year';
  }

  @override
  String get yourCar => 'Your car';

  @override
  String get make => 'Make';

  @override
  String get model => 'Model';

  @override
  String get generation => 'Generation';

  @override
  String get confirmSelection => 'Confirm selection';

  @override
  String get connectionHelp => 'Check your connection and try again';

  @override
  String get serviceCategories => 'Service categories';

  @override
  String get serviceCategoriesLoadError => 'Could not load service categories';

  @override
  String get serviceCategoryOpenError => 'Could not open the category';

  @override
  String get serviceCategoryNoLocation => 'Could not determine your location';

  @override
  String get results => 'Results';

  @override
  String searchResultsFor(String query) {
    return 'Search: $query';
  }

  @override
  String get sortAndFilters => 'Sort and filters';

  @override
  String get sort => 'Sort';

  @override
  String get filters => 'Filters';

  @override
  String get sortDistance => 'By distance';

  @override
  String get sortPrice => 'By price';

  @override
  String get sortRating => 'By rating';

  @override
  String radiusKm(int value) {
    return 'Radius: $value km';
  }

  @override
  String distanceMeters(int value) {
    return '$value m';
  }

  @override
  String distanceKilometers(String value) {
    return '$value km';
  }

  @override
  String get availabilityOnly => 'In stock only';

  @override
  String get priceAmd => 'Price, AMD';

  @override
  String priceValueAmd(num value) {
    return '$value AMD';
  }

  @override
  String priceFromAmd(num value) {
    return 'from $value AMD';
  }

  @override
  String get reset => 'Reset';

  @override
  String get list => 'List';

  @override
  String get map => 'Map';

  @override
  String get mapUnavailable => 'Map unavailable';

  @override
  String get nothingNearby => 'Nothing found nearby';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get nothingFoundHelp =>
      'No matching vendors nearby. Try another category or filters.';

  @override
  String get backToCategories => 'Back to categories';

  @override
  String get resultsLoadError => 'Could not load results';

  @override
  String get locationDisabled => 'Location is disabled';

  @override
  String get locationDisabledHelp =>
      'Allow location access to find nearby vendors. For now, results are shown for central Yerevan.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get partsShop => 'Parts shop';

  @override
  String get repairShop => 'Repair shop';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String serviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count services',
      one: '$count service',
    );
    return '$_temp0';
  }

  @override
  String get vendor => 'Vendor';

  @override
  String get verifiedVendor => 'Verified vendor';

  @override
  String ratingOutOfFive(String rating) {
    return '$rating out of 5';
  }

  @override
  String get openingHours => 'Opening hours';

  @override
  String get weekdaysShort => 'Mon–Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  @override
  String get call => 'Call';

  @override
  String get route => 'Directions';

  @override
  String get openAppError => 'Could not open the app';

  @override
  String get vendorLoadError => 'Could not load vendor';

  @override
  String get language => 'Language';

  @override
  String get russian => 'Русский';

  @override
  String get armenian => 'Հայերեն';

  @override
  String get english => 'English';
}
