// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get titleAppBar => 'اختبار - محاكي الامتحان';

  @override
  String get create => 'إنشاء';

  @override
  String get preview => 'معاينة';

  @override
  String get load => 'تحميل';

  @override
  String fileLoaded(String filePath) {
    return 'تم تحميل الملف: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'تم حفظ الملف: $filePath';
  }

  @override
  String get dropFileHere => 'انقر هنا أو اسحب ملف .quiz إلى الشاشة';

  @override
  String get errorInvalidFile => 'خطأ: ملف غير صالح. يجب أن يكون ملف .quiz.';

  @override
  String errorLoadingFile(String error) {
    return 'خطأ في تحميل ملف الاختبار: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'خطأ في تصدير الملف: $error';
  }

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get saveButton => 'حفظ';

  @override
  String get confirmDeleteTitle => 'تأكيد الحذف';

  @override
  String confirmDeleteMessage(String processName) {
    return 'هل أنت متأكد من أنك تريد حذف العملية `$processName`؟';
  }

  @override
  String get deleteButton => 'حذف';

  @override
  String get confirmExitTitle => 'تأكيد الخروج';

  @override
  String get confirmExitMessage => 'هل أنت متأكد من أنك تريد الخروج بدون حفظ؟';

  @override
  String get exitButton => 'خروج';

  @override
  String get saveDialogTitle => 'يرجى اختيار ملف الإخراج:';

  @override
  String get createQuizFileTitle => 'إنشاء ملف اختبار';

  @override
  String get fileNameLabel => 'اسم الملف';

  @override
  String get fileDescriptionLabel => 'وصف الملف';

  @override
  String get createButton => 'إنشاء';

  @override
  String get fileNameRequiredError => 'اسم الملف مطلوب.';

  @override
  String get fileDescriptionRequiredError => 'وصف الملف مطلوب.';

  @override
  String get versionLabel => 'الإصدار';

  @override
  String get authorLabel => 'المؤلف';

  @override
  String get authorRequiredError => 'المؤلف مطلوب.';

  @override
  String get requiredFieldsError => 'يجب ملء جميع الحقول المطلوبة.';

  @override
  String get requestFileNameTitle => 'أدخل اسم ملف الاختبار';

  @override
  String get fileNameHint => 'اسم الملف';

  @override
  String get emptyFileNameMessage => 'اسم الملف لا يمكن أن يكون فارغاً.';

  @override
  String get acceptButton => 'قبول';

  @override
  String get saveTooltip => 'حفظ الملف';

  @override
  String get saveDisabledTooltip => 'لا توجد تغييرات للحفظ';

  @override
  String get executeTooltip => 'تنفيذ الامتحان';

  @override
  String get addTooltip => 'إضافة سؤال جديد';

  @override
  String get backSemanticLabel => 'زر الرجوع';

  @override
  String get createFileTooltip => 'إنشاء ملف اختبار جديد';

  @override
  String get loadFileTooltip => 'تحميل ملف اختبار موجود';

  @override
  String questionNumber(int number) {
    return 'السؤال $number';
  }

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get finish => 'إنهاء';

  @override
  String get finishQuiz => 'إنهاء الاختبار';

  @override
  String get finishQuizConfirmation =>
      'هل أنت متأكد من أنك تريد إنهاء الاختبار؟ لن تتمكن من تغيير إجاباتك بعد ذلك.';

  @override
  String get abandonQuiz => 'التخلي عن الاختبار';

  @override
  String get abandonQuizConfirmation =>
      'هل أنت متأكد من أنك تريد التخلي عن الاختبار؟ سيتم فقدان جميع التقدم.';

  @override
  String get abandon => 'التخلي';

  @override
  String get quizCompleted => 'تم إكمال الاختبار!';

  @override
  String score(String score) {
    return 'النتيجة: $score%';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$correct من $total إجابات صحيحة';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get goBack => 'إنهاء';

  @override
  String get retryFailedQuestions => 'إعادة الأسئلة الخاطئة';

  @override
  String question(String question) {
    return 'السؤال: $question';
  }

  @override
  String get selectQuestionCountTitle => 'اختر عدد الأسئلة';

  @override
  String get selectQuestionCountMessage =>
      'كم عدد الأسئلة التي تريد الإجابة عليها في هذا الاختبار؟';

  @override
  String allQuestions(int count) {
    return 'جميع الأسئلة ($count)';
  }

  @override
  String get startQuiz => 'بدء الاختبار';

  @override
  String get errorInvalidNumber => 'يرجى إدخال رقم صالح';

  @override
  String get errorNumberMustBePositive => 'يجب أن يكون الرقم أكبر من 0';

  @override
  String get customNumberLabel => 'أو أدخل رقماً مخصصاً:';

  @override
  String customNumberHelper(int total) {
    return 'أدخل أي رقم (بحد أقصى $total). إذا كان أكبر، ستتكرر الأسئلة.';
  }

  @override
  String get numberInputLabel => 'عدد الأسئلة';

  @override
  String get questionOrderConfigTitle => 'إعداد ترتيب الأسئلة';

  @override
  String get questionOrderConfigDescription =>
      'اختر الترتيب الذي تريد أن تظهر به الأسئلة أثناء الامتحان:';

  @override
  String get questionOrderAscending => 'الترتيب التصاعدي';

  @override
  String get questionOrderAscendingDesc =>
      'ستظهر الأسئلة بترتيب من 1 إلى النهاية';

  @override
  String get questionOrderDescending => 'الترتيب التنازلي';

  @override
  String get questionOrderDescendingDesc => 'ستظهر الأسئلة من النهاية إلى 1';

  @override
  String get questionOrderRandom => 'عشوائي';

  @override
  String get questionOrderRandomDesc => 'ستظهر الأسئلة بترتيب عشوائي';

  @override
  String get questionOrderConfigTooltip => 'إعداد ترتيب الأسئلة';

  @override
  String get save => 'حفظ';

  @override
  String get examTimeLimitTitle => 'حد وقت الامتحان';

  @override
  String get examTimeLimitDescription =>
      'تعيين حد زمني للامتحان. عند التفعيل، سيتم عرض عداد تنازلي أثناء الاختبار.';

  @override
  String get enableTimeLimit => 'تفعيل الحد الزمني';

  @override
  String get timeLimitMinutes => 'الحد الزمني (دقائق)';

  @override
  String get examTimeExpiredTitle => 'انتهى الوقت!';

  @override
  String get examTimeExpiredMessage =>
      'انتهى وقت الامتحان. تم تقديم إجاباتك تلقائياً.';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => 'اختيار متعدد';

  @override
  String get questionTypeSingleChoice => 'اختيار واحد';

  @override
  String get questionTypeTrueFalse => 'صح/خطأ';

  @override
  String get questionTypeEssay => 'مقالي';

  @override
  String get questionTypeUnknown => 'غير معروف';

  @override
  String optionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خيارات',
      one: 'خيار واحد',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip => 'عدد خيارات الإجابة لهذا السؤال';

  @override
  String get imageTooltip => 'هذا السؤال له صورة مرتبطة';

  @override
  String get explanationTooltip => 'هذا السؤال له شرح';

  @override
  String get aiPrompt =>
      'أنت مدرس خبير وودود متخصص في مساعدة الطلاب على فهم أسئلة الامتحانات والمواضيع ذات الصلة بشكل أفضل. هدفك هو تسهيل التعلم العميق والفهم المفاهيمي.\n\nيمكنك المساعدة في:\n- شرح المفاهيم المتعلقة بالسؤال\n- توضيح الشكوك حول خيارات الإجابة\n- تقديم سياق إضافي حول الموضوع\n- اقتراح موارد دراسة تكميلية\n- شرح لماذا إجابات معينة صحيحة أو خاطئة\n- ربط الموضوع بمفاهيم مهمة أخرى\n- الإجابة على أسئلة متابعة حول المادة\n\nاستجب دائماً بنفس اللغة التي يُطرح بها السؤال. كن تعليمياً وواضحاً ومحفزاً في شروحاتك.';

  @override
  String get questionLabel => 'السؤال';

  @override
  String get studentComment => 'تعليق الطالب';

  @override
  String get aiAssistantTitle => 'مساعد الدراسة الذكي';

  @override
  String get questionContext => 'سياق السؤال';

  @override
  String get aiAssistant => 'المساعد الذكي';

  @override
  String get aiThinking => 'الذكاء الاصطناعي يفكر...';

  @override
  String get askAIHint => 'اطرح سؤالك حول هذا الموضوع...';

  @override
  String get aiPlaceholderResponse =>
      'هذه استجابة مؤقتة. في التطبيق الحقيقي، سيتصل هذا بخدمة الذكاء الاصطناعي لتقديم شروحات مفيدة حول السؤال.';

  @override
  String get aiErrorResponse =>
      'عذراً، حدث خطأ في معالجة سؤالك. يرجى المحاولة مرة أخرى.';

  @override
  String get configureApiKeyMessage =>
      'يرجى تكوين مفتاح API للذكاء الاصطناعي في الإعدادات.';

  @override
  String get errorLabel => 'خطأ:';

  @override
  String get noResponseReceived => 'لم يتم استلام رد';

  @override
  String get invalidApiKeyError =>
      'مفتاح API غير صالح. يرجى التحقق من مفتاح OpenAI API في الإعدادات.';

  @override
  String get rateLimitError =>
      'تم تجاوز حد المعدل. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get modelNotFoundError =>
      'النموذج غير موجود. يرجى التحقق من إمكانية الوصول إلى API.';

  @override
  String get unknownError => 'خطأ غير معروف';

  @override
  String get networkError =>
      'خطأ في الشبكة: غير قادر على الاتصال بـ OpenAI. يرجى التحقق من اتصال الإنترنت.';

  @override
  String get openaiApiKeyNotConfigured => 'مفتاح OpenAI API غير مُكوَّن';

  @override
  String get geminiApiKeyNotConfigured => 'مفتاح Gemini API غير مُكوَّن';

  @override
  String get geminiApiKeyLabel => 'مفتاح Gemini API';

  @override
  String get geminiApiKeyHint => 'أدخل مفتاح Gemini API الخاص بك';

  @override
  String get geminiApiKeyDescription =>
      'مطلوب لوظائف Gemini AI. يتم تخزين مفتاحك بأمان.';

  @override
  String get getGeminiApiKeyTooltip => 'احصل على مفتاح API من Google AI Studio';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'مساعد الدراسة الذكي يتطلب مفتاح API واحد على الأقل (OpenAI أو Gemini). يرجى إدخال مفتاح API أو تعطيل المساعد الذكي.';

  @override
  String get minutesAbbreviation => 'د';

  @override
  String get aiButtonTooltip => 'مساعد الدراسة الذكي';

  @override
  String get aiButtonText => 'AI';

  @override
  String get aiAssistantSettingsTitle => 'مساعد الدراسة الذكي (معاينة)';

  @override
  String get aiAssistantSettingsDescription =>
      'تفعيل أو تعطيل مساعد الدراسة الذكي للأسئلة';

  @override
  String get aiDefaultModelTitle => 'نموذج الذكاء الاصطناعي الافتراضي';

  @override
  String get aiDefaultModelDescription =>
      'حدد خدمة ونموذج الذكاء الاصطناعي الافتراضي لتوليد الأسئلة';

  @override
  String get openaiApiKeyLabel => 'مفتاح OpenAI API';

  @override
  String get openaiApiKeyHint => 'أدخل مفتاح OpenAI API الخاص بك (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'مطلوب للتكامل مع OpenAI. يتم تخزين مفتاح OpenAI الخاص بك بأمان.';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'مساعد الدراسة الذكي يتطلب مفتاح OpenAI API. يرجى إدخال مفتاح API أو تعطيل المساعد الذكي.';

  @override
  String get getApiKeyTooltip => 'احصل على مفتاح API من OpenAI';

  @override
  String get deleteAction => 'حذف';

  @override
  String get explanationLabel => 'الشرح (اختياري)';

  @override
  String get explanationHint => 'أدخل شرحاً للإجابة/الإجابات الصحيحة';

  @override
  String get explanationTitle => 'الشرح';

  @override
  String get imageLabel => 'الصورة';

  @override
  String get changeImage => 'تغيير الصورة';

  @override
  String get removeImage => 'إزالة الصورة';

  @override
  String get addImageTap => 'انقر لإضافة صورة';

  @override
  String get imageFormats => 'التنسيقات: JPG، PNG، GIF';

  @override
  String get imageLoadError => 'خطأ في تحميل الصورة';

  @override
  String imagePickError(String error) {
    return 'خطأ في تحميل الصورة: $error';
  }

  @override
  String get tapToZoom => 'انقر للتكبير';

  @override
  String get trueLabel => 'صحيح';

  @override
  String get falseLabel => 'خطأ';

  @override
  String get addQuestion => 'إضافة سؤال';

  @override
  String get editQuestion => 'تحرير السؤال';

  @override
  String get questionText => 'نص السؤال';

  @override
  String get questionType => 'نوع السؤال';

  @override
  String get addOption => 'إضافة خيار';

  @override
  String get optionsLabel => 'الخيارات';

  @override
  String get optionLabel => 'الخيار';

  @override
  String get questionTextRequired => 'نص السؤال مطلوب';

  @override
  String get atLeastOneOptionRequired =>
      'يجب أن يحتوي خيار واحد على الأقل على نص';

  @override
  String get atLeastOneCorrectAnswerRequired =>
      'يجب اختيار إجابة صحيحة واحدة على الأقل';

  @override
  String get onlyOneCorrectAnswerAllowed =>
      'إجابة صحيحة واحدة فقط مسموحة لهذا النوع من الأسئلة';

  @override
  String get removeOption => 'إزالة الخيار';

  @override
  String get selectCorrectAnswer => 'اختر الإجابة الصحيحة';

  @override
  String get selectCorrectAnswers => 'اختر الإجابات الصحيحة';

  @override
  String emptyOptionsError(String optionNumbers) {
    return 'الخيارات $optionNumbers فارغة. يرجى إضافة نص إليها أو إزالتها.';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return 'الخيار $optionNumber فارغ. يرجى إضافة نص إليه أو إزالته.';
  }

  @override
  String get optionEmptyError => 'هذا الخيار لا يمكن أن يكون فارغاً';

  @override
  String get hasImage => 'صورة';

  @override
  String get hasExplanation => 'شرح';

  @override
  String errorLoadingSettings(String error) {
    return 'خطأ في تحميل الإعدادات: $error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return 'لا يمكن فتح $url';
  }

  @override
  String get loadingAiServices => 'جاري تحميل خدمات الذكاء الاصطناعي...';

  @override
  String usingAiService(String serviceName) {
    return 'الاستخدام: $serviceName';
  }

  @override
  String get aiServiceLabel => 'خدمة الذكاء الاصطناعي:';

  @override
  String get aiModelLabel => 'النموذج:';

  @override
  String get importQuestionsTitle => 'استيراد الأسئلة';

  @override
  String importQuestionsMessage(int count, String fileName) {
    return 'وجدت $count أسئلة في \"$fileName\". أين تريد استيرادها؟';
  }

  @override
  String get importQuestionsPositionQuestion => 'أين تريد إضافة هذه الأسئلة؟';

  @override
  String get importAtBeginning => 'في البداية';

  @override
  String get importAtEnd => 'في النهاية';

  @override
  String questionsImportedSuccess(int count) {
    return 'تم استيراد $count أسئلة بنجاح';
  }

  @override
  String get importQuestionsTooltip => 'استيراد أسئلة من ملف اختبار آخر';

  @override
  String get dragDropHintText =>
      'يمكنك أيضاً سحب وإفلات ملفات .quiz هنا لاستيراد الأسئلة';

  @override
  String get randomizeAnswersTitle => 'عشوائية خيارات الإجابة';

  @override
  String get randomizeAnswersDescription =>
      'خلط ترتيب خيارات الإجابة أثناء تنفيذ الاختبار';

  @override
  String get showCorrectAnswerCountTitle => 'إظهار عدد الإجابات الصحيحة';

  @override
  String get showCorrectAnswerCountDescription =>
      'عرض عدد الإجابات الصحيحة في أسئلة الاختيار المتعدد';

  @override
  String correctAnswersCount(int count) {
    return 'اختر $count إجابات صحيحة';
  }

  @override
  String get correctSelectedLabel => 'صحيح';

  @override
  String get correctMissedLabel => 'صحيح';

  @override
  String get incorrectSelectedLabel => 'خطأ';

  @override
  String get aiGenerateDialogTitle => 'إنتاج أسئلة بالذكاء الاصطناعي';

  @override
  String get aiQuestionCountLabel => 'عدد الأسئلة (اختياري)';

  @override
  String get aiQuestionCountHint => 'اتركه فارغاً ليقرر الذكاء الاصطناعي';

  @override
  String get aiQuestionCountValidation => 'يجب أن يكون رقماً بين 1 و 50';

  @override
  String get aiQuestionTypeLabel => 'نوع السؤال';

  @override
  String get aiQuestionTypeRandom => 'عشوائي (مختلط)';

  @override
  String get aiLanguageLabel => 'لغة الأسئلة';

  @override
  String get aiContentLabel => 'المحتوى لإنتاج الأسئلة منه';

  @override
  String aiWordCount(int current, int max) {
    return '$current / $max كلمة';
  }

  @override
  String get aiContentHint =>
      'أدخل النص أو الموضوع أو المحتوى الذي تريد إنتاج أسئلة منه...';

  @override
  String get aiContentHelperText =>
      'سينشئ الذكاء الاصطناعي أسئلة بناءً على هذا المحتوى';

  @override
  String aiWordLimitError(int max) {
    return 'لقد تجاوزت حد $max كلمة';
  }

  @override
  String get aiContentRequiredError => 'يجب أن تقدم محتوى لإنتاج الأسئلة';

  @override
  String aiContentLimitError(int max) {
    return 'المحتوى يتجاوز حد $max كلمة';
  }

  @override
  String get aiMinWordsError =>
      'قدم 10 كلمات على الأقل لإنتاج أسئلة عالية الجودة';

  @override
  String get aiInfoTitle => 'معلومات';

  @override
  String get aiInfoDescription =>
      '• سيحلل الذكاء الاصطناعي المحتوى وينتج أسئلة ذات صلة\n• إذا كتبت أقل من 10 كلمات، فستدخل في وضع الموضوع حيث سيطرح أسئلة حول تلك المواضيع المحددة، ومع أكثر من 10 كلمات ستدخل في وضع المحتوى الذي سيطرح أسئلة حول النص نفسه (مزيد من الكلمات = مزيد من الدقة)\n• يمكنك تضمين نصوص وتعريفات وشروحات أو أي مادة تعليمية\n• ستتضمن الأسئلة خيارات إجابة وشروحات\n• قد تستغرق العملية بضع ثوانٍ';

  @override
  String get aiGenerateButton => 'إنتاج الأسئلة';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageGreek => 'Ελληνικά';

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
  String get aiServicesLoading => 'جاري تحميل خدمات الذكاء الاصطناعي...';

  @override
  String get aiServicesNotConfigured => 'لم يتم تكوين خدمات الذكاء الاصطناعي';

  @override
  String get aiGeneratedQuestions => 'منتج بالذكاء الاصطناعي';

  @override
  String get aiApiKeyRequired =>
      'يرجى تكوين مفتاح API واحد على الأقل للذكاء الاصطناعي في الإعدادات لاستخدام الإنتاج بالذكاء الاصطناعي.';

  @override
  String get aiGenerationFailed =>
      'لم أتمكن من إنتاج الأسئلة. جرب بمحتوى مختلف.';

  @override
  String aiGenerationError(String error) {
    return 'خطأ في إنتاج الأسئلة: $error';
  }

  @override
  String get noQuestionsInFile => 'لم توجد أسئلة في الملف المستورد';

  @override
  String get couldNotAccessFile => 'لا يمكن الوصول إلى الملف المحدد';

  @override
  String get defaultOutputFileName => 'output-file.quiz';

  @override
  String get generateQuestionsWithAI => 'إنتاج أسئلة بالذكاء الاصطناعي';

  @override
  String aiServiceLimitsWithChars(int words, int chars) {
    return 'الحد: $words كلمة أو $chars حرف';
  }

  @override
  String aiServiceLimitsWordsOnly(int words) {
    return 'الحد: $words كلمة';
  }

  @override
  String get aiAssistantDisabled => 'مساعد الذكاء الاصطناعي معطل';

  @override
  String get enableAiAssistant =>
      'مساعد الذكاء الاصطناعي معطل. يرجى تفعيله في الإعدادات لاستخدام ميزات الذكاء الاصطناعي.';

  @override
  String aiMinWordsRequired(int minWords) {
    return 'مطلوب الحد الأدنى $minWords كلمة';
  }

  @override
  String aiWordsReadyToGenerate(int wordCount) {
    return '$wordCount كلمة ✓ جاهز للتوليد';
  }

  @override
  String aiWordsProgress(int currentWords, int minWords, int moreNeeded) {
    return '$currentWords/$minWords كلمة (نحتاج $moreNeeded أكثر)';
  }

  @override
  String aiValidationMinWords(int minWords, int moreNeeded) {
    return 'مطلوب الحد الأدنى $minWords كلمة (نحتاج $moreNeeded أكثر)';
  }

  @override
  String get enableQuestion => 'تفعيل السؤال';

  @override
  String get disableQuestion => 'تعطيل السؤال';

  @override
  String get questionDisabled => 'معطل';

  @override
  String get noEnabledQuestionsError => 'لا توجد أسئلة مفعلة لتشغيل الاختبار';

  @override
  String get evaluateWithAI => 'تقييم بالذكاء الاصطناعي';

  @override
  String get aiEvaluation => 'تقييم الذكاء الاصطناعي';

  @override
  String aiEvaluationError(String error) {
    return 'خطأ في تقييم الإجابة: $error';
  }

  @override
  String get aiEvaluationPromptSystemRole =>
      'أنت مدرس خبير تقيم إجابة طالب على سؤال مقال. مهمتك هي تقديم تقييم مفصل وبناء. يرجى الإجابة باللغة العربية.';

  @override
  String get aiEvaluationPromptQuestion => 'السؤال:';

  @override
  String get aiEvaluationPromptStudentAnswer => 'إجابة الطالب:';

  @override
  String get aiEvaluationPromptCriteria =>
      'معايير التقييم (بناءً على شرح المعلم):';

  @override
  String get aiEvaluationPromptSpecificInstructions =>
      'تعليمات محددة:\n- قيم مدى توافق إجابة الطالب مع المعايير المحددة\n- حلل درجة التركيب والهيكل في الإجابة\n- حدد إذا كان هناك شيء مهم مفقود وفقاً للمعايير\n- اعتبر عمق ودقة التحليل';

  @override
  String get aiEvaluationPromptGeneralInstructions =>
      'تعليمات عامة:\n- بما أنه لا توجد معايير محددة، قيم الإجابة بناءً على المعايير الأكاديمية العامة\n- اعتبر الوضوح والتماسك وهيكل الإجابة\n- قيم إذا كانت الإجابة تظهر فهماً للموضوع\n- حلل عمق التحليل وجودة الحجج';

  @override
  String get aiEvaluationPromptResponseFormat =>
      'تنسيق الإجابة:\n1. الدرجة: [X/10] - اذكر مبرراً مختصراً للدرجة\n2. نقاط القوة: اذكر الجوانب الإيجابية في الإجابة\n3. مجالات التحسين: أشر إلى الجوانب التي يمكن تحسينها\n4. تعليقات محددة: قدم ملاحظات مفصلة وبناءة\n5. اقتراحات: قدم توصيات محددة للتحسين\n\nكن بناءً ومحدداً وتعليمياً في تقييمك. الهدف هو مساعدة الطالب على التعلم والتحسن. اخاطبه بصيغة المخاطب واستخدم نبرة مهنية وودية.';

  @override
  String get raffleTitle => 'سحب القرعة';

  @override
  String get raffleTooltip => 'فتح شاشة السحب';

  @override
  String get participantListTitle => 'قائمة المشاركين';

  @override
  String get participantListHint => 'أدخل الأسماء مفصولة بسطر جديد';

  @override
  String get participantListPlaceholder =>
      'أدخل أسماء المشاركين هنا...\nاسم واحد في كل سطر';

  @override
  String get clearList => 'محو القائمة';

  @override
  String get participants => 'مشاركون';

  @override
  String get noParticipants => 'لا يوجد مشاركون';

  @override
  String get addParticipantsHint => 'أضف مشاركين لبدء السحب';

  @override
  String get activeParticipants => 'المشاركون النشطون';

  @override
  String get alreadySelected => 'تم اختيارهم مسبقاً';

  @override
  String totalParticipants(int count) {
    return 'إجمالي المشاركين';
  }

  @override
  String activeVsWinners(int active, int winners) {
    return '$active نشطون، $winners فائزون';
  }

  @override
  String get startRaffle => 'بدء السحب';

  @override
  String get raffling => 'جاري السحب...';

  @override
  String get selectingWinner => 'اختيار الفائز...';

  @override
  String get allParticipantsSelected => 'تم اختيار جميع المشاركين';

  @override
  String get addParticipantsToStart => 'أضف مشاركين لبدء السحب';

  @override
  String participantsReadyCount(int count) {
    return '$count مشاركون جاهزون للسحب';
  }

  @override
  String get resetWinners => 'إعادة تعيين الفائزين';

  @override
  String get resetWinnersConfirmTitle => 'إعادة تعيين الفائزين؟';

  @override
  String get resetWinnersConfirmMessage =>
      'هذا سيعيد جميع الفائزين إلى قائمة المشاركين النشطين.';

  @override
  String get resetRaffleTitle => 'إعادة تعيين السحب؟';

  @override
  String get resetRaffleConfirmMessage =>
      'هذا سيعيد تعيين جميع الفائزين والمشاركين النشطين.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get viewWinners => 'عرض الفائزين';

  @override
  String get congratulations => 'تهانينا!';

  @override
  String positionLabel(int position) {
    return 'المركز $position';
  }

  @override
  String remainingParticipants(int count) {
    return 'مشاركون متبقون: $count';
  }

  @override
  String get continueRaffle => 'متابعة السحب';

  @override
  String get finishRaffle => 'إنهاء السحب';

  @override
  String get winnersTitle => 'الفائزون';

  @override
  String get shareResults => 'مشاركة النتائج';

  @override
  String get noWinnersYet => 'لا يوجد فائزون بعد';

  @override
  String get performRaffleToSeeWinners => 'قم بإجراء سحب لرؤية الفائزين';

  @override
  String get goToRaffle => 'الذهاب إلى السحب';

  @override
  String get raffleCompleted => 'اكتمل السحب!';

  @override
  String winnersSelectedCount(int count) {
    return 'تم اختيار $count فائزين';
  }

  @override
  String get newRaffle => 'سحب جديد';

  @override
  String get shareResultsTitle => 'نتائج السحب';

  @override
  String get raffleResultsLabel => 'نتائج السحب:';

  @override
  String get close => 'إغلاق';

  @override
  String get share => 'نسخ';

  @override
  String get shareNotImplemented => 'المشاركة غير مطبقة بعد';

  @override
  String get firstPlace => 'المركز الأول';

  @override
  String get secondPlace => 'المركز الثاني';

  @override
  String get thirdPlace => 'المركز الثالث';

  @override
  String nthPlace(int position) {
    return 'المركز $position';
  }

  @override
  String placeLabel(String position) {
    return 'المركز';
  }

  @override
  String get raffleResultsHeader => 'نتائج السحب - null فائزين';

  @override
  String totalWinners(int count) {
    return 'إجمالي الفائزين: $count';
  }

  @override
  String get noWinnersToShare => 'لا يوجد فائزون للمشاركة';

  @override
  String get shareSuccess => 'تم نسخ النتائج بنجاح';

  @override
  String get selectLogo => 'اختيار الشعار';

  @override
  String get logoUrl => 'رابط الشعار';

  @override
  String get logoUrlHint => 'أدخل رابط صورة لاستخدامها كشعار مخصص للسحب';

  @override
  String get invalidLogoUrl =>
      'رابط صورة غير صالح. يجب أن يكون رابطاً صالحاً ينتهي بـ .jpg أو .png أو .gif إلخ.';

  @override
  String get logoPreview => 'معاينة';

  @override
  String get removeLogo => 'إزالة الشعار';

  @override
  String get logoTooLargeWarning =>
      'الصورة كبيرة جداً ولا يمكن حفظها. سيتم استخدامها فقط خلال هذه الجلسة.';

  @override
  String get aiModeTopicTitle => 'وضع الموضوع';

  @override
  String get aiModeTopicDescription => 'استكشاف إبداعي للموضوع';

  @override
  String get aiModeContentTitle => 'وضع المحتوى';

  @override
  String get aiModeContentDescription => 'أسئلة دقيقة بناءً على مدخلاتك';

  @override
  String aiWordCountIndicator(int count) {
    return '$count كلمة';
  }

  @override
  String aiPrecisionIndicator(String level) {
    return 'الدقة: $level';
  }

  @override
  String get aiPrecisionLow => 'منخفضة';

  @override
  String get aiPrecisionMedium => 'متوسطة';

  @override
  String get aiPrecisionHigh => 'عالية';

  @override
  String get aiMoreWordsMorePrecision => 'كلمات أكثر = دقة أعلى';
}
