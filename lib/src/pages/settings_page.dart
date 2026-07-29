part of '../home_shell.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.themeMode,
    required this.locale,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.justOneApiToken,
    required this.onJustOneApiTokenChanged,
    required this.onDataImported,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final String justOneApiToken;
  final Future<void> Function(String) onJustOneApiTokenChanged;
  final VoidCallback onDataImported;

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return GuardianPageFrame(
      title: copy.t('设置', 'Settings'),
      subtitle: copy.t('按你习惯的方式来。', 'Set things up your way.'),
      child: Column(
        children: [
          _JustOneApiSettings(
            initialToken: justOneApiToken,
            onSaved: onJustOneApiTokenChanged,
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: copy.t('关于', 'About'),
            icon: Icons.info_outline,
            children: [
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.system_update_alt_outlined),
                  title: Text(
                    copy.t(
                      '当前版本 ${AppVersion.current}',
                      'Version ${AppVersion.current}',
                    ),
                  ),
                  subtitle: Text(
                    copy.t(
                      '仅在点击时直连 GitHub 检查，不会后台轮询或自动下载。',
                      'Checks GitHub only when tapped; no background polling or automatic downloads.',
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _checkVersion(context, copy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: copy.t('外观', 'Appearance'),
            icon: Icons.palette_outlined,
            children: [
              _SettingRow(
                title: copy.t('主题', 'Theme'),
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(copy.t('跟随系统', 'System')),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(copy.t('浅色', 'Light')),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(copy.t('深色', 'Dark')),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (value) => onThemeChanged(value.first),
                ),
              ),
              _SettingRow(
                title: copy.t('语言', 'Language'),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'zh', label: Text('中文')),
                    ButtonSegment(value: 'en', label: Text('English')),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (value) =>
                      onLocaleChanged(Locale(value.first)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _ModelSettings(),
          const SizedBox(height: 16),
          const _RuleSettings(),
          const SizedBox(height: 16),
          _SettingsSection(
            title: copy.t('隐私与外部请求', 'Privacy and external requests'),
            icon: Icons.shield_outlined,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(copy.t('商品信息', 'Product details')),
                subtitle: Text(
                  copy.t(
                    '补全淘宝或京东商品时，商品链接或 ID 和你的 JustOneAPI Token 会直达 JustOneAPI。',
                    'When enriching Taobao or JD items, the product link or ID and your JustOneAPI token go directly to JustOneAPI.',
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.auto_awesome_outlined),
                title: Text(copy.t('模型分析', 'Model analysis')),
                subtitle: Text(
                  copy.t(
                    '商品、价格、购买理由、分类标签、预算、命中规则、最多 5 条相关历史摘要和你确认的个人规律会直达你配置的模型服务。发送前可以核对并取消。',
                    'The item, price, reason, category, tags, budget, matched rules, up to five related-history summaries, and personal patterns you confirmed go directly to your configured model service. You can review and cancel before sending.',
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(copy.t('导出导入诊断', 'Export import diagnostics')),
                  subtitle: Text(
                    copy.t(
                      '只包含平台、失败阶段、错误类别和时间，不含链接、商品名、分享原文或密钥。',
                      'Contains only platform, failed stage, error category, and time—never links, item names, shared text, or keys.',
                    ),
                  ),
                  trailing: const Icon(Icons.download_outlined),
                  onTap: () async {
                    final saved = await const ImportDiagnosticExporter()
                        .export();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          saved
                              ? copy.t('诊断文件已保存。', 'Diagnostic file saved.')
                              : copy.t(
                                  '没有保存诊断文件。',
                                  'Diagnostic file was not saved.',
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.key_outlined),
                title: Text(copy.t('API Key 如何保存', 'How API keys are stored')),
                subtitle: Text(
                  copy.t(
                    'Android、iOS 和 Windows 使用系统安全存储；macOS 使用应用支持目录内权限为 0600 的本地文件。',
                    'Android, iOS, and Windows use platform secure storage. macOS uses a local file with 0600 permissions in Application Support.',
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.storage_outlined),
                title: Text(copy.t('业务数据与导出', 'App data and exports')),
                subtitle: Text(
                  copy.t(
                    '决策、预算和规则保存在本机数据库；设置保存在本机偏好。数据库和 JSON 导出没有额外加密，请妥善保管设备和备份文件。',
                    'Decisions, budgets, and rules are stored in a local database; settings use local preferences. The database and JSON exports are not additionally encrypted, so protect your device and backup files.',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: copy.t('数据', 'Data'),
            icon: Icons.lock_outline_rounded,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.cloud_off_outlined),
                title: Text(copy.t('只存在这台设备', 'Stored on this device')),
                subtitle: Text(
                  copy.t(
                    '本项目没有账号或中转服务器；外部请求范围见上方说明。',
                    'This project has no accounts or relay server; see the external request details above.',
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.file_download_outlined),
                  title: Text(copy.t('导出数据', 'Export data')),
                  subtitle: Text(
                    copy.t(
                      'API Key 不会放进导出文件。',
                      'Your API key is never included.',
                    ),
                  ),
                  onTap: () async {
                    final saved = await const DataExporter().export();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          saved
                              ? copy.t('数据已导出。', 'Data exported.')
                              : copy.t('已取消导出。', 'Export cancelled.'),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.file_upload_outlined),
                  title: Text(copy.t('导入数据', 'Import data')),
                  subtitle: Text(
                    copy.t(
                      '先预览，再选择合并或覆盖。API Key 不会导入。',
                      'Preview first, then merge or replace. API keys are never imported.',
                    ),
                  ),
                  onTap: () => _importData(context, copy),
                ),
              ),
              const Divider(),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_sweep_outlined),
                  title: Text(copy.t('清除决策和预算', 'Clear decisions and budget')),
                  onTap: () => _confirmClear(context, copy, clearConfig: false),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.key_off_outlined),
                  title: Text(copy.t('清除 API 配置', 'Clear API configuration')),
                  onTap: () => _confirmClear(context, copy, clearConfig: true),
                ),
              ),
              const Divider(),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    copy.t('清除全部本地数据', 'Clear all local data'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  subtitle: Text(
                    copy.t(
                      '包括记录、预算、规则、API 配置、偏好和提醒。',
                      'Includes history, budget, rules, API settings, preferences, and reminders.',
                    ),
                  ),
                  onTap: () => _confirmClearAll(context, copy),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _checkVersion(BuildContext context, GuardianCopy copy) async {
    try {
      final release = await const VersionChecker().check();
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            release.updateAvailable
                ? copy.t(
                    '发现新版本 ${release.latestVersion}',
                    'Version ${release.latestVersion} is available',
                  )
                : copy.t('已经是最新版', 'You are up to date'),
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (release.notes.isNotEmpty) SelectableText(release.notes),
                  if (release.notes.isNotEmpty) const SizedBox(height: 16),
                  Text(copy.t('下载页面', 'Download page')),
                  SelectableText(release.url.toString()),
                ],
              ),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(copy.t('关闭', 'Close')),
            ),
          ],
        ),
      );
    } on VersionCheckException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _importData(BuildContext context, GuardianCopy copy) async {
    try {
      final importer = DataImporter();
      final preview = await importer.pickAndPreview();
      if (preview == null || !context.mounted) return;

      var selectedMode = DataImportMode.merge;
      final mode = await showDialog<DataImportMode>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(copy.t('确认导入内容', 'Review import')),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.t(
                        '${preview.decisions.length} 条决策记录 · ${preview.rules.length} 条消费规则',
                        '${preview.decisions.length} decisions · ${preview.rules.length} rules',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      preview.monthlyBudget == null
                          ? copy.t('文件中没有月预算', 'No monthly budget in file')
                          : copy.t(
                              '月预算：¥${preview.monthlyBudget!.toStringAsFixed(0)}',
                              'Monthly budget: ¥${preview.monthlyBudget!.toStringAsFixed(0)}',
                            ),
                    ),
                    if (preview.decisionConflicts + preview.ruleConflicts > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          copy.t(
                            '${preview.decisionConflicts + preview.ruleConflicts} 条内容与本机 ID 重复。合并时会保留本机版本。',
                            '${preview.decisionConflicts + preview.ruleConflicts} items share IDs with local data. Merge keeps the local versions.',
                          ),
                        ),
                      ),
                    if (preview.containsModelConfiguration)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          copy.t(
                            '文件中的模型名称和地址不会自动改动。API Key 从不导入。',
                            'Model name and endpoint will not be changed. API keys are never imported.',
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    SegmentedButton<DataImportMode>(
                      segments: [
                        ButtonSegment(
                          value: DataImportMode.merge,
                          label: Text(copy.t('合并', 'Merge')),
                        ),
                        ButtonSegment(
                          value: DataImportMode.replace,
                          label: Text(copy.t('覆盖本机', 'Replace local')),
                        ),
                      ],
                      selected: {selectedMode},
                      onSelectionChanged: (selection) =>
                          setDialogState(() => selectedMode = selection.first),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedMode == DataImportMode.merge
                          ? copy.t(
                              '保留本机内容，只加入不重复的记录。本机已有预算不变。',
                              'Keep local data and add only new records. Your existing budget stays unchanged.',
                            )
                          : preview.containsRules
                          ? copy.t(
                              '删除本机决策、规则和预算，再写入这份文件。此操作无法撤销。',
                              'Delete local decisions, rules, and budget before importing this file. This cannot be undone.',
                            )
                          : copy.t(
                              '这是旧版备份：将替换决策和预算，但保留本机消费规则。此操作无法撤销。',
                              'This is an older backup: decisions and budget will be replaced, while local rules are kept. This cannot be undone.',
                            ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(copy.t('取消', 'Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, selectedMode),
                child: Text(copy.t('开始导入', 'Import')),
              ),
            ],
          ),
        ),
      );
      if (mode == null || !context.mounted) return;

      final result = await importer.apply(preview, mode);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.t(
              '已导入 ${result.importedDecisions} 条决策和 ${result.importedRules} 条规则'
                  '${result.skippedConflicts > 0 ? '，跳过 ${result.skippedConflicts} 条重复内容' : ''}。',
              'Imported ${result.importedDecisions} decisions and ${result.importedRules} rules'
                  '${result.skippedConflicts > 0 ? '; skipped ${result.skippedConflicts} duplicates' : ''}.',
            ),
          ),
        ),
      );
      onDataImported();
    } on DataImportException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.t(
              '无法导入：${error.message}',
              'Could not import: ${error.message}',
            ),
          ),
        ),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.t(
              '导入没有完成，本机数据没有改动。',
              'Import did not finish. Local data was not changed.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _confirmClear(
    BuildContext context,
    GuardianCopy copy, {
    required bool clearConfig,
  }) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              clearConfig
                  ? copy.t('清除 API 配置？', 'Clear API configuration?')
                  : copy.t('清除决策和预算？', 'Clear decisions and budget?'),
            ),
            content: Text(copy.t('这个操作不能撤销。', 'This cannot be undone.')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(copy.t('取消', 'Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(copy.t('确认清除', 'Clear')),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    if (clearConfig) {
      await const ModelConfigStore().clear();
      await onJustOneApiTokenChanged('');
    } else {
      await const DecisionStore().clear();
      await const BudgetStore().clear();
    }
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(copy.t('已经清除。', 'Cleared.'))));
    }
  }

  Future<void> _confirmClearAll(BuildContext context, GuardianCopy copy) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(copy.t('清除全部本地数据？', 'Clear all local data?')),
            content: Text(
              copy.t(
                '记录、预算、规则、API 配置、应用偏好和已安排的提醒都会删除。这个操作不能撤销。',
                'History, budget, rules, API settings, app preferences, and scheduled reminders will be removed. This cannot be undone.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(copy.t('取消', 'Cancel')),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(copy.t('全部清除', 'Clear everything')),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    await const AllDataClearer().clear();
    await onJustOneApiTokenChanged('');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          copy.t(
            '本地数据已清除。重新打开应用后会回到首次设置。',
            'Local data cleared. Reopen the app to start fresh.',
          ),
        ),
      ),
    );
  }
}

