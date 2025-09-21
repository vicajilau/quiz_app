// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get titleAppBar => '测验 - 考试模拟器';

  @override
  String get create => '创建';

  @override
  String get load => '加载';

  @override
  String fileLoaded(String filePath) {
    return '文件已加载：$filePath';
  }

  @override
  String fileSaved(String filePath) {
    return '文件已保存：$filePath';
  }

  @override
  String get dropFileHere => '点击这里或将.quiz文件拖拽到屏幕';

  @override
  String get errorInvalidFile => '错误：无效文件。必须是.quiz文件。';

  @override
  String errorLoadingFile(String error) {
    return '加载测验文件时出错：$error';
  }

  @override
  String errorExportingFile(String error) {
    return '导出文件时出错：$error';
  }

  @override
  String get cancelButton => '取消';

  @override
  String get saveButton => '保存';

  @override
  String get confirmDeleteTitle => '确认删除';

  @override
  String confirmDeleteMessage(String processName) {
    return '您确定要删除\"$processName\"过程吗？';
  }

  @override
  String get deleteButton => '删除';

  @override
  String get confirmExitTitle => '确认退出';

  @override
  String get confirmExitMessage => '您确定要在不保存的情况下退出吗？';

  @override
  String get exitButton => '退出';

  @override
  String get saveDialogTitle => '请选择输出文件：';

  @override
  String get createQuizFileTitle => '创建测验文件';

  @override
  String get fileNameLabel => '文件名';

  @override
  String get fileDescriptionLabel => '文件描述';

  @override
  String get createButton => '创建';

  @override
  String get fileNameRequiredError => '文件名是必需的。';

  @override
  String get fileDescriptionRequiredError => '文件描述是必需的。';

  @override
  String get versionLabel => '版本';

  @override
  String get authorLabel => '作者';

  @override
  String get authorRequiredError => '作者是必需的。';

  @override
  String get requiredFieldsError => '所有必填字段都必须填写。';

  @override
  String get requestFileNameTitle => '输入测验文件名';

  @override
  String get fileNameHint => '文件名';

  @override
  String get emptyFileNameMessage => '文件名不能为空。';

  @override
  String get acceptButton => '接受';

  @override
  String get saveTooltip => '保存文件';

  @override
  String get saveDisabledTooltip => '没有需要保存的更改';

  @override
  String get executeTooltip => '执行考试';

  @override
  String get addTooltip => '添加新问题';

  @override
  String get backSemanticLabel => '返回按钮';

  @override
  String get createFileTooltip => '创建新的测验文件';

  @override
  String get loadFileTooltip => '加载现有的测验文件';

  @override
  String questionNumber(int number) {
    return '问题 $number';
  }

  @override
  String get previous => '上一个';

  @override
  String get next => '下一个';

  @override
  String get finish => '完成';

  @override
  String get finishQuiz => '完成测验';

  @override
  String get finishQuizConfirmation => '您确定要完成测验吗？之后您将无法更改答案。';

  @override
  String get cancel => '取消';

  @override
  String get abandonQuiz => '放弃测验';

  @override
  String get abandonQuizConfirmation => '您确定要放弃测验吗？所有进度都将丢失。';

  @override
  String get abandon => '放弃';

  @override
  String get quizCompleted => '测验完成！';

  @override
  String score(String score) {
    return '得分：$score%';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$total个问题中答对$correct个';
  }

  @override
  String get retry => '重试';

  @override
  String get goBack => '完成';

  @override
  String get retryFailedQuestions => '重做错题';

  @override
  String question(String question) {
    return '问题：$question';
  }

  @override
  String get selectQuestionCountTitle => '选择问题数量';

  @override
  String get selectQuestionCountMessage => '您想在这个测验中回答多少个问题？';

  @override
  String allQuestions(int count) {
    return '所有问题（$count个）';
  }

  @override
  String get startQuiz => '开始测验';

  @override
  String get customNumberLabel => '或输入自定义数量：';

  @override
  String get numberInputLabel => '问题数量';

  @override
  String customNumberHelper(int total) {
    return '输入任意数量（最多$total个）。如果超过，问题会重复。';
  }

  @override
  String get errorInvalidNumber => '请输入有效数字';

  @override
  String get errorNumberMustBePositive => '数字必须大于0';

  @override
  String get questionOrderConfigTitle => '问题顺序配置';

  @override
  String get questionOrderConfigDescription => '选择考试期间问题的显示顺序：';

  @override
  String get questionOrderAscending => '升序';

  @override
  String get questionOrderAscendingDesc => '问题将按从1到结尾的顺序显示';

  @override
  String get questionOrderDescending => '降序';

  @override
  String get questionOrderDescendingDesc => '问题将从结尾到1显示';

  @override
  String get questionOrderRandom => '随机';

  @override
  String get questionOrderRandomDesc => '问题将随机显示';

  @override
  String get questionOrderConfigTooltip => '问题顺序配置';

  @override
  String get save => '保存';

  @override
  String get examTimeLimitTitle => '考试时间限制';

  @override
  String get examTimeLimitDescription => '为考试设置时间限制。启用后，测验期间将显示倒计时器。';

  @override
  String get enableTimeLimit => '启用时间限制';

  @override
  String get timeLimitMinutes => '时间限制（分钟）';

  @override
  String get examTimeExpiredTitle => '时间到！';

  @override
  String get examTimeExpiredMessage => '考试时间已到。您的答案已自动提交。';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => '多选题';

  @override
  String get questionTypeSingleChoice => '单选题';

  @override
  String get questionTypeTrueFalse => '判断题';

  @override
  String get questionTypeEssay => '论述题';

  @override
  String get questionTypeUnknown => '未知';

  @override
  String optionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个选项',
      one: '1个选项',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip => '此问题的答案选项数量';

  @override
  String get imageTooltip => '此问题有关联的图片';

  @override
  String get explanationTooltip => '此问题有解释';

  @override
  String get aiPrompt =>
      '您是一位专业且友好的导师，专门帮助学生更好地理解考试问题和相关主题。您的目标是促进深度学习和概念理解。\n\n您可以帮助：\n- 解释与问题相关的概念\n- 澄清对答案选项的疑惑\n- 提供关于主题的额外背景\n- 建议补充学习资源\n- 解释为什么某些答案是正确或错误的\n- 将主题与其他重要概念联系起来\n- 回答有关材料的后续问题\n\n始终用被问问题的相同语言回答。在解释中要有教学性、清晰和鼓励性。';

  @override
  String get questionLabel => '问题';

  @override
  String get optionsLabel => '选项';

  @override
  String get explanationLabel => '解释（可选）';

  @override
  String get studentComment => '学生评论';

  @override
  String get aiAssistantTitle => 'AI学习助手';

  @override
  String get questionContext => '问题背景';

  @override
  String get aiAssistant => 'AI助手';

  @override
  String get aiThinking => 'AI正在思考...';

  @override
  String get askAIHint => '询问关于这个主题的问题...';

  @override
  String get aiPlaceholderResponse => '这是一个占位符响应。在实际实现中，这将连接到AI服务，提供有关问题的有用解释。';

  @override
  String get aiErrorResponse => '抱歉，处理您的问题时出现错误。请重试。';

  @override
  String get configureApiKeyMessage => '请在设置中配置您的AI API密钥。';

  @override
  String get errorLabel => '错误：';

  @override
  String get noResponseReceived => '未收到响应';

  @override
  String get invalidApiKeyError => '无效的API密钥。请在设置中检查您的OpenAI API密钥。';

  @override
  String get rateLimitError => '超出速率限制。请稍后重试。';

  @override
  String get modelNotFoundError => '未找到模型。请检查您的API访问权限。';

  @override
  String get unknownError => '未知错误';

  @override
  String get networkError => '网络错误：无法连接到OpenAI。请检查您的网络连接。';

  @override
  String get openaiApiKeyNotConfigured => 'OpenAI API密钥未配置';

  @override
  String get geminiApiKeyNotConfigured => 'Gemini API密钥未配置';

  @override
  String get geminiApiKeyLabel => 'Gemini API密钥';

  @override
  String get geminiApiKeyHint => '输入您的Gemini API密钥';

  @override
  String get geminiApiKeyDescription => 'Gemini AI功能所需。您的密钥会安全存储。';

  @override
  String get getGeminiApiKeyTooltip => '从Google AI Studio获取API密钥';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'AI学习助手至少需要一个API密钥（OpenAI或Gemini）。请输入API密钥或禁用AI助手。';

  @override
  String get minutesAbbreviation => '分钟';

  @override
  String get aiButtonTooltip => 'AI学习助手';

  @override
  String get aiButtonText => 'AI';

  @override
  String get aiAssistantSettingsTitle => 'AI学习助手（预览）';

  @override
  String get aiAssistantSettingsDescription => '启用或禁用问题的AI学习助手';

  @override
  String get openaiApiKeyLabel => 'OpenAI API密钥';

  @override
  String get openaiApiKeyHint => '输入您的OpenAI API密钥（sk-...）';

  @override
  String get openaiApiKeyDescription => '用于与OpenAI集成。您的OpenAI密钥会安全存储。';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'AI学习助手需要OpenAI API密钥。请输入您的API密钥或禁用AI助手。';

  @override
  String get getApiKeyTooltip => '从OpenAI获取API密钥';

  @override
  String get deleteAction => '删除';

  @override
  String get explanationHint => '输入正确答案的解释';

  @override
  String get explanationTitle => '解释';

  @override
  String get imageLabel => '图片';

  @override
  String get changeImage => '更换图片';

  @override
  String get removeImage => '移除图片';

  @override
  String get addImageTap => '点击添加图片';

  @override
  String get imageFormats => '格式：JPG、PNG、GIF';

  @override
  String get imageLoadError => '图片加载错误';

  @override
  String imagePickError(String error) {
    return '图片加载错误：$error';
  }

  @override
  String get tapToZoom => '点击放大';

  @override
  String get trueLabel => '正确';

  @override
  String get falseLabel => '错误';

  @override
  String get addQuestion => '添加问题';

  @override
  String get editQuestion => '编辑问题';

  @override
  String get questionText => '问题文本';

  @override
  String get questionType => '问题类型';

  @override
  String get addOption => '添加选项';

  @override
  String get optionLabel => '选项';

  @override
  String get questionTextRequired => '问题文本是必需的';

  @override
  String get atLeastOneOptionRequired => '至少一个选项必须有文本';

  @override
  String get atLeastOneCorrectAnswerRequired => '至少必须选择一个正确答案';

  @override
  String get onlyOneCorrectAnswerAllowed => '此问题类型只允许一个正确答案';

  @override
  String get removeOption => '移除选项';

  @override
  String get selectCorrectAnswer => '选择正确答案';

  @override
  String get selectCorrectAnswers => '选择正确答案';

  @override
  String emptyOptionsError(String optionNumbers) {
    return '选项$optionNumbers为空。请为它们添加文本或删除它们。';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return '选项$optionNumber为空。请为其添加文本或删除它。';
  }

  @override
  String get optionEmptyError => '此选项不能为空';

  @override
  String get hasImage => '图片';

  @override
  String get hasExplanation => '解释';

  @override
  String errorLoadingSettings(String error) {
    return '加载设置时出错：$error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return '无法打开$url';
  }

  @override
  String get loadingAiServices => '正在加载AI服务...';

  @override
  String usingAiService(String serviceName) {
    return '使用：$serviceName';
  }

  @override
  String get aiServiceLabel => 'AI服务：';

  @override
  String get importQuestionsTitle => '导入问题';

  @override
  String importQuestionsMessage(int count, String fileName) {
    return '在\"$fileName\"中找到$count个问题。您想将它们导入到哪里？';
  }

  @override
  String get importQuestionsPositionQuestion => '您想将这些问题添加到哪里？';

  @override
  String get importAtBeginning => '开头';

  @override
  String get importAtEnd => '结尾';

  @override
  String questionsImportedSuccess(int count) {
    return '成功导入$count个问题';
  }

  @override
  String get importQuestionsTooltip => '从另一个测验文件导入问题';

  @override
  String get dragDropHintText => '您也可以将.quiz文件拖拽到这里导入问题';

  @override
  String get randomizeAnswersTitle => '随机化答案选项';

  @override
  String get randomizeAnswersDescription => '在测验执行期间打乱答案选项的顺序';

  @override
  String get showCorrectAnswerCountTitle => '显示正确答案数量';

  @override
  String get showCorrectAnswerCountDescription => '在多选题中显示正确答案的数量';

  @override
  String correctAnswersCount(int count) {
    return '选择$count个正确答案';
  }

  @override
  String get correctSelectedLabel => '正确';

  @override
  String get correctMissedLabel => '正确';

  @override
  String get incorrectSelectedLabel => '错误';

  @override
  String get generateQuestionsWithAI => '使用AI生成问题';

  @override
  String get aiGenerateDialogTitle => '使用AI生成问题';

  @override
  String get aiQuestionCountLabel => '问题数量（可选）';

  @override
  String get aiQuestionCountHint => '留空让AI决定';

  @override
  String get aiQuestionCountValidation => '必须是1到50之间的数字';

  @override
  String get aiQuestionTypeLabel => '问题类型';

  @override
  String get aiQuestionTypeRandom => '随机（混合）';

  @override
  String get aiLanguageLabel => '问题语言';

  @override
  String get aiContentLabel => '生成问题的内容';

  @override
  String aiWordCount(int current, int max) {
    return '$current / $max 词';
  }

  @override
  String get aiContentHint => '输入您想生成问题的文本、主题或内容...';

  @override
  String get aiContentHelperText => 'AI将基于此内容创建问题';

  @override
  String aiWordLimitError(int max) {
    return '您已超过$max词的限制';
  }

  @override
  String get aiContentRequiredError => '您必须提供内容来生成问题';

  @override
  String aiContentLimitError(int max) {
    return '内容超过$max词限制';
  }

  @override
  String get aiMinWordsError => '至少提供10个词以生成高质量问题';

  @override
  String get aiInfoTitle => '信息';

  @override
  String get aiInfoDescription =>
      '• AI将分析内容并生成相关问题\n• 您可以包含文本、定义、解释或任何教育材料\n• 问题将包括答案选项和解释\n• 该过程可能需要几秒钟';

  @override
  String get aiGenerateButton => '生成问题';

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
  String get aiServicesLoading => '正在加载AI服务...';

  @override
  String get aiServicesNotConfigured => '未配置AI服务';

  @override
  String get aiGeneratedQuestions => 'AI生成';

  @override
  String get aiApiKeyRequired => '请在设置中配置至少一个AI API密钥以使用AI生成。';

  @override
  String get aiGenerationFailed => '无法生成问题。请尝试不同的内容。';

  @override
  String aiGenerationError(String error) {
    return '生成问题时出错：$error';
  }

  @override
  String get noQuestionsInFile => '导入的文件中未找到问题';

  @override
  String get couldNotAccessFile => '无法访问所选文件';

  @override
  String get defaultOutputFileName => 'output-file.quiz';

  @override
  String aiServiceLimitsWithChars(int words, int chars) {
    return '限制：$words词或$chars字符';
  }

  @override
  String aiServiceLimitsWordsOnly(int words) {
    return '限制：$words词';
  }

  @override
  String get aiAssistantDisabled => 'AI助手已禁用';

  @override
  String get enableAiAssistant => 'AI助手已禁用。请在设置中启用它以使用AI功能。';

  @override
  String aiMinWordsRequired(int minWords) {
    return '需要至少$minWords个单词';
  }

  @override
  String aiWordsReadyToGenerate(int wordCount) {
    return '$wordCount个单词 ✓ 准备生成';
  }

  @override
  String aiWordsProgress(int currentWords, int minWords, int moreNeeded) {
    return '$currentWords/$minWords个单词（还需要$moreNeeded个）';
  }

  @override
  String aiValidationMinWords(int minWords, int moreNeeded) {
    return '需要至少$minWords个单词（还需要$moreNeeded个）';
  }

  @override
  String get enableQuestion => '启用问题';

  @override
  String get disableQuestion => '禁用问题';

  @override
  String get questionDisabled => '已禁用';

  @override
  String get noEnabledQuestionsError => '没有启用的问题可以运行测验';

  @override
  String get evaluateWithAI => '用AI评估';

  @override
  String get aiEvaluation => 'AI评估';

  @override
  String aiEvaluationError(String error) {
    return '评估回答时出错：$error';
  }

  @override
  String get aiEvaluationPromptSystemRole =>
      '您是一位专家教师，正在评估学生对论述题的回答。您的任务是提供详细和建设性的评估。请用中文回答。';

  @override
  String get aiEvaluationPromptQuestion => '题目：';

  @override
  String get aiEvaluationPromptStudentAnswer => '学生答案：';

  @override
  String get aiEvaluationPromptCriteria => '评估标准（基于教师解释）：';

  @override
  String get aiEvaluationPromptSpecificInstructions =>
      '具体指示：\n- 评估学生回答与既定标准的契合程度\n- 分析回答中的综合程度和结构\n- 识别根据标准是否遗漏了重要内容\n- 考虑分析的深度和准确性';

  @override
  String get aiEvaluationPromptGeneralInstructions =>
      '一般指示：\n- 由于没有建立具体标准，请基于一般学术标准评估回答\n- 考虑回答的清晰度、连贯性和结构\n- 评估回答是否展示了对主题的理解\n- 分析分析的深度和论证的质量';

  @override
  String get aiEvaluationPromptResponseFormat =>
      '回答格式：\n1. 评分：[X/10] - 简要说明评分理由\n2. 优点：提及回答的积极方面\n3. 改进领域：指出可以改进的方面\n4. 具体评论：提供详细和建设性的反馈\n5. 建议：提供具体的改进建议\n\n在评估中要有建设性、具体性和教育性。目标是帮助学生学习和改进。用第二人称称呼他们，使用专业友好的语调。';

  @override
  String get raffleTitle => '抽奖';

  @override
  String get raffleTooltip => '打开抽奖屏幕';

  @override
  String get participantListTitle => '参与者列表';

  @override
  String get participantListHint => '输入用换行分隔的姓名';

  @override
  String get participantListPlaceholder => '在此输入参与者姓名...\n每行一个姓名';

  @override
  String get clearList => '清空列表';

  @override
  String get participants => '参与者';

  @override
  String get noParticipants => '没有参与者';

  @override
  String get addParticipantsHint => '添加参与者以开始抽奖';

  @override
  String get activeParticipants => '活跃参与者';

  @override
  String get alreadySelected => '已选中';

  @override
  String totalParticipants(int count) {
    return '总参与者';
  }

  @override
  String activeVsWinners(int active, int winners) {
    return '$active名活跃，$winners名获奖者';
  }

  @override
  String get startRaffle => '开始抽奖';

  @override
  String get raffling => '抽奖中...';

  @override
  String get selectingWinner => '选择获奖者...';

  @override
  String get allParticipantsSelected => '所有参与者已被选中';

  @override
  String get addParticipantsToStart => '添加参与者以开始抽奖';

  @override
  String participantsReadyCount(int count) {
    return '$count名参与者准备抽奖';
  }

  @override
  String get resetWinners => '重置获奖者';

  @override
  String get resetWinnersConfirmTitle => '重置获奖者？';

  @override
  String get resetWinnersConfirmMessage => '这将把所有获奖者重新放回活跃参与者列表。';

  @override
  String get resetRaffleTitle => '重置抽奖？';

  @override
  String get resetRaffleConfirmMessage => '这将重置所有获奖者和活跃参与者。';

  @override
  String get reset => '重置';

  @override
  String get viewWinners => '查看获奖者';

  @override
  String get congratulations => '恭喜！';

  @override
  String positionLabel(int position) {
    return '第$position名';
  }

  @override
  String remainingParticipants(int count) {
    return '剩余参与者：$count名';
  }

  @override
  String get continueRaffle => '继续抽奖';

  @override
  String get finishRaffle => '结束抽奖';

  @override
  String get winnersTitle => '获奖者';

  @override
  String get shareResults => '分享结果';

  @override
  String get noWinnersYet => '暂无获奖者';

  @override
  String get performRaffleToSeeWinners => '进行抽奖以查看获奖者';

  @override
  String get goToRaffle => '前往抽奖';

  @override
  String get raffleCompleted => '抽奖完成！';

  @override
  String winnersSelectedCount(int count) {
    return '已选出$count名获奖者';
  }

  @override
  String get newRaffle => '新抽奖';

  @override
  String get shareResultsTitle => '抽奖结果';

  @override
  String get raffleResultsLabel => '抽奖结果：';

  @override
  String get close => '关闭';

  @override
  String get share => '分享';

  @override
  String get shareNotImplemented => '分享功能尚未实现';

  @override
  String get firstPlace => '第一名';

  @override
  String get secondPlace => '第二名';

  @override
  String get thirdPlace => '第三名';

  @override
  String nthPlace(int position) {
    return '第$position名';
  }

  @override
  String placeLabel(String position) {
    return '名次';
  }

  @override
  String get raffleResultsHeader => '抽奖结果 - null名获奖者';

  @override
  String totalWinners(int count) {
    return '总获奖者：$count名';
  }

  @override
  String get noWinnersToShare => '没有获奖者可分享';

  @override
  String get shareSuccess => '结果复制成功';
}
