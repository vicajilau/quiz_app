// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get titleAppBar => 'क्विज़ - परीक्षा सिमुलेटर';

  @override
  String get create => 'बनाएं';

  @override
  String get load => 'लोड करें';

  @override
  String fileLoaded(String filePath) {
    return 'फ़ाइल लोड हुई: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'फ़ाइल सेव हुई: $filePath';
  }

  @override
  String get dropFileHere =>
      'यहाँ क्लिक करें या स्क्रीन पर .quiz फ़ाइल ड्रैग करें';

  @override
  String get errorInvalidFile =>
      'त्रुटि: अमान्य फ़ाइल। .quiz फ़ाइल होनी चाहिए।';

  @override
  String errorLoadingFile(String error) {
    return 'क्विज़ फ़ाइल लोड करने में त्रुटि: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'फ़ाइल एक्सपोर्ट करने में त्रुटि: $error';
  }

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String get saveButton => 'सेव करें';

  @override
  String get confirmDeleteTitle => 'हटाने की पुष्टि करें';

  @override
  String confirmDeleteMessage(String processName) {
    return 'क्या आप वाकई `$processName` प्रक्रिया को हटाना चाहते हैं?';
  }

  @override
  String get deleteButton => 'हटाएं';

  @override
  String get confirmExitTitle => 'बाहर निकलने की पुष्टि करें';

  @override
  String get confirmExitMessage =>
      'क्या आप वाकई बिना सेव किए बाहर निकलना चाहते हैं?';

  @override
  String get exitButton => 'बाहर निकलें';

  @override
  String get saveDialogTitle => 'कृपया आउटपुट फ़ाइल चुनें:';

  @override
  String get createQuizFileTitle => 'क्विज़ फ़ाइल बनाएं';

  @override
  String get fileNameLabel => 'फ़ाइल का नाम';

  @override
  String get fileDescriptionLabel => 'फ़ाइल का विवरण';

  @override
  String get createButton => 'बनाएं';

  @override
  String get fileNameRequiredError => 'फ़ाइल का नाम आवश्यक है।';

  @override
  String get fileDescriptionRequiredError => 'फ़ाइल का विवरण आवश्यक है।';

  @override
  String get versionLabel => 'संस्करण';

  @override
  String get authorLabel => 'लेखक';

  @override
  String get authorRequiredError => 'लेखक का नाम आवश्यक है।';

  @override
  String get requiredFieldsError => 'सभी आवश्यक फ़ील्ड भरे जाने चाहिए।';

  @override
  String get requestFileNameTitle => 'क्विज़ फ़ाइल का नाम दर्ज करें';

  @override
  String get fileNameHint => 'फ़ाइल का नाम';

  @override
  String get emptyFileNameMessage => 'फ़ाइल का नाम खाली नहीं हो सकता।';

  @override
  String get acceptButton => 'स्वीकार करें';

  @override
  String get saveTooltip => 'फ़ाइल सेव करें';

  @override
  String get saveDisabledTooltip => 'सेव करने के लिए कोई बदलाव नहीं';

  @override
  String get executeTooltip => 'परीक्षा शुरू करें';

  @override
  String get addTooltip => 'नया प्रश्न जोड़ें';

  @override
  String get backSemanticLabel => 'वापस जाएं बटन';

  @override
  String get createFileTooltip => 'नई क्विज़ फ़ाइल बनाएं';

  @override
  String get loadFileTooltip => 'मौजूदा क्विज़ फ़ाइल लोड करें';

  @override
  String questionNumber(int number) {
    return 'प्रश्न $number';
  }

  @override
  String get previous => 'पिछला';

  @override
  String get next => 'अगला';

  @override
  String get finish => 'समाप्त करें';

  @override
  String get finishQuiz => 'क्विज़ समाप्त करें';

  @override
  String get finishQuizConfirmation =>
      'क्या आप वाकई क्विज़ समाप्त करना चाहते हैं? इसके बाद आप अपने उत्तर नहीं बदल सकेंगे।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get abandonQuiz => 'क्विज़ छोड़ें';

  @override
  String get abandonQuizConfirmation =>
      'क्या आप वाकई क्विज़ छोड़ना चाहते हैं? सभी प्रगति खो जाएगी।';

  @override
  String get abandon => 'छोड़ें';

  @override
  String get quizCompleted => 'क्विज़ पूरी हुई!';

  @override
  String score(String score) {
    return 'स्कोर: $score%';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$total में से $correct सही उत्तर';
  }

  @override
  String get retry => 'दोहराएं';

  @override
  String get goBack => 'समाप्त करें';

  @override
  String get retryFailedQuestions => 'गलत प्रश्न दोहराएं';

  @override
  String question(String question) {
    return 'प्रश्न: $question';
  }

  @override
  String get selectQuestionCountTitle => 'प्रश्नों की संख्या चुनें';

  @override
  String get selectQuestionCountMessage =>
      'इस क्विज़ में आप कितने प्रश्नों का उत्तर देना चाहते हैं?';

  @override
  String allQuestions(int count) {
    return 'सभी प्रश्न ($count)';
  }

  @override
  String get startQuiz => 'क्विज़ शुरू करें';

  @override
  String get customNumberLabel => 'या कस्टम संख्या दर्ज करें:';

  @override
  String get numberInputLabel => 'प्रश्नों की संख्या';

  @override
  String customNumberHelper(int total) {
    return 'कोई भी संख्या दर्ज करें (अधिकतम $total)। यदि अधिक है, तो प्रश्न दोहराए जाएंगे।';
  }

  @override
  String get errorInvalidNumber => 'कृपया वैध संख्या दर्ज करें';

  @override
  String get errorNumberMustBePositive => 'संख्या 0 से अधिक होनी चाहिए';

  @override
  String get questionOrderConfigTitle => 'प्रश्न क्रम कॉन्फ़िगरेशन';

  @override
  String get questionOrderConfigDescription =>
      'परीक्षा के दौरान प्रश्न किस क्रम में दिखाए जाएं, यह चुनें:';

  @override
  String get questionOrderAscending => 'आरोही क्रम';

  @override
  String get questionOrderAscendingDesc =>
      'प्रश्न 1 से अंत तक क्रम में दिखेंगे';

  @override
  String get questionOrderDescending => 'अवरोही क्रम';

  @override
  String get questionOrderDescendingDesc => 'प्रश्न अंत से 1 तक दिखेंगे';

  @override
  String get questionOrderRandom => 'यादृच्छिक';

  @override
  String get questionOrderRandomDesc => 'प्रश्न यादृच्छिक क्रम में दिखेंगे';

  @override
  String get questionOrderConfigTooltip => 'प्रश्न क्रम कॉन्फ़िगरेशन';

  @override
  String get save => 'सेव करें';

  @override
  String get examTimeLimitTitle => 'परीक्षा समय सीमा';

  @override
  String get examTimeLimitDescription =>
      'परीक्षा के लिए समय सीमा निर्धारित करें। सक्षम होने पर, क्विज़ के दौरान काउंटडाउन टाइमर दिखेगा।';

  @override
  String get enableTimeLimit => 'समय सीमा सक्षम करें';

  @override
  String get timeLimitMinutes => 'समय सीमा (मिनट)';

  @override
  String get examTimeExpiredTitle => 'समय समाप्त!';

  @override
  String get examTimeExpiredMessage =>
      'परीक्षा का समय समाप्त हो गया है। आपके उत्तर स्वचालित रूप से जमा कर दिए गए हैं।';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => 'बहुविकल्पीय';

  @override
  String get questionTypeSingleChoice => 'एकल विकल्प';

  @override
  String get questionTypeTrueFalse => 'सही/गलत';

  @override
  String get questionTypeEssay => 'निबंध';

  @override
  String get questionTypeUnknown => 'अज्ञात';

  @override
  String optionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count विकल्प',
      one: '1 विकल्प',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip => 'इस प्रश्न के लिए उत्तर विकल्पों की संख्या';

  @override
  String get imageTooltip => 'इस प्रश्न के साथ चित्र जुड़ा है';

  @override
  String get explanationTooltip => 'इस प्रश्न का स्पष्टीकरण है';

  @override
  String get aiPrompt =>
      'आप एक विशेषज्ञ और मित्रवत शिक्षक हैं जो छात्रों को परीक्षा प्रश्नों और संबंधित विषयों को बेहतर समझने में मदद करने में विशेषज्ञ हैं। आपका लक्ष्य गहन अधिगम और वैचारिक समझ को सुविधाजनक बनाना है।\n\nआप इसमें मदद कर सकते हैं:\n- प्रश्न से संबंधित अवधारणाओं को समझाना\n- उत्तर विकल्पों के बारे में संदेह स्पष्ट करना\n- विषय के बारे में अतिरिक्त संदर्भ प्रदान करना\n- पूरक अध्ययन संसाधन सुझाना\n- समझाना कि कुछ उत्तर सही या गलत क्यों हैं\n- विषय को अन्य महत्वपूर्ण अवधारणाओं से जोड़ना\n- सामग्री के बारे में अनुवर्ती प्रश्नों का उत्तर देना\n\nहमेशा उसी भाषा में जवाब दें जिसमें आपसे पूछा गया है। अपने स्पष्टीकरण में शैक्षणिक, स्पष्ट और प्रेरणादायक बनें।';

  @override
  String get questionLabel => 'प्रश्न';

  @override
  String get optionsLabel => 'विकल्प';

  @override
  String get explanationLabel => 'स्पष्टीकरण (वैकल्पिक)';

  @override
  String get studentComment => 'छात्र की टिप्पणी';

  @override
  String get aiAssistantTitle => 'AI अध्ययन सहायक';

  @override
  String get questionContext => 'प्रश्न संदर्भ';

  @override
  String get aiAssistant => 'AI सहायक';

  @override
  String get aiThinking => 'AI सोच रहा है...';

  @override
  String get askAIHint => 'इस विषय के बारे में अपना प्रश्न पूछें...';

  @override
  String get aiPlaceholderResponse =>
      'यह एक प्लेसहोल्डर प्रतिक्रिया है। वास्तविक कार्यान्वयन में, यह प्रश्न के बारे में सहायक स्पष्टीकरण प्रदान करने के लिए AI सेवा से जुड़ेगा।';

  @override
  String get aiErrorResponse =>
      'क्षमा करें, आपके प्रश्न को प्रोसेस करने में त्रुटि हुई। कृपया पुनः प्रयास करें।';

  @override
  String get configureApiKeyMessage =>
      'कृपया सेटिंग्स में अपनी AI API Key कॉन्फ़िगर करें।';

  @override
  String get errorLabel => 'त्रुटि:';

  @override
  String get noResponseReceived => 'कोई प्रतिक्रिया प्राप्त नहीं हुई';

  @override
  String get invalidApiKeyError =>
      'अमान्य API Key। कृपया सेटिंग्स में अपनी OpenAI API Key जांचें।';

  @override
  String get rateLimitError =>
      'दर सीमा पार हो गई। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get modelNotFoundError =>
      'मॉडल नहीं मिला। कृपया अपनी API पहुंच जांचें।';

  @override
  String get unknownError => 'अज्ञात त्रुटि';

  @override
  String get networkError =>
      'नेटवर्क त्रुटि: OpenAI से कनेक्ट नहीं हो सका। कृपया अपना इंटरनेट कनेक्शन जांचें।';

  @override
  String get openaiApiKeyNotConfigured => 'OpenAI API Key कॉन्फ़िगर नहीं की गई';

  @override
  String get geminiApiKeyNotConfigured => 'Gemini API Key कॉन्फ़िगर नहीं की गई';

  @override
  String get geminiApiKeyLabel => 'Google Gemini API Key';

  @override
  String get geminiApiKeyHint => 'अपनी Gemini API Key दर्ज करें';

  @override
  String get geminiApiKeyDescription =>
      'Gemini AI कार्यक्षमता के लिए आवश्यक। आपकी key सुरक्षित रूप से संग्रहीत की जाती है।';

  @override
  String get getGeminiApiKeyTooltip =>
      'Google AI Studio से API Key प्राप्त करें';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'AI अध्ययन सहायक के लिए कम से कम एक API Key (OpenAI या Gemini) की आवश्यकता है। कृपया API key दर्ज करें या AI सहायक को अक्षम करें।';

  @override
  String get minutesAbbreviation => 'मिन';

  @override
  String get aiButtonTooltip => 'AI अध्ययन सहायक';

  @override
  String get aiButtonText => 'AI';

  @override
  String get aiAssistantSettingsTitle => 'AI अध्ययन सहायक (पूर्वावलोकन)';

  @override
  String get aiAssistantSettingsDescription =>
      'प्रश्नों के लिए AI अध्ययन सहायक को सक्षम या अक्षम करें';

  @override
  String get openaiApiKeyLabel => 'OpenAI API Key';

  @override
  String get openaiApiKeyHint => 'अपनी OpenAI API Key दर्ज करें (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'AI कार्यक्षमता के लिए आवश्यक। आपकी key सुरक्षित रूप से संग्रहीत की जाती है।';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'AI अध्ययन सहायक के लिए OpenAI API Key की आवश्यकता है। कृपया अपनी API key दर्ज करें या AI सहायक को अक्षम करें।';

  @override
  String get getApiKeyTooltip => 'OpenAI से API Key प्राप्त करें';

  @override
  String get deleteAction => 'हटाएं';

  @override
  String get explanationHint => 'सही उत्तर(रों) के लिए स्पष्टीकरण दर्ज करें';

  @override
  String get explanationTitle => 'स्पष्टीकरण';

  @override
  String get imageLabel => 'चित्र';

  @override
  String get changeImage => 'चित्र बदलें';

  @override
  String get removeImage => 'चित्र हटाएं';

  @override
  String get addImageTap => 'चित्र जोड़ने के लिए टैप करें';

  @override
  String get imageFormats => 'प्रारूप: JPG, PNG, GIF';

  @override
  String get imageLoadError => 'चित्र लोड करने में त्रुटि';

  @override
  String imagePickError(String error) {
    return 'चित्र लोड करने में त्रुटि: $error';
  }

  @override
  String get tapToZoom => 'ज़ूम करने के लिए टैप करें';

  @override
  String get trueLabel => 'सही';

  @override
  String get falseLabel => 'गलत';

  @override
  String get addQuestion => 'प्रश्न जोड़ें';

  @override
  String get editQuestion => 'प्रश्न संपादित करें';

  @override
  String get questionText => 'प्रश्न पाठ';

  @override
  String get questionType => 'प्रश्न प्रकार';

  @override
  String get addOption => 'विकल्प जोड़ें';

  @override
  String get optionLabel => 'विकल्प';

  @override
  String get questionTextRequired => 'प्रश्न पाठ आवश्यक है';

  @override
  String get atLeastOneOptionRequired =>
      'कम से कम एक विकल्प में पाठ होना चाहिए';

  @override
  String get atLeastOneCorrectAnswerRequired =>
      'कम से कम एक सही उत्तर चुना जाना चाहिए';

  @override
  String get onlyOneCorrectAnswerAllowed =>
      'इस प्रश्न प्रकार के लिए केवल एक सही उत्तर की अनुमति है';

  @override
  String get removeOption => 'विकल्प हटाएं';

  @override
  String get selectCorrectAnswer => 'सही उत्तर चुनें';

  @override
  String get selectCorrectAnswers => 'सही उत्तर चुनें';

  @override
  String emptyOptionsError(String optionNumbers) {
    return 'विकल्प $optionNumbers खाली हैं। कृपया उनमें पाठ जोड़ें या उन्हें हटा दें।';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return 'विकल्प $optionNumber खाली है। कृपया इसमें पाठ जोड़ें या इसे हटा दें।';
  }

  @override
  String get optionEmptyError => 'यह विकल्प खाली नहीं हो सकता';

  @override
  String get hasImage => 'चित्र';

  @override
  String get hasExplanation => 'स्पष्टीकरण';

  @override
  String errorLoadingSettings(String error) {
    return 'सेटिंग्स लोड करने में त्रुटि: $error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return '$url खोला नहीं जा सका';
  }

  @override
  String get loadingAiServices => 'AI सेवाएं लोड हो रही हैं...';

  @override
  String usingAiService(String serviceName) {
    return 'उपयोग में: $serviceName';
  }

  @override
  String get aiServiceLabel => 'AI सेवा:';

  @override
  String get importQuestionsTitle => 'प्रश्न आयात करें';

  @override
  String importQuestionsMessage(int count, String fileName) {
    return '\"$fileName\" में $count प्रश्न मिले। आप इन्हें कहाँ आयात करना चाहते हैं?';
  }

  @override
  String get importQuestionsPositionQuestion =>
      'आप इन प्रश्नों को कहाँ जोड़ना चाहते हैं?';

  @override
  String get importAtBeginning => 'शुरुआत में';

  @override
  String get importAtEnd => 'अंत में';

  @override
  String questionsImportedSuccess(int count) {
    return 'सफलतापूर्वक $count प्रश्न आयात किए गए';
  }

  @override
  String get importQuestionsTooltip => 'दूसरी क्विज़ फ़ाइल से प्रश्न आयात करें';

  @override
  String get dragDropHintText =>
      'प्रश्न आयात करने के लिए आप .quiz फ़ाइलों को यहाँ ड्रैग और ड्रॉप भी कर सकते हैं';

  @override
  String get randomizeAnswersTitle => 'उत्तर विकल्पों को मिलाएं';

  @override
  String get randomizeAnswersDescription =>
      'क्विज़ निष्पादन के दौरान उत्तर विकल्पों का क्रम मिलाएं';

  @override
  String get showCorrectAnswerCountTitle => 'सही उत्तर संख्या दिखाएं';

  @override
  String get showCorrectAnswerCountDescription =>
      'बहुविकल्पीय प्रश्नों में सही उत्तरों की संख्या प्रदर्शित करें';

  @override
  String correctAnswersCount(int count) {
    return '$count सही उत्तर चुनें';
  }

  @override
  String get correctSelectedLabel => 'सही';

  @override
  String get correctMissedLabel => 'सही';

  @override
  String get incorrectSelectedLabel => 'गलत';

  @override
  String get generateQuestionsWithAI => 'AI के साथ प्रश्न बनाएं';

  @override
  String get aiGenerateDialogTitle => 'AI के साथ प्रश्न बनाएं';

  @override
  String get aiQuestionCountLabel => 'प्रश्नों की संख्या (वैकल्पिक)';

  @override
  String get aiQuestionCountHint => 'AI को निर्णय लेने के लिए खाली छोड़ें';

  @override
  String get aiQuestionCountValidation => '1 से 50 के बीच संख्या होनी चाहिए';

  @override
  String get aiQuestionTypeLabel => 'प्रश्न प्रकार';

  @override
  String get aiQuestionTypeRandom => 'यादृच्छिक (मिश्रित)';

  @override
  String get aiLanguageLabel => 'प्रश्न भाषा';

  @override
  String get aiContentLabel => 'प्रश्न बनाने के लिए सामग्री';

  @override
  String aiWordCount(int current, int max) {
    return '$current / $max शब्द';
  }

  @override
  String get aiContentHint =>
      'वह पाठ, विषय या सामग्री दर्ज करें जिससे आप प्रश्न बनाना चाहते हैं...';

  @override
  String get aiContentHelperText => 'AI इस सामग्री के आधार पर प्रश्न बनाएगा';

  @override
  String aiWordLimitError(int max) {
    return 'आपने $max शब्दों की सीमा पार कर दी है';
  }

  @override
  String get aiContentRequiredError =>
      'प्रश्न बनाने के लिए आपको सामग्री प्रदान करनी होगी';

  @override
  String aiContentLimitError(int max) {
    return 'सामग्री $max शब्दों की सीमा से अधिक है';
  }

  @override
  String get aiMinWordsError =>
      'गुणवत्तापूर्ण प्रश्न बनाने के लिए कम से कम 10 शब्द प्रदान करें';

  @override
  String get aiInfoTitle => 'जानकारी';

  @override
  String get aiInfoDescription =>
      '• AI सामग्री का विश्लेषण करके प्रासंगिक प्रश्न बनाएगा\n• आप पाठ, परिभाषाएं, स्पष्टीकरण या कोई भी शैक्षिक सामग्री शामिल कर सकते हैं\n• प्रश्नों में उत्तर विकल्प और स्पष्टीकरण शामिल होंगे\n• इस प्रक्रिया में कुछ सेकंड लग सकते हैं';

  @override
  String get aiGenerateButton => 'प्रश्न बनाएं';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageCatalan => 'Català';

  @override
  String get languageBasque => 'Euskera';

  @override
  String get languageGalician => 'Galego';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageChinese => '中文';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageJapanese => '日本語';

  @override
  String get aiServicesLoading => 'AI सेवाएं लोड हो रही हैं...';

  @override
  String get aiServicesNotConfigured => 'कोई AI सेवा कॉन्फ़िगर नहीं की गई';

  @override
  String get aiGeneratedQuestions => 'AI द्वारा बनाए गए';

  @override
  String get aiApiKeyRequired =>
      'AI जेनरेशन का उपयोग करने के लिए कृपया सेटिंग्स में कम से कम एक AI API key कॉन्फ़िगर करें।';

  @override
  String get aiGenerationFailed =>
      'प्रश्न नहीं बना सके। अलग सामग्री के साथ प्रयास करें।';

  @override
  String aiGenerationError(String error) {
    return 'प्रश्न बनाने में त्रुटि: $error';
  }

  @override
  String get noQuestionsInFile => 'आयातित फ़ाइल में कोई प्रश्न नहीं मिले';

  @override
  String get couldNotAccessFile => 'चयनित फ़ाइल तक पहुंच नहीं सकी';

  @override
  String get defaultOutputFileName => 'output-file.quiz';

  @override
  String aiServiceLimitsWithChars(int words, int chars) {
    return 'सीमा: $words शब्द या $chars अक्षर';
  }

  @override
  String aiServiceLimitsWordsOnly(int words) {
    return 'सीमा: $words शब्द';
  }
}