class _RuleSettings extends StatefulWidget {
  const _RuleSettings();
  @override
  State<_RuleSettings> createState() => _RuleSettingsState();
}

class _RuleSettingsState extends State<_RuleSettings> {
  List<ConsumptionRule> rules = const [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await const ConsumptionRuleStore().readAll();
    if (mounted) setState(() => rules = value);
  }

  Future<void> _save(List<ConsumptionRule> value) async {
    await const ConsumptionRuleStore().saveAll(value);
    if (mounted) setState(() => rules = value);
  }

  Future<void> _add() async {
    final name = TextEditingController();
    final description = TextEditingController();
    final amount = TextEditingController();
    final days = TextEditingController();
    final rule = await showDialog<ConsumptionRule>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(GuardianCopy.of(context).t('新增消费规则', 'Add rule')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(
                  labelText: GuardianCopy.of(context).t('规则名称', 'Name'),
                ),
              ),
              TextField(
                controller: description,
                decoration: InputDecoration(
                  labelText: GuardianCopy.of(context).t('规则描述', 'Description'),
                ),
              ),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: GuardianCopy.of(
                    context,
                  ).t('最低金额（选填）', 'Minimum amount (optional)'),
                  prefixText: '¥ ',
                ),
              ),
              TextField(
                controller: days,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: GuardianCopy.of(
                    context,
                  ).t('建议等待天数（选填）', 'Wait days (optional)'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(GuardianCopy.of(context).t('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty || description.text.trim().isEmpty) {
                return;
              }
              Navigator.pop(
                context,
                ConsumptionRule(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: name.text.trim(),
                  description: description.text.trim(),
                  minimumAmount: double.tryParse(amount.text.trim()),
                  waitDays: int.tryParse(days.text.trim()),
                ),
              );
            },
            child: Text(GuardianCopy.of(context).t('保存', 'Save')),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    name.dispose();
    description.dispose();
    amount.dispose();
    days.dispose();
    if (rule != null) await _save([...rules, rule]);
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _SettingsSection(
      title: copy.t('消费规则', 'Purchase rules'),
      icon: Icons.rule_outlined,
      children: [
        if (rules.isEmpty)
          Text(
            copy.t(
              '还没有规则。可以先加一条“大额商品至少等两天”。',
              'No rules yet. Add one for large purchases.',
            ),
          ),
        ...rules.map(
          (rule) => Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(rule.name),
              subtitle: Text(rule.description),
              leading: Switch(
                value: rule.enabled,
                onChanged: (value) => _save(
                  rules
                      .map(
                        (item) => item.id == rule.id
                            ? item.copyWith(enabled: value)
                            : item,
                      )
                      .toList(),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    _save(rules.where((item) => item.id != rule.id).toList()),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: Text(copy.t('新增规则', 'Add rule')),
          ),
        ),
      ],
    );
  }
}

class _ModelSettings extends StatefulWidget {
  const _ModelSettings();
  @override
  State<_ModelSettings> createState() => _ModelSettingsState();
}

class _ModelSettingsState extends State<_ModelSettings> {
  final endpoint = TextEditingController();
  final apiKey = TextEditingController();
  final model = TextEditingController();
  ModelServicePreset preset = ModelServicePreset.custom;
  bool structuredOutput = true;
  bool loading = true;
  bool testing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final config = await const ModelConfigStore().read();
      endpoint.text = config.endpoint;
      apiKey.text = config.apiKey;
      model.text = config.model;
      preset = config.preset;
      structuredOutput = config.structuredOutput;
    } on MissingPluginException {
      // Native storage is unavailable in widget tests.
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _testAndSave() async {
    final copy = GuardianCopy.of(context);
    final normalizedEndpoint = ModelConfigStore.normalizeEndpoint(
      endpoint.text,
    );
    endpoint.text = normalizedEndpoint;
    final config = ModelConfig(
      endpoint: normalizedEndpoint,
      model: model.text.trim(),
      apiKey: apiKey.text.trim(),
      structuredOutput: structuredOutput,
      preset: preset,
    );
    if (!config.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.t(
              '请填写有效的接口地址和模型名称。',
              'Enter a valid endpoint and model name.',
            ),
          ),
        ),
      );
      return;
    }
    setState(() => testing = true);
    try {
      await ModelClient(
        endpoint: config.endpoint,
        apiKey: config.apiKey,
        model: config.model,
        useStructuredOutput: config.structuredOutput,
      ).analyze(itemName: '连接测试', price: 1, reason: '只测试连接');
      await const ModelConfigStore().write(config);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.t('模型连接正常，配置已保存。', 'Connected. Configuration saved.'),
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(copy.t('连接失败：$error', 'Connection failed: $error')),
        ),
      );
    } finally {
      if (mounted) setState(() => testing = false);
    }
  }

  @override
  void dispose() {
    endpoint.dispose();
    apiKey.dispose();
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _SettingsSection(
      title: copy.t('模型', 'Model'),
      icon: Icons.hub_outlined,
      children: [
        DropdownButtonFormField<ModelServicePreset>(
          initialValue: preset,
          decoration: InputDecoration(
            labelText: copy.t('服务预设', 'Service preset'),
          ),
          items: ModelServicePreset.values
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(switch (value) {
                    ModelServicePreset.custom => copy.t('自定义', 'Custom'),
                    ModelServicePreset.openAI => 'OpenAI',
                    ModelServicePreset.deepSeek => 'DeepSeek',
                    ModelServicePreset.ollama => 'Ollama',
                  }),
                ),
              )
              .toList(),
          onChanged: loading
              ? null
              : (value) {
                  if (value == null) return;
                  setState(() {
                    preset = value;
                    if (value.endpoint.isNotEmpty) {
                      endpoint.text = value.endpoint;
                    }
                  });
                },
        ),
        TextField(
          controller: endpoint,
          enabled: !loading,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.url,
          textCapitalization: TextCapitalization.none,
          onChanged: (value) {
            if (preset != ModelServicePreset.custom &&
                value.trim() != preset.endpoint) {
              setState(() => preset = ModelServicePreset.custom);
            }
          },
          decoration: InputDecoration(
            labelText: copy.t('Base URL 或完整接口地址', 'Base URL or full endpoint'),
            hintText: 'https://api.example.com/v1',
            helperText: copy.t(
              '以 /v1 结尾时会自动补全 /chat/completions。',
              'URLs ending in /v1 automatically add /chat/completions.',
            ),
          ),
        ),
        TextField(
          controller: apiKey,
          enabled: !loading,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            labelText: copy.t('API Key（选填）', 'API Key (optional)'),
            hintText: '••••••••••••',
          ),
        ),
        TextField(
          controller: model,
          enabled: !loading,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            labelText: copy.t('模型名称', 'Model name'),
            hintText: copy.t('填写服务中的模型名', 'Model name from your service'),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: structuredOutput,
          onChanged: loading
              ? null
              : (value) => setState(() => structuredOutput = value),
          title: Text(copy.t('请求 JSON 输出', 'Request JSON output')),
          subtitle: Text(
            copy.t(
              '如果服务不支持 response_format，请关闭。应用仍会检查并尝试修复返回内容。',
              'Turn this off if the service rejects response_format. The app will still validate and repair the response.',
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: loading || testing ? null : _testAndSave,
            icon: testing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.link_rounded),
            label: Text(copy.t('测试并保存', 'Test and save')),
          ),
        ),
      ],
    );
  }
}

