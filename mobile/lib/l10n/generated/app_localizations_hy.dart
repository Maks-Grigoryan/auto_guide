// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Armenian (`hy`).
class AppLocalizationsHy extends AppLocalizations {
  AppLocalizationsHy([String locale = 'hy']) : super(locale);

  @override
  String get appTitle => 'Ավտո Հայաստան';

  @override
  String get parts => 'Պահեստամասեր';

  @override
  String get repair => 'Վերանորոգում';

  @override
  String get selectCar => 'Ընտրել մեքենան';

  @override
  String get partsCategories => 'Պահեստամասերի կատեգորիաներ';

  @override
  String get partSearchHint => 'Արտիկուլ կամ OEM համար';

  @override
  String get locationFallback =>
      'Տեղադրությունը հասանելի չէ։ Որոնման կենտրոն է ընտրվել Երևանը։';

  @override
  String get locationSettingsHelp =>
      'Մոտակա արդյունքների համար թույլատրեք տեղադրության հասանելիությունը կարգավորումներում։';

  @override
  String get generationNotSpecified => 'Սերունդը նշված չէ';

  @override
  String get categoriesLoadError => 'Չհաջողվեց բեռնել կատեգորիաները';

  @override
  String get retry => 'Կրկին փորձել';

  @override
  String get selectMake => 'Ընտրեք մակնիշը';

  @override
  String get makeSearchHint => 'Որոնել մակնիշ...';

  @override
  String get makesLoadError => 'Չհաջողվեց բեռնել մակնիշները';

  @override
  String get makeNotFound => 'Մակնիշը չի գտնվել։ Ստուգեք գրությունը։';

  @override
  String get modelSearchHint => 'Որոնել մոդել...';

  @override
  String get modelsLoadError => 'Չհաջողվեց բեռնել մոդելները';

  @override
  String get modelNotFound => 'Մոդելը չի գտնվել։ Ստուգեք գրությունը։';

  @override
  String get generationsLoadError => 'Չհաջողվեց բեռնել սերունդները';

  @override
  String get skipGeneration => 'Բաց թողնել';

  @override
  String fromYear(int year) {
    return 'սկսած $year-ից';
  }

  @override
  String get yourCar => 'Ձեր մեքենան';

  @override
  String get make => 'Մակնիշ';

  @override
  String get model => 'Մոդել';

  @override
  String get generation => 'Սերունդ';

  @override
  String get confirmSelection => 'Հաստատել ընտրությունը';

  @override
  String get connectionHelp => 'Ստուգեք կապը և կրկին փորձեք';

  @override
  String get serviceCategories => 'Ծառայությունների կատեգորիաներ';

  @override
  String get serviceCategoriesLoadError =>
      'Չհաջողվեց բեռնել ծառայությունների կատեգորիաները';

  @override
  String get serviceCategoryOpenError => 'Չհաջողվեց բացել կատեգորիան';

  @override
  String get serviceCategoryNoLocation => 'Չհաջողվեց որոշել ձեր տեղադրությունը';

  @override
  String get results => 'Արդյունքներ';

  @override
  String searchResultsFor(String query) {
    return 'Որոնում՝ $query';
  }

  @override
  String get sortAndFilters => 'Դասավորում և զտիչներ';

  @override
  String get sort => 'Դասավորում';

  @override
  String get filters => 'Զտիչներ';

  @override
  String get sortDistance => 'Ըստ հեռավորության';

  @override
  String get sortPrice => 'Ըստ գնի';

  @override
  String get sortRating => 'Ըստ վարկանիշի';

  @override
  String radiusKm(int value) {
    return 'Շառավիղ՝ $value կմ';
  }

  @override
  String distanceMeters(int value) {
    return '$value մ';
  }

  @override
  String distanceKilometers(String value) {
    return '$value կմ';
  }

  @override
  String get availabilityOnly => 'Միայն առկա';

  @override
  String get priceAmd => 'Գին, AMD';

  @override
  String priceValueAmd(num value) {
    return '$value AMD';
  }

  @override
  String priceFromAmd(num value) {
    return 'սկսած $value AMD-ից';
  }

  @override
  String get reset => 'Վերակայել';

