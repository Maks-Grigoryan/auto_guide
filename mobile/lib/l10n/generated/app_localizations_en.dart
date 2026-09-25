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
  String get skipGeneration => 'Skip';

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

  @override
  String get noModelsForMake => 'This make has no models yet.';

  @override
  String get noMakesInCatalog => 'The make catalogue is empty.';

  @override
  String get authTitle => 'Sign in';

  @override
  String get authSubtitle => 'Car parts and workshops near you';

  @override
  String get authSignInTab => 'Sign in';

  @override
  String get authSignUpTab => 'Register';

  @override
  String get authIdentifierLabel => 'Phone or email';

  @override
  String get authIdentifierInvalid =>
      'That does not look like a phone number or an email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordRepeatLabel => 'Repeat password';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authSignUpButton => 'Create account';

  @override
  String get authIdentifierRequired => 'Enter a phone number or email';

  @override
  String get authPasswordRequired => 'Enter your password';

  @override
  String get authPasswordTooShort => 'Password must be at least 8 characters';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authInvalidCredentials => 'Wrong phone, email or password';

  @override
  String get authAccountExists =>
      'An account with these details already exists';

  @override
  String get authTooManyAttempts => 'Too many attempts. Wait a minute';

  @override
  String get authNetworkError => 'Server unreachable. Check your connection';

  @override
  String get authUnknownError => 'Could not sign in. Please try again';

  @override
  String authSignedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get authAdminBadge => 'Administrator';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authCodeTitle => 'Confirm your contact';

  @override
  String authCodeSentTo(String target) {
    return 'Code sent to $target';
  }

  @override
  String get authCodeLabel => '6-digit code';

  @override
  String get authConfirmButton => 'Confirm';

  @override
  String get authResendCode => 'Send the code again';

  @override
  String get authCodeResent => 'Code sent again';

  @override
  String get authChangeContact => 'Change contact';

  @override
  String get authCodeRequired => 'Enter the 6-digit code';

  @override
  String get authCodeInvalid => 'Wrong code';

  @override
  String get authCodeExpired => 'The code has expired. Request a new one';

  @override
  String get hubSectionsLabel => 'Sections';

  @override
  String get hubParts => 'Parts';

  @override
  String get hubPartsHint => 'Shops near you';

  @override
  String get hubRepair => 'Repair';

  @override
  String get hubRepairHint => 'Garages near you';

  @override
  String get hubPartsRepair => 'Parts and repair';

  @override
  String get hubPartsRepairHint => 'Shops and services near you';

  @override
  String get hubRoadside => 'Roadside assistance';

  @override
  String get hubRoadsideHint => 'Towing and on-the-spot help';

  @override
  String get hubComingSoon => 'Soon';

  @override
  String get hubComingSoonMessage => 'This section is coming soon';

  @override
  String get aiChatBarPrompt => 'Ask the assistant about your car';

  @override
  String get aiChatTitle => 'Assistant';

  @override
  String get aiChatInputHint => 'Describe the problem...';

  @override
  String get aiChatSend => 'Send';

  @override
  String get aiChatGreeting => 'What happened to your car?';

  @override
  String get aiChatGreetingHint =>
      'Describe the problem in your own words — I will help work out the cause and find the part you need nearby.';

  @override
  String get aiChatExamplesLabel => 'For example';

  @override
  String get aiChatExampleKnock => 'Knocking at the front over bumps';

  @override
  String get aiChatExamplePads => 'I need brake pads';

  @override
  String get aiChatExampleOil => 'Which engine oil should I use?';

  @override
  String get aiChatDisclaimer =>
      'The assistant suggests likely causes and does not replace an inspection at a garage.';

  @override
  String get aiChatNotConnected =>
      'The assistant is not connected yet — only the interface is ready. Soon it will search the catalogue and answer your questions.';

  @override
  String get yearLabel => 'Year of manufacture';

  @override
  String get yearNotSpecified => 'Not specified';

  @override
  String get selectYear => 'Select a year';

  @override
  String get yearSkip => 'Leave the year unset';
}
