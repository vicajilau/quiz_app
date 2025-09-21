// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get titleAppBar => 'Quiz - Simulador de Exames';

  @override
  String get create => 'Criar';

  @override
  String get load => 'Carregar';

  @override
  String fileLoaded(String filePath) {
    return 'Arquivo carregado: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'Arquivo salvo: $filePath';
  }

  @override
  String get dropFileHere =>
      'Clique aqui ou arraste um arquivo .quiz para a tela';

  @override
  String get errorInvalidFile =>
      'Erro: Arquivo inválido. Deve ser um arquivo .quiz.';

  @override
  String errorLoadingFile(String error) {
    return 'Erro ao carregar o arquivo Quiz: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Erro ao exportar o arquivo: $error';
  }

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Salvar';

  @override
  String get confirmDeleteTitle => 'Confirmar Exclusão';

  @override
  String confirmDeleteMessage(String processName) {
    return 'Tem certeza de que deseja excluir o processo `$processName`?';
  }

  @override
  String get deleteButton => 'Excluir';

  @override
  String get confirmExitTitle => 'Confirmar Saída';

  @override
  String get confirmExitMessage => 'Tem certeza de que deseja sair sem salvar?';

  @override
  String get exitButton => 'Sair';

  @override
  String get saveDialogTitle => 'Selecione um arquivo de saída:';

  @override
  String get createQuizFileTitle => 'Criar Arquivo Quiz';

  @override
  String get fileNameLabel => 'Nome do Arquivo';

  @override
  String get fileDescriptionLabel => 'Descrição do Arquivo';

  @override
  String get createButton => 'Criar';

  @override
  String get fileNameRequiredError => 'O nome do arquivo é obrigatório.';

  @override
  String get fileDescriptionRequiredError =>
      'A descrição do arquivo é obrigatória.';

  @override
  String get versionLabel => 'Versão';

  @override
  String get authorLabel => 'Autor';

  @override
  String get authorRequiredError => 'O autor é obrigatório.';

  @override
  String get requiredFieldsError =>
      'Todos os campos obrigatórios devem ser preenchidos.';

  @override
  String get requestFileNameTitle => 'Digite o nome do arquivo Quiz';

  @override
  String get fileNameHint => 'Nome do arquivo';

  @override
  String get emptyFileNameMessage => 'O nome do arquivo não pode estar vazio.';

  @override
  String get acceptButton => 'Aceitar';

  @override
  String get saveTooltip => 'Salvar o arquivo';

  @override
  String get saveDisabledTooltip => 'Nenhuma alteração para salvar';

  @override
  String get executeTooltip => 'Executar o exame';

  @override
  String get addTooltip => 'Adicionar uma nova pergunta';

  @override
  String get backSemanticLabel => 'Botão voltar';

  @override
  String get createFileTooltip => 'Criar um novo arquivo Quiz';

  @override
  String get loadFileTooltip => 'Carregar um arquivo Quiz existente';

  @override
  String questionNumber(int number) {
    return 'Pergunta $number';
  }

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Próximo';

  @override
  String get finish => 'Finalizar';

  @override
  String get finishQuiz => 'Finalizar Quiz';

  @override
  String get finishQuizConfirmation =>
      'Tem certeza de que deseja finalizar o quiz? Você não poderá mais alterar suas respostas depois.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get abandonQuiz => 'Abandonar Quiz';

  @override
  String get abandonQuizConfirmation =>
      'Tem certeza de que deseja abandonar o quiz? Todo o progresso será perdido.';

  @override
  String get abandon => 'Abandonar';

  @override
  String get quizCompleted => 'Quiz Concluído!';

  @override
  String score(String score) {
    return 'Pontuação: $score%';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$correct de $total respostas corretas';
  }

  @override
  String get retry => 'Repetir';

  @override
  String get goBack => 'Finalizar';

  @override
  String get retryFailedQuestions => 'Repetir Falhadas';

  @override
  String question(String question) {
    return 'Pergunta: $question';
  }

  @override
  String get selectQuestionCountTitle => 'Selecionar Número de Perguntas';

  @override
  String get selectQuestionCountMessage =>
      'Quantas perguntas você gostaria de responder neste quiz?';

  @override
  String allQuestions(int count) {
    return 'Todas as perguntas ($count)';
  }

  @override
  String get startQuiz => 'Iniciar Quiz';

  @override
  String get customNumberLabel => 'Ou digite um número personalizado:';

  @override
  String get numberInputLabel => 'Número de perguntas';

  @override
  String customNumberHelper(int total) {
    return 'Digite qualquer número (máx $total). Se maior, as perguntas se repetirão.';
  }

  @override
  String get errorInvalidNumber => 'Por favor, digite um número válido';

  @override
  String get errorNumberMustBePositive => 'O número deve ser maior que 0';

  @override
  String get questionOrderConfigTitle => 'Configuração da Ordem das Perguntas';

  @override
  String get questionOrderConfigDescription =>
      'Selecione a ordem na qual deseja que as perguntas apareçam durante o exame:';

  @override
  String get questionOrderAscending => 'Ordem Crescente';

  @override
  String get questionOrderAscendingDesc =>
      'As perguntas aparecerão em ordem de 1 ao final';

  @override
  String get questionOrderDescending => 'Ordem Decrescente';

  @override
  String get questionOrderDescendingDesc =>
      'As perguntas aparecerão do final a 1';

  @override
  String get questionOrderRandom => 'Aleatório';

  @override
  String get questionOrderRandomDesc =>
      'As perguntas aparecerão em ordem aleatória';

  @override
  String get questionOrderConfigTooltip =>
      'Configuração da ordem das perguntas';

  @override
  String get save => 'Salvar';

  @override
  String get examTimeLimitTitle => 'Limite de Tempo do Exame';

  @override
  String get examTimeLimitDescription =>
      'Defina um limite de tempo para o exame. Quando habilitado, um cronômetro regressivo será exibido durante o quiz.';

  @override
  String get enableTimeLimit => 'Habilitar limite de tempo';

  @override
  String get timeLimitMinutes => 'Limite de tempo (minutos)';

  @override
  String get examTimeExpiredTitle => 'Tempo Esgotado!';

  @override
  String get examTimeExpiredMessage =>
      'O tempo do exame expirou. Suas respostas foram automaticamente enviadas.';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => 'Múltipla Escolha';

  @override
  String get questionTypeSingleChoice => 'Escolha Única';

  @override
  String get questionTypeTrueFalse => 'Verdadeiro/Falso';

  @override
  String get questionTypeEssay => 'Ensaio';

  @override
  String get questionTypeUnknown => 'Desconhecido';

  @override
  String optionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opções',
      one: '1 opção',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip =>
      'Número de opções de resposta para esta pergunta';

  @override
  String get imageTooltip => 'Esta pergunta tem uma imagem associada';

  @override
  String get explanationTooltip => 'Esta pergunta tem uma explicação';

  @override
  String get aiPrompt =>
      'Você é um tutor experiente e amigável especializado em ajudar estudantes a compreender melhor questões de exame e tópicos relacionados. Seu objetivo é facilitar o aprendizado profundo e a compreensão conceitual.\n\nVocê pode ajudar com:\n- Explicar conceitos relacionados à pergunta\n- Esclarecer dúvidas sobre opções de resposta\n- Fornecer contexto adicional sobre o tópico\n- Sugerir recursos de estudo complementares\n- Explicar por que certas respostas estão corretas ou incorretas\n- Relacionar o tópico a outros conceitos importantes\n- Responder perguntas de acompanhamento sobre o material\n\nSempre responda na mesma língua em que for questionado. Seja pedagógico, claro e motivador em suas explicações.';

  @override
  String get questionLabel => 'Pergunta';

  @override
  String get optionsLabel => 'Opções';

  @override
  String get explanationLabel => 'Explicação (opcional)';

  @override
  String get studentComment => 'Comentário do estudante';

  @override
  String get aiAssistantTitle => 'Assistente de Estudo IA';

  @override
  String get questionContext => 'Contexto da Pergunta';

  @override
  String get aiAssistant => 'Assistente IA';

  @override
  String get aiThinking => 'IA está pensando...';

  @override
  String get askAIHint => 'Faça sua pergunta sobre este tópico...';

  @override
  String get aiPlaceholderResponse =>
      'Esta é uma resposta placeholder. Em uma implementação real, isso se conectaria a um serviço IA para fornecer explicações úteis sobre a pergunta.';

  @override
  String get aiErrorResponse =>
      'Desculpe, houve um erro ao processar sua pergunta. Tente novamente.';

  @override
  String get configureApiKeyMessage =>
      'Por favor, configure sua Chave API IA nas Configurações.';

  @override
  String get errorLabel => 'Erro:';

  @override
  String get noResponseReceived => 'Nenhuma resposta recebida';

  @override
  String get invalidApiKeyError =>
      'Chave API inválida. Verifique sua Chave API OpenAI nas configurações.';

  @override
  String get rateLimitError =>
      'Limite de taxa excedido. Tente novamente mais tarde.';

  @override
  String get modelNotFoundError =>
      'Modelo não encontrado. Verifique seu acesso à API.';

  @override
  String get unknownError => 'Erro desconhecido';

  @override
  String get networkError =>
      'Erro de rede: Não foi possível conectar ao OpenAI. Verifique sua conexão com a internet.';

  @override
  String get openaiApiKeyNotConfigured => 'Chave API OpenAI não configurada';

  @override
  String get geminiApiKeyNotConfigured => 'Chave API Gemini não configurada';

  @override
  String get geminiApiKeyLabel => 'Chave API Gemini';

  @override
  String get geminiApiKeyHint => 'Digite sua Chave API Gemini';

  @override
  String get geminiApiKeyDescription =>
      'Necessário para funcionalidade IA Gemini. Sua chave é armazenada com segurança.';

  @override
  String get getGeminiApiKeyTooltip => 'Obter Chave API do Google AI Studio';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'Assistente de Estudo IA requer pelo menos uma Chave API (OpenAI ou Gemini). Digite uma chave API ou desabilite o Assistente IA.';

  @override
  String get minutesAbbreviation => 'min';

  @override
  String get aiButtonTooltip => 'Assistente de Estudo IA';

  @override
  String get aiButtonText => 'IA';

  @override
  String get aiAssistantSettingsTitle => 'Assistente de Estudo IA (Prévia)';

  @override
  String get aiAssistantSettingsDescription =>
      'Habilitar ou desabilitar o assistente de estudo IA para perguntas';

  @override
  String get openaiApiKeyLabel => 'Chave API OpenAI';

  @override
  String get openaiApiKeyHint => 'Digite sua Chave API OpenAI (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'Necessário para integração com OpenAI. Sua chave OpenAI é armazenada com segurança.';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'Assistente de Estudo IA requer uma Chave API OpenAI. Digite sua chave API ou desabilite o Assistente IA.';

  @override
  String get getApiKeyTooltip => 'Obter Chave API do OpenAI';

  @override
  String get deleteAction => 'Excluir';

  @override
  String get explanationHint =>
      'Digite uma explicação para a(s) resposta(s) correta(s)';

  @override
  String get explanationTitle => 'Explicação';

  @override
  String get imageLabel => 'Imagem';

  @override
  String get changeImage => 'Alterar imagem';

  @override
  String get removeImage => 'Remover imagem';

  @override
  String get addImageTap => 'Toque para adicionar imagem';

  @override
  String get imageFormats => 'Formatos: JPG, PNG, GIF';

  @override
  String get imageLoadError => 'Erro ao carregar imagem';

  @override
  String imagePickError(String error) {
    return 'Erro ao carregar imagem: $error';
  }

  @override
  String get tapToZoom => 'Toque para ampliar';

  @override
  String get trueLabel => 'Verdadeiro';

  @override
  String get falseLabel => 'Falso';

  @override
  String get addQuestion => 'Adicionar Pergunta';

  @override
  String get editQuestion => 'Editar Pergunta';

  @override
  String get questionText => 'Texto da Pergunta';

  @override
  String get questionType => 'Tipo de Pergunta';

  @override
  String get addOption => 'Adicionar Opção';

  @override
  String get optionLabel => 'Opção';

  @override
  String get questionTextRequired => 'Texto da pergunta é obrigatório';

  @override
  String get atLeastOneOptionRequired => 'Pelo menos uma opção deve ter texto';

  @override
  String get atLeastOneCorrectAnswerRequired =>
      'Pelo menos uma resposta correta deve ser selecionada';

  @override
  String get onlyOneCorrectAnswerAllowed =>
      'Apenas uma resposta correta é permitida para este tipo de pergunta';

  @override
  String get removeOption => 'Remover opção';

  @override
  String get selectCorrectAnswer => 'Selecionar resposta correta';

  @override
  String get selectCorrectAnswers => 'Selecionar respostas corretas';

  @override
  String emptyOptionsError(String optionNumbers) {
    return 'Opções $optionNumbers estão vazias. Adicione texto a elas ou remova-as.';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return 'Opção $optionNumber está vazia. Adicione texto a ela ou remova-a.';
  }

  @override
  String get optionEmptyError => 'Esta opção não pode estar vazia';

  @override
  String get hasImage => 'Imagem';

  @override
  String get hasExplanation => 'Explicação';

  @override
  String errorLoadingSettings(String error) {
    return 'Erro ao carregar configurações: $error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return 'Não foi possível abrir $url';
  }

  @override
  String get loadingAiServices => 'Carregando serviços IA...';

  @override
  String usingAiService(String serviceName) {
    return 'Usando: $serviceName';
  }

  @override
  String get aiServiceLabel => 'Serviço IA:';

  @override
  String get importQuestionsTitle => 'Importar Perguntas';

  @override
  String importQuestionsMessage(int count, String fileName) {
    return 'Encontradas $count perguntas em \"$fileName\". Onde você gostaria de importá-las?';
  }

  @override
  String get importQuestionsPositionQuestion =>
      'Onde você gostaria de adicionar essas perguntas?';

  @override
  String get importAtBeginning => 'No Início';

  @override
  String get importAtEnd => 'No Final';

  @override
  String questionsImportedSuccess(int count) {
    return 'Importadas com sucesso $count perguntas';
  }

  @override
  String get importQuestionsTooltip =>
      'Importar perguntas de outro arquivo quiz';

  @override
  String get dragDropHintText =>
      'Você também pode arrastar e soltar arquivos .quiz aqui para importar perguntas';

  @override
  String get randomizeAnswersTitle => 'Aleatorizar Opções de Resposta';

  @override
  String get randomizeAnswersDescription =>
      'Embaralhar a ordem das opções de resposta durante a execução do quiz';

  @override
  String get showCorrectAnswerCountTitle =>
      'Mostrar Número de Respostas Corretas';

  @override
  String get showCorrectAnswerCountDescription =>
      'Exibir o número de respostas corretas em perguntas de múltipla escolha';

  @override
  String correctAnswersCount(int count) {
    return 'Selecione $count respostas corretas';
  }

  @override
  String get correctSelectedLabel => 'Correto';

  @override
  String get correctMissedLabel => 'Correto';

  @override
  String get incorrectSelectedLabel => 'Incorreto';

  @override
  String get generateQuestionsWithAI => 'Gerar perguntas com IA';

  @override
  String get aiGenerateDialogTitle => 'Gerar Perguntas com IA';

  @override
  String get aiQuestionCountLabel => 'Número de Perguntas (Opcional)';

  @override
  String get aiQuestionCountHint => 'Deixe vazio para a IA decidir';

  @override
  String get aiQuestionCountValidation => 'Deve ser um número entre 1 e 50';

  @override
  String get aiQuestionTypeLabel => 'Tipo de Pergunta';

  @override
  String get aiQuestionTypeRandom => 'Aleatório (Misto)';

  @override
  String get aiLanguageLabel => 'Idioma das Perguntas';

  @override
  String get aiContentLabel => 'Conteúdo para gerar perguntas';

  @override
  String aiWordCount(int current, int max) {
    return '$current / $max palavras';
  }

  @override
  String get aiContentHint =>
      'Digite o texto, tópico, ou conteúdo a partir do qual deseja gerar perguntas...';

  @override
  String get aiContentHelperText =>
      'IA criará perguntas baseadas neste conteúdo';

  @override
  String aiWordLimitError(int max) {
    return 'Você excedeu o limite de $max palavras';
  }

  @override
  String get aiContentRequiredError =>
      'Você deve fornecer conteúdo para gerar perguntas';

  @override
  String aiContentLimitError(int max) {
    return 'Conteúdo excede o limite de $max palavras';
  }

  @override
  String get aiMinWordsError =>
      'Forneça pelo menos 10 palavras para gerar perguntas de qualidade';

  @override
  String get aiInfoTitle => 'Informação';

  @override
  String get aiInfoDescription =>
      '• IA analisará o conteúdo e gerará perguntas relevantes\n• Você pode incluir texto, definições, explicações, ou qualquer material educativo\n• Perguntas incluirão opções de resposta e explicações\n• O processo pode levar alguns segundos';

  @override
  String get aiGenerateButton => 'Gerar Perguntas';

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
  String get aiServicesLoading => 'Carregando serviços IA...';

  @override
  String get aiServicesNotConfigured => 'Nenhum serviço IA configurado';

  @override
  String get aiGeneratedQuestions => 'Gerado por IA';

  @override
  String get aiApiKeyRequired =>
      'Configure pelo menos uma chave API IA nas Configurações para usar geração IA.';

  @override
  String get aiGenerationFailed =>
      'Não foi possível gerar perguntas. Tente com conteúdo diferente.';

  @override
  String aiGenerationError(String error) {
    return 'Erro ao gerar perguntas: $error';
  }

  @override
  String get noQuestionsInFile =>
      'Nenhuma pergunta encontrada no arquivo importado';

  @override
  String get couldNotAccessFile =>
      'Não foi possível acessar o arquivo selecionado';

  @override
  String get defaultOutputFileName => 'arquivo-saida.quiz';

  @override
  String aiServiceLimitsWithChars(int words, int chars) {
    return 'Limite: $words palavras ou $chars caracteres';
  }

  @override
  String aiServiceLimitsWordsOnly(int words) {
    return 'Limite: $words palavras';
  }

  @override
  String get aiAssistantDisabled => 'Assistente IA Desabilitado';

  @override
  String get enableAiAssistant =>
      'O assistente de IA está desabilitado. Por favor, habilite-o nas configurações para usar recursos de IA.';

  @override
  String aiMinWordsRequired(int minWords) {
    return 'Mínimo de $minWords palavras necessárias';
  }

  @override
  String aiWordsReadyToGenerate(int wordCount) {
    return '$wordCount palavras ✓ Pronto para gerar';
  }

  @override
  String aiWordsProgress(int currentWords, int minWords, int moreNeeded) {
    return '$currentWords/$minWords palavras ($moreNeeded mais necessárias)';
  }

  @override
  String aiValidationMinWords(int minWords, int moreNeeded) {
    return 'Mínimo de $minWords palavras necessárias ($moreNeeded mais necessárias)';
  }

  @override
  String get enableQuestion => 'Ativar pergunta';

  @override
  String get disableQuestion => 'Desativar pergunta';

  @override
  String get questionDisabled => 'Desativada';

  @override
  String get noEnabledQuestionsError =>
      'Nenhuma pergunta ativada disponível para executar o quiz';

  @override
  String get evaluateWithAI => 'Avaliar com IA';

  @override
  String get aiEvaluation => 'Avaliação IA';

  @override
  String aiEvaluationError(String error) {
    return 'Erro ao avaliar a resposta: $error';
  }

  @override
  String get aiEvaluationPromptSystemRole =>
      'Você é um professor especialista avaliando a resposta de um estudante a uma questão dissertativa. Sua tarefa é fornecer uma avaliação detalhada e construtiva. Responda em português.';

  @override
  String get aiEvaluationPromptQuestion => 'PERGUNTA:';

  @override
  String get aiEvaluationPromptStudentAnswer => 'RESPOSTA DO ESTUDANTE:';

  @override
  String get aiEvaluationPromptCriteria =>
      'CRITÉRIOS DE AVALIAÇÃO (baseados na explicação do professor):';

  @override
  String get aiEvaluationPromptSpecificInstructions =>
      'INSTRUÇÕES ESPECÍFICAS:\n- Avalie quão bem a resposta do estudante se alinha com os critérios estabelecidos\n- Analise o grau de síntese e estrutura na resposta\n- Identifique se algo importante foi deixado de fora segundo os critérios\n- Considere a profundidade e precisão da análise';

  @override
  String get aiEvaluationPromptGeneralInstructions =>
      'INSTRUÇÕES GERAIS:\n- Como não há critérios específicos estabelecidos, avalie a resposta baseando-se em padrões acadêmicos gerais\n- Considere clareza, coerência e estrutura da resposta\n- Avalie se a resposta demonstra compreensão do tópico\n- Analise a profundidade da análise e qualidade dos argumentos';

  @override
  String get aiEvaluationPromptResponseFormat =>
      'FORMATO DA RESPOSTA:\n1. NOTA: [X/10] - Justifique brevemente a nota\n2. PONTOS FORTES: Mencione os aspectos positivos da resposta\n3. ÁREAS DE MELHORIA: Aponte aspectos que poderiam ser melhorados\n4. COMENTÁRIOS ESPECÍFICOS: Forneça feedback detalhado e construtivo\n5. SUGERÊNCIAS: Ofereça recomendações específicas para melhoria\n\nSeja construtivo, específico e educativo em sua avaliação. O objetivo é ajudar o estudante a aprender e melhorar. Dirija-se a ele em segunda pessoa e use um tom profissional e amigável.';

  @override
  String get raffleTitle => 'Sorteio';

  @override
  String get raffleTooltip => 'Sorteio';

  @override
  String get participantListTitle => 'Lista de participantes';

  @override
  String get participantListHint => 'Digite um nome por linha:';

  @override
  String get participantListPlaceholder =>
      'João Silva\nMaria Santos\nPedro Oliveira\n...';

  @override
  String get clearList => 'Limpar lista';

  @override
  String get participants => 'Participantes';

  @override
  String get noParticipants => 'Nenhum participante';

  @override
  String get addParticipantsHint => 'Adicione nomes na área de texto';

  @override
  String get activeParticipants => 'Participantes ativos';

  @override
  String get alreadySelected => 'Já selecionados';

  @override
  String totalParticipants(int count) {
    return 'Total: $count';
  }

  @override
  String activeVsWinners(int active, int winners) {
    return 'Ativos: $active | Vencedores: $winners';
  }

  @override
  String get startRaffle => 'Iniciar sorteio';

  @override
  String get raffling => 'Sorteando...';

  @override
  String get selectingWinner => 'Selecionando vencedor...';

  @override
  String get allParticipantsSelected =>
      'Todos os participantes já foram selecionados';

  @override
  String get addParticipantsToStart =>
      'Adicione participantes para iniciar o sorteio';

  @override
  String participantsReadyCount(int count) {
    return '$count participante(s) pronto(s) para o sorteio';
  }

  @override
  String get resetWinners => 'Resetar vencedores';

  @override
  String get resetWinnersConfirmTitle => 'Resetar vencedores';

  @override
  String get resetWinnersConfirmMessage =>
      'Tem certeza de que deseja resetar a lista de vencedores? Todos os participantes estarão disponíveis para o sorteio novamente.';

  @override
  String get resetRaffleTitle => 'Resetar sorteio';

  @override
  String get resetRaffleConfirmMessage =>
      'Tem certeza de que deseja resetar o sorteio? Todos os participantes e vencedores serão perdidos.';

  @override
  String get reset => 'Resetar';

  @override
  String get viewWinners => 'Ver vencedores';

  @override
  String get congratulations => '🎉 Parabéns! 🎉';

  @override
  String positionLabel(int position) {
    return 'Posição: $position°';
  }

  @override
  String remainingParticipants(int count) {
    return 'Participantes restantes: $count';
  }

  @override
  String get continueRaffle => 'Continuar sorteio';

  @override
  String get finishRaffle => 'Finalizar sorteio';

  @override
  String get winnersTitle => 'Vencedores do sorteio';

  @override
  String get shareResults => 'Compartilhar resultados';

  @override
  String get noWinnersYet => 'Ainda sem vencedores';

  @override
  String get performRaffleToSeeWinners =>
      'Realize um sorteio para ver os vencedores aqui';

  @override
  String get goToRaffle => 'Ir para sorteio';

  @override
  String get raffleCompleted => 'Sorteio concluído';

  @override
  String winnersSelectedCount(int count) {
    return '$count vencedor(es) selecionado(s)';
  }

  @override
  String get newRaffle => 'Novo sorteio';

  @override
  String get shareResultsTitle => 'Compartilhar resultados';

  @override
  String get raffleResultsLabel => 'Resultados do sorteio:';

  @override
  String get close => 'Fechar';

  @override
  String get share => 'Copiar';

  @override
  String get shareNotImplemented =>
      'Funcionalidade de compartilhamento não implementada';

  @override
  String get firstPlace => '1°';

  @override
  String get secondPlace => '2°';

  @override
  String get thirdPlace => '3°';

  @override
  String nthPlace(int position) {
    return '$position°';
  }

  @override
  String placeLabel(String position) {
    return '$position lugar';
  }

  @override
  String get raffleResultsHeader => '🏆 RESULTADOS DO SORTEIO 🏆';

  @override
  String totalWinners(int count) {
    return 'Total de vencedores: $count';
  }

  @override
  String get noWinnersToShare => 'Nenhum vencedor.';

  @override
  String get shareSuccess => 'Resultados copiados com sucesso';
}
