// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get titleAppBar => 'Quiz - Simulateur d\'Examens';

  @override
  String get create => 'Créer';

  @override
  String get load => 'Charger';

  @override
  String fileLoaded(String filePath) {
    return 'Fichier chargé : $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'Fichier sauvegardé : $filePath';
  }

  @override
  String get dropFileHere =>
      'Cliquez ici ou faites glisser un fichier .quiz vers l\'écran';

  @override
  String get errorInvalidFile =>
      'Erreur : Fichier invalide. Doit être un fichier .quiz.';

  @override
  String errorLoadingFile(String error) {
    return 'Erreur lors du chargement du fichier Quiz : $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Erreur lors de l\'exportation du fichier : $error';
  }

  @override
  String get cancelButton => 'Annuler';

  @override
  String get saveButton => 'Sauvegarder';

  @override
  String get confirmDeleteTitle => 'Confirmer la suppression';

  @override
  String confirmDeleteMessage(String processName) {
    return 'Êtes-vous sûr de vouloir supprimer le processus `$processName` ?';
  }

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get confirmExitTitle => 'Confirmer la sortie';

  @override
  String get confirmExitMessage =>
      'Êtes-vous sûr de vouloir quitter sans sauvegarder ?';

  @override
  String get exitButton => 'Quitter';

  @override
  String get saveDialogTitle => 'Veuillez sélectionner un fichier de sortie :';

  @override
  String get createQuizFileTitle => 'Créer un fichier Quiz';

  @override
  String get fileNameLabel => 'Nom du fichier';

  @override
  String get fileDescriptionLabel => 'Description du fichier';

  @override
  String get createButton => 'Créer';

  @override
  String get fileNameRequiredError => 'Le nom du fichier est requis.';

  @override
  String get fileDescriptionRequiredError =>
      'La description du fichier est requise.';

  @override
  String get versionLabel => 'Version';

  @override
  String get authorLabel => 'Auteur';

  @override
  String get authorRequiredError => 'L\'auteur est requis.';

  @override
  String get requiredFieldsError =>
      'Tous les champs requis doivent être complétés.';

  @override
  String get requestFileNameTitle => 'Entrez le nom du fichier Quiz';

  @override
  String get fileNameHint => 'Nom du fichier';

  @override
  String get emptyFileNameMessage => 'Le nom du fichier ne peut pas être vide.';

  @override
  String get acceptButton => 'Accepter';

  @override
  String get saveTooltip => 'Sauvegarder le fichier';

  @override
  String get saveDisabledTooltip => 'Aucun changement à sauvegarder';

  @override
  String get executeTooltip => 'Exécuter l\'examen';

  @override
  String get addTooltip => 'Ajouter une nouvelle question';

  @override
  String get backSemanticLabel => 'Bouton retour';

  @override
  String get createFileTooltip => 'Créer un nouveau fichier Quiz';

  @override
  String get loadFileTooltip => 'Charger un fichier Quiz existant';

  @override
  String questionNumber(int number) {
    return 'Question $number';
  }

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get finish => 'Terminer';

  @override
  String get finishQuiz => 'Terminer le Quiz';

  @override
  String get finishQuizConfirmation =>
      'Êtes-vous sûr de vouloir terminer le quiz ? Vous ne pourrez plus modifier vos réponses après.';

  @override
  String get cancel => 'Annuler';

  @override
  String get abandonQuiz => 'Abandonner le Quiz';

  @override
  String get abandonQuizConfirmation =>
      'Êtes-vous sûr de vouloir abandonner le quiz ? Tous les progrès seront perdus.';

  @override
  String get abandon => 'Abandonner';

  @override
  String get quizCompleted => 'Quiz Terminé !';

  @override
  String score(String score) {
    return 'Score : $score%';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$correct de $total réponses correctes';
  }

  @override
  String get retry => 'Répéter';

  @override
  String get goBack => 'Terminer';

  @override
  String get retryFailedQuestions => 'Reprendre Échecs';

  @override
  String question(String question) {
    return 'Question : $question';
  }

  @override
  String get selectQuestionCountTitle => 'Sélectionner le nombre de questions';

  @override
  String get selectQuestionCountMessage =>
      'Combien de questions aimeriez-vous répondre dans ce quiz ?';

  @override
  String allQuestions(int count) {
    return 'Toutes les questions ($count)';
  }

  @override
  String get startQuiz => 'Commencer le Quiz';

  @override
  String get customNumberLabel => 'Ou entrez un nombre personnalisé :';

  @override
  String get numberInputLabel => 'Nombre de questions';

  @override
  String customNumberHelper(int total) {
    return 'Entrez n\'importe quel nombre (max $total). Si supérieur, les questions se répéteront.';
  }

  @override
  String get errorInvalidNumber => 'Veuillez entrer un nombre valide';

  @override
  String get errorNumberMustBePositive => 'Le nombre doit être supérieur à 0';

  @override
  String get questionOrderConfigTitle =>
      'Configuration de l\'ordre des questions';

  @override
  String get questionOrderConfigDescription =>
      'Sélectionnez l\'ordre dans lequel vous voulez que les questions apparaissent pendant l\'examen :';

  @override
  String get questionOrderAscending => 'Ordre Croissant';

  @override
  String get questionOrderAscendingDesc =>
      'Les questions apparaîtront dans l\'ordre de 1 à la fin';

  @override
  String get questionOrderDescending => 'Ordre Décroissant';

  @override
  String get questionOrderDescendingDesc =>
      'Les questions apparaîtront de la fin à 1';

  @override
  String get questionOrderRandom => 'Aléatoire';

  @override
  String get questionOrderRandomDesc =>
      'Les questions apparaîtront dans un ordre aléatoire';

  @override
  String get questionOrderConfigTooltip =>
      'Configuration de l\'ordre des questions';

  @override
  String get save => 'Sauvegarder';

  @override
  String get examTimeLimitTitle => 'Limite de temps d\'examen';

  @override
  String get examTimeLimitDescription =>
      'Définir une limite de temps pour l\'examen. Lorsqu\'elle est activée, un minuteur de compte à rebours sera affiché pendant le quiz.';

  @override
  String get enableTimeLimit => 'Activer la limite de temps';

  @override
  String get timeLimitMinutes => 'Limite de temps (minutes)';

  @override
  String get examTimeExpiredTitle => 'Temps écoulé !';

  @override
  String get examTimeExpiredMessage =>
      'Le temps d\'examen a expiré. Vos réponses ont été automatiquement soumises.';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => 'Choix Multiple';

  @override
  String get questionTypeSingleChoice => 'Choix Unique';

  @override
  String get questionTypeTrueFalse => 'Vrai/Faux';

  @override
  String get questionTypeEssay => 'Essai';

  @override
  String get questionTypeUnknown => 'Inconnu';

  @override
  String optionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count options',
      one: '1 option',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip =>
      'Nombre d\'options de réponse pour cette question';

  @override
  String get imageTooltip => 'Cette question a une image associée';

  @override
  String get explanationTooltip => 'Cette question a une explication';

  @override
  String get aiPrompt =>
      'Vous êtes un tuteur expert et amical spécialisé dans l\'aide aux étudiants pour mieux comprendre les questions d\'examen et les sujets connexes. Votre objectif est de faciliter l\'apprentissage profond et la compréhension conceptuelle.\n\nVous pouvez aider avec :\n- Expliquer les concepts liés à la question\n- Clarifier les doutes sur les options de réponse\n- Fournir un contexte supplémentaire sur le sujet\n- Suggérer des ressources d\'étude complémentaires\n- Expliquer pourquoi certaines réponses sont correctes ou incorrectes\n- Relier le sujet à d\'autres concepts importants\n- Répondre aux questions de suivi sur le matériel\n\nRépondez toujours dans la même langue dans laquelle on vous pose la question. Soyez pédagogique, clair et motivant dans vos explications.';

  @override
  String get questionLabel => 'Question';

  @override
  String get optionsLabel => 'Options';

  @override
  String get explanationLabel => 'Explication (optionnelle)';

  @override
  String get studentComment => 'Commentaire de l\'étudiant';

  @override
  String get aiAssistantTitle => 'Assistant d\'Étude IA';

  @override
  String get questionContext => 'Contexte de la Question';

  @override
  String get aiAssistant => 'Assistant IA';

  @override
  String get aiThinking => 'L\'IA réfléchit...';

  @override
  String get askAIHint => 'Posez votre question sur ce sujet...';

  @override
  String get aiPlaceholderResponse =>
      'Ceci est une réponse d\'espace réservé. Dans une implémentation réelle, cela se connecterait à un service IA pour fournir des explications utiles sur la question.';

  @override
  String get aiErrorResponse =>
      'Désolé, il y a eu une erreur lors du traitement de votre question. Veuillez réessayer.';

  @override
  String get configureApiKeyMessage =>
      'Veuillez configurer votre clé API IA dans les Paramètres.';

  @override
  String get errorLabel => 'Erreur :';

  @override
  String get noResponseReceived => 'Aucune réponse reçue';

  @override
  String get invalidApiKeyError =>
      'Clé API invalide. Veuillez vérifier votre clé API OpenAI dans les paramètres.';

  @override
  String get rateLimitError =>
      'Limite de taux dépassée. Veuillez réessayer plus tard.';

  @override
  String get modelNotFoundError =>
      'Modèle non trouvé. Veuillez vérifier votre accès API.';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get networkError =>
      'Erreur réseau : Impossible de se connecter à OpenAI. Veuillez vérifier votre connexion internet.';

  @override
  String get openaiApiKeyNotConfigured => 'Clé API OpenAI non configurée';

  @override
  String get geminiApiKeyNotConfigured => 'Clé API Gemini non configurée';

  @override
  String get geminiApiKeyLabel => 'Clé API Gemini';

  @override
  String get geminiApiKeyHint => 'Entrez votre clé API Gemini';

  @override
  String get geminiApiKeyDescription =>
      'Requis pour la fonctionnalité IA Gemini. Votre clé est stockée en sécurité.';

  @override
  String get getGeminiApiKeyTooltip =>
      'Obtenir la clé API depuis Google AI Studio';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'L\'Assistant d\'Étude IA nécessite au moins une clé API (OpenAI ou Gemini). Veuillez entrer une clé API ou désactiver l\'Assistant IA.';

  @override
  String get minutesAbbreviation => 'min';

  @override
  String get aiButtonTooltip => 'Assistant d\'Étude IA';

  @override
  String get aiButtonText => 'IA';

  @override
  String get aiAssistantSettingsTitle => 'Assistant d\'Étude IA (Aperçu)';

  @override
  String get aiAssistantSettingsDescription =>
      'Activer ou désactiver l\'assistant d\'étude IA pour les questions';

  @override
  String get openaiApiKeyLabel => 'Clé API OpenAI';

  @override
  String get openaiApiKeyHint => 'Entrez votre clé API OpenAI (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'Requis pour l\'intégration avec OpenAI. Votre clé OpenAI est stockée en sécurité.';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'L\'Assistant d\'Étude IA nécessite une clé API OpenAI. Veuillez entrer votre clé API ou désactiver l\'Assistant IA.';

  @override
  String get getApiKeyTooltip => 'Obtenir la clé API depuis OpenAI';

  @override
  String get deleteAction => 'Supprimer';

  @override
  String get explanationHint =>
      'Entrez une explication pour la ou les réponses correctes';

  @override
  String get explanationTitle => 'Explication';

  @override
  String get imageLabel => 'Image';

  @override
  String get changeImage => 'Changer l\'image';

  @override
  String get removeImage => 'Supprimer l\'image';

  @override
  String get addImageTap => 'Appuyez pour ajouter une image';

  @override
  String get imageFormats => 'Formats : JPG, PNG, GIF';

  @override
  String get imageLoadError => 'Erreur de chargement de l\'image';

  @override
  String imagePickError(String error) {
    return 'Erreur de chargement de l\'image : $error';
  }

  @override
  String get tapToZoom => 'Appuyez pour zoomer';

  @override
  String get trueLabel => 'Vrai';

  @override
  String get falseLabel => 'Faux';

  @override
  String get addQuestion => 'Ajouter une Question';

  @override
  String get editQuestion => 'Modifier la Question';

  @override
  String get questionText => 'Texte de la Question';

  @override
  String get questionType => 'Type de Question';

  @override
  String get addOption => 'Ajouter une Option';

  @override
  String get optionLabel => 'Option';

  @override
  String get questionTextRequired => 'Le texte de la question est requis';

  @override
  String get atLeastOneOptionRequired =>
      'Au moins une option doit avoir du texte';

  @override
  String get atLeastOneCorrectAnswerRequired =>
      'Au moins une réponse correcte doit être sélectionnée';

  @override
  String get onlyOneCorrectAnswerAllowed =>
      'Une seule réponse correcte est autorisée pour ce type de question';

  @override
  String get removeOption => 'Supprimer l\'option';

  @override
  String get selectCorrectAnswer => 'Sélectionner la réponse correcte';

  @override
  String get selectCorrectAnswers => 'Sélectionner les réponses correctes';

  @override
  String emptyOptionsError(String optionNumbers) {
    return 'Les options $optionNumbers sont vides. Veuillez leur ajouter du texte ou les supprimer.';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return 'L\'option $optionNumber est vide. Veuillez lui ajouter du texte ou la supprimer.';
  }

  @override
  String get optionEmptyError => 'Cette option ne peut pas être vide';

  @override
  String get hasImage => 'Image';

  @override
  String get hasExplanation => 'Explication';

  @override
  String errorLoadingSettings(String error) {
    return 'Erreur de chargement des paramètres : $error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String get loadingAiServices => 'Chargement des services IA...';

  @override
  String usingAiService(String serviceName) {
    return 'Utilisation : $serviceName';
  }

  @override
  String get aiServiceLabel => 'Service IA :';

  @override
  String get importQuestionsTitle => 'Importer des Questions';

  @override
  String importQuestionsMessage(int count, String fileName) {
    return 'Trouvé $count questions dans \"$fileName\". Où souhaitez-vous les importer ?';
  }

  @override
  String get importQuestionsPositionQuestion =>
      'Où souhaitez-vous ajouter ces questions ?';

  @override
  String get importAtBeginning => 'Au Début';

  @override
  String get importAtEnd => 'À la Fin';

  @override
  String questionsImportedSuccess(int count) {
    return 'Importation réussie de $count questions';
  }

  @override
  String get importQuestionsTooltip =>
      'Importer des questions depuis un autre fichier quiz';

  @override
  String get dragDropHintText =>
      'Vous pouvez aussi faire glisser et déposer des fichiers .quiz ici pour importer des questions';

  @override
  String get randomizeAnswersTitle => 'Randomiser les Options de Réponse';

  @override
  String get randomizeAnswersDescription =>
      'Mélanger l\'ordre des options de réponse pendant l\'exécution du quiz';

  @override
  String get showCorrectAnswerCountTitle =>
      'Afficher le Nombre de Réponses Correctes';

  @override
  String get showCorrectAnswerCountDescription =>
      'Afficher le nombre de réponses correctes dans les questions à choix multiple';

  @override
  String correctAnswersCount(int count) {
    return 'Sélectionnez $count réponses correctes';
  }

  @override
  String get correctSelectedLabel => 'Correct';

  @override
  String get correctMissedLabel => 'Correct';

  @override
  String get incorrectSelectedLabel => 'Incorrect';

  @override
  String get generateQuestionsWithAI => 'Générer des questions avec l\'IA';

  @override
  String get aiGenerateDialogTitle => 'Générer des Questions avec l\'IA';

  @override
  String get aiQuestionCountLabel => 'Nombre de Questions (Optionnel)';

  @override
  String get aiQuestionCountHint => 'Laisser vide pour laisser l\'IA décider';

  @override
  String get aiQuestionCountValidation => 'Doit être un nombre entre 1 et 50';

  @override
  String get aiQuestionTypeLabel => 'Type de Question';

  @override
  String get aiQuestionTypeRandom => 'Aléatoire (Mixte)';

  @override
  String get aiLanguageLabel => 'Langue des Questions';

  @override
  String get aiContentLabel => 'Contenu pour générer des questions';

  @override
  String aiWordCount(int current, int max) {
    return '$current / $max mots';
  }

  @override
  String get aiContentHint =>
      'Entrez le texte, sujet, ou contenu à partir duquel vous voulez générer des questions...';

  @override
  String get aiContentHelperText =>
      'L\'IA créera des questions basées sur ce contenu';

  @override
  String aiWordLimitError(int max) {
    return 'Vous avez dépassé la limite de $max mots';
  }

  @override
  String get aiContentRequiredError =>
      'Vous devez fournir du contenu pour générer des questions';

  @override
  String aiContentLimitError(int max) {
    return 'Le contenu dépasse la limite de $max mots';
  }

  @override
  String get aiMinWordsError =>
      'Fournissez au moins 10 mots pour générer des questions de qualité';

  @override
  String get aiInfoTitle => 'Information';

  @override
  String get aiInfoDescription =>
      '• L\'IA analysera le contenu et générera des questions pertinentes\n• Vous pouvez inclure du texte, des définitions, des explications, ou tout matériel éducatif\n• Les questions incluront des options de réponse et des explications\n• Le processus peut prendre quelques secondes';

  @override
  String get aiGenerateButton => 'Générer des Questions';

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
  String get aiServicesLoading => 'Chargement des services IA...';

  @override
  String get aiServicesNotConfigured => 'Aucun service IA configuré';

  @override
  String get aiGeneratedQuestions => 'Généré par IA';

  @override
  String get aiApiKeyRequired =>
      'Veuillez configurer au moins une clé API IA dans les Paramètres pour utiliser la génération IA.';

  @override
  String get aiGenerationFailed =>
      'Impossible de générer des questions. Essayez avec un contenu différent.';

  @override
  String aiGenerationError(String error) {
    return 'Erreur de génération de questions : $error';
  }

  @override
  String get noQuestionsInFile =>
      'Aucune question trouvée dans le fichier importé';

  @override
  String get couldNotAccessFile =>
      'Impossible d\'accéder au fichier sélectionné';

  @override
  String get defaultOutputFileName => 'fichier-sortie.quiz';

  @override
  String aiServiceLimitsWithChars(int words, int chars) {
    return 'Limite : $words mots ou $chars caractères';
  }

  @override
  String aiServiceLimitsWordsOnly(int words) {
    return 'Limite : $words mots';
  }

  @override
  String get aiAssistantDisabled => 'Assistant IA Désactivé';

  @override
  String get enableAiAssistant =>
      'L\'assistant IA est désactivé. Veuillez l\'activer dans les paramètres pour utiliser les fonctionnalités IA.';

  @override
  String aiMinWordsRequired(int minWords) {
    return 'Minimum $minWords mots requis';
  }

  @override
  String aiWordsReadyToGenerate(int wordCount) {
    return '$wordCount mots ✓ Prêt à générer';
  }

  @override
  String aiWordsProgress(int currentWords, int minWords, int moreNeeded) {
    return '$currentWords/$minWords mots ($moreNeeded de plus nécessaires)';
  }

  @override
  String aiValidationMinWords(int minWords, int moreNeeded) {
    return 'Minimum $minWords mots requis ($moreNeeded de plus nécessaires)';
  }

  @override
  String get enableQuestion => 'Activer la question';

  @override
  String get disableQuestion => 'Désactiver la question';

  @override
  String get questionDisabled => 'Désactivée';

  @override
  String get noEnabledQuestionsError =>
      'Aucune question activée disponible pour lancer le quiz';

  @override
  String get evaluateWithAI => 'Évaluer avec l\'IA';

  @override
  String get aiEvaluation => 'Évaluation IA';

  @override
  String aiEvaluationError(String error) {
    return 'Erreur lors de l\'évaluation de la réponse : $error';
  }

  @override
  String get aiEvaluationPromptSystemRole =>
      'Vous êtes un professeur expert évaluant la réponse d\'un étudiant à une question de dissertation. Votre tâche est de fournir une évaluation détaillée et constructive. Veuillez répondre en français.';

  @override
  String get aiEvaluationPromptQuestion => 'QUESTION:';

  @override
  String get aiEvaluationPromptStudentAnswer => 'RÉPONSE DE L\'ÉTUDIANT:';

  @override
  String get aiEvaluationPromptCriteria =>
      'CRITÈRES D\'ÉVALUATION (basés sur l\'explication du professeur):';

  @override
  String get aiEvaluationPromptSpecificInstructions =>
      'INSTRUCTIONS SPÉCIFIQUES:\n- Évaluez dans quelle mesure la réponse de l\'étudiant s\'aligne sur les critères établis\n- Analysez le degré de synthèse et la structure de la réponse\n- Identifiez si quelque chose d\'important a été omis selon les critères\n- Considérez la profondeur et la précision de l\'analyse';

  @override
  String get aiEvaluationPromptGeneralInstructions =>
      'INSTRUCTIONS GÉNÉRALES:\n- Comme il n\'y a pas de critères spécifiques établis, évaluez la réponse selon les standards académiques généraux\n- Considérez la clarté, la cohérence et la structure de la réponse\n- Évaluez si la réponse démontre une compréhension du sujet\n- Analysez la profondeur de l\'analyse et la qualité des arguments';

  @override
  String get aiEvaluationPromptResponseFormat =>
      'FORMAT DE RÉPONSE:\n1. NOTE: [X/10] - Justifiez brièvement la note\n2. POINTS FORTS: Mentionnez les aspects positifs de la réponse\n3. DOMAINES D\'AMÉLIORATION: Signalez les aspects qui pourraient être améliorés\n4. COMMENTAIRES SPÉCIFIQUES: Fournissez des commentaires détaillés et constructifs\n5. SUGGESTIONS: Offrez des recommandations spécifiques pour l\'amélioration\n\nSoyez constructif, spécifique et éducatif dans votre évaluation. L\'objectif est d\'aider l\'étudiant à apprendre et à s\'améliorer. Adressez-vous à lui à la deuxième personne et utilisez un ton professionnel et amical.';
}