class _JustOneApiSettings extends StatefulWidget {
  const _JustOneApiSettings({
    required this.initialToken,
    required this.onSaved,
  });

  final String initialToken;
  final Future<void> Function(String) onSaved;

  @override
  State<_JustOneApiSettings> createState() => _JustOneApiSettingsState();
}

class _JustOneApiSettingsState extends State<_JustOneApiSettings> {
  late final TextEditingController controller;
  bool busy = false;
  bool obscure = true;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialToken);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _saveAndTest() async {
    final copy = GuardianCopy.of(context);
    final token = controller.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.t('先填 API Key。', 'Enter an API key.'))),
      );
      return;
    }
    setState(() => busy = true);
    try {
      await JustOneApiClient(token: token).loadJdProduct('63081885510');
      await widget.onSaved(token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.t('连接正常，Key 已安全保存。', 'Connected. The key is saved securely.'),
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(copy.t('连接失败：$error', 'Connection failed: $error')),
        ),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _SettingsSection(
      title: 'JustOneAPI',
      icon: Icons.inventory_2_outlined,
      children: [
        Text(
          copy.t(
            '用来补全商品价格、图片和店铺信息。Key 只保存在这台设备。',
            'Used to fill in prices, images, and shop details. The key stays on this device.',
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: 'API Key',
            hintText: '••••••••••••',
            suffixIcon: IconButton(
              onPressed: () => setState(() => obscure = !obscure),
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: busy ? null : _saveAndTest,
            icon: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.link_rounded),
            label: Text(copy.t('测试并保存', 'Test and save')),
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: child,
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.labelLarge),
            ),
            child,
          ],
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children
                .expand((child) => [child, const SizedBox(height: 16)])
                .toList()
              ..removeLast(),
          ],
        ),
      ),
    );
  }
}