  @override
  String get list => 'Ցանկ';

  @override
  String get map => 'Քարտեզ';

  @override
  String get mapUnavailable => 'Քարտեզը հասանելի չէ';

  @override
  String get nothingNearby => 'Մոտակայքում ոչինչ չի գտնվել';

  @override
  String get nothingFound => 'Ոչինչ չի գտնվել';

  @override
  String get nothingFoundHelp =>
      'Մոտակայքում համապատասխան վաճառող չկա։ Փորձեք այլ կատեգորիա կամ զտիչներ։';

  @override
  String get backToCategories => 'Վերադառնալ կատեգորիաներին';

  @override
  String get resultsLoadError => 'Չհաջողվեց բեռնել արդյունքները';

  @override
  String get locationDisabled => 'Տեղադրությունն անջատված է';

  @override
  String get locationDisabledHelp =>
      'Մոտակա վաճառողներին գտնելու համար թույլատրեք տեղադրության հասանելիությունը։ Առայժմ ցուցադրվում են Երևանի կենտրոնի արդյունքները։';

  @override
  String get openSettings => 'Բացել կարգավորումները';

  @override
  String get partsShop => 'Պահեստամասերի խանութ';

  @override
  String get repairShop => 'Ավտոսպասարկում';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ապրանք',
      one: '$count ապրանք',
    );
    return '$_temp0';
  }

  @override
  String serviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ծառայություն',
      one: '$count ծառայություն',
    );
    return '$_temp0';
  }

  @override
  String get vendor => 'Վաճառող';

  @override
  String get verifiedVendor => 'Ստուգված վաճառող';

  @override
  String ratingOutOfFive(String rating) {
    return '$rating՝ 5-ից';
  }

  @override
  String get openingHours => 'Աշխատանքային ժամեր';

  @override
  String get weekdaysShort => 'Երկ–Ուրբ';

  @override
  String get saturdayShort => 'Շբթ';

  @override
  String get sundayShort => 'Կիր';

  @override
  String get call => 'Զանգահարել';

  @override
  String get route => 'Երթուղի';

  @override
  String get openAppError => 'Չհաջողվեց բացել հավելվածը';

  @override
  String get vendorLoadError => 'Չհաջողվեց բեռնել վաճառողին';

  @override
  String get language => 'Լեզու';

  @override
  String get russian => 'Русский';

  @override
  String get armenian => 'Հայերեն';

  @override
  String get english => 'English';

  @override
  String get noModelsForMake => 'Այս մակնխանիշի համար մոդելներ դեոշ չկան։';

  @override
  String get noMakesInCatalog => 'Մակնխանիշների ցանկն դատարկ է։';

  @override
  String get authTitle => 'Մուտք հավելված';

  @override
  String get authSubtitle => 'Պահեստամասեր և ավտոսերվիսներ ձեր մոտ';

  @override
  String get authSignInTab => 'Մուտք';

  @override
  String get authSignUpTab => 'Գրանցում';

  @override
  String get authIdentifierLabel => 'Հեռախոս կամ էլ. հասցե';

  @override
  String get authIdentifierInvalid => 'Սա նման չէ հեռախոսի կամ էլ. հասցեի';

  @override
  String get authPasswordLabel => 'Գաղտնաբառ';

  @override
  String get authPasswordRepeatLabel => 'Կրկնեք գաղտնաբառը';

  @override
  String get authSignInButton => 'Մուտք գործել';

  @override
  String get authSignUpButton => 'Գրանցվել';

  @override
  String get authIdentifierRequired => 'Մուտքագրեք հեռախոս կամ էլ. հասցե';

  @override
  String get authPasswordRequired => 'Մուտքագրեք գաղտնաբառը';

  @override
  String get authPasswordTooShort => 'Գաղտնաբառը պետք է լինի առնվազն 8 նիշ';

  @override
  String get authPasswordsDoNotMatch => 'Գաղտնաբառերը չեն համընկնում';

  @override
  String get authInvalidCredentials => 'Սխալ հեռախոս, էլ. հասցե կամ գաղտնաբառ';

  @override
  String get authAccountExists => 'Այդպիսի հաշիվ արդեն գոյություն ունի';

  @override
  String get authTooManyAttempts => 'Չափազանց շատ փորձեր։ Սպասեք մեկ րոպե';

  @override
  String get authNetworkError => 'Սերվերն անհասանելի է։ Ստուգեք կապը';

  @override
  String get authUnknownError => 'Չհաջողվեց մուտք գործել։ Փորձեք նորից';

  @override
  String authSignedInAs(String name) {
    return 'Դուք մուտք եք գործել որպես $name';
  }

  @override
  String get authAdminBadge => 'Ադմինիստրատոր';

  @override
  String get authSignOut => 'Դուրս գալ';

  @override
  String get authCodeTitle => 'Հաստատեք կոնտակտը';

  @override
  String authCodeSentTo(String target) {
    return 'Կոդն ուղարկվել է $target';
  }

  @override
  String get authCodeLabel => '6 նիշանոց կոդ';

  @override
  String get authConfirmButton => 'Հաստատել';

  @override
  String get authResendCode => 'Ուղարկել կոդը կրկին';

  @override
  String get authCodeResent => 'Կոդը կրկին ուղարկվեց';

  @override
  String get authChangeContact => 'Փոխել կոնտակտը';

  @override
  String get authCodeRequired => 'Մուտքագրեք 6 նիշանոց կոդը';

  @override
  String get authCodeInvalid => 'Սխալ կոդ';

  @override
  String get authCodeExpired => 'Կոդի ժամկետն անցել է։ Խնդրեք նորը';

  @override
  String get hubSectionsLabel => 'Բաժիններ';

  @override
  String get hubParts => 'Պահեստամասեր';

  @override
  String get hubPartsHint => 'Խանութներ ձեր մոտ';

  @override
  String get hubRepair => 'Վերանորոգում';

  @override
  String get hubRepairHint => 'Ավտոսերվիսներ ձեր մոտ';

  @override
  String get hubPartsRepair => 'Պահեստամասեր և վերանորոգում';

  @override
  String get hubPartsRepairHint => 'Խանութներ և ավտոսերվիսներ ձեր մոտ';

  @override
  String get hubRoadside => 'Ճանապարհային օգնություն';

  @override
  String get hubRoadsideHint => 'Էվակուատոր և օգնություն տեղում';

  @override
  String get hubComingSoon => 'Շուտով';

  @override
  String get hubComingSoonMessage => 'Բաժինը շուտով կհայտնվի';

  @override
  String get aiChatBarPrompt => 'Հարցրեք օգնականին ձեր մեքենայի մասին';

  @override
  String get aiChatTitle => 'Օգնական';

  @override
  String get aiChatInputHint => 'Նկարագրեք խնդիրը...';

  @override
  String get aiChatSend => 'Ուղարկել';

  @override
  String get aiChatGreeting => 'Ի՞նչ է պատահել մեքենային';

  @override
  String get aiChatGreetingHint =>
      'Նկարագրեք խնդիրը ձեր բառերով — կօգնեմ հասկանալ պատճառը և գտնել անհրաժեշտ պահեստամասը ձեր մոտ։';

  @override
  String get aiChatExamplesLabel => 'Օրինակ';

  @override
  String get aiChatExampleKnock => 'Առջևից թխկթխկոց է լսվում փոսերին';

  @override
  String get aiChatExamplePads => 'Անհրաժեշտ են արգելակային կոճղակներ';

  @override
  String get aiChatExampleOil => 'Ի՞նչ յուղ լցնել';

  @override
  String get aiChatDisclaimer =>
      'Օգնականը նշում է հավանական պատճառները և չի փոխարինում սերվիսի զննմանը։';

  @override
  String get aiChatNotConnected =>
      'Օգնականը դեռ միացված չէ — պատրաստ է միայն ինտերֆեյսը։ Շուտով նա կկարողանա որոնել պահեստամասեր կատալոգում և պատասխանել հարցերին։';

  @override
  String get yearLabel => 'Թողարկման տարի';

  @override
  String get yearNotSpecified => 'Նշված չէ';

  @override
  String get selectYear => 'Ընտրեք տարին';

  @override
  String get yearSkip => 'Չնշել տարին';
}
