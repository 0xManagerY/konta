import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/presentation/providers/invoice_template_provider.dart';
import 'package:konta/core/utils/logger.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  @override
  void initState() {
    super.initState();
    Logger.ui('TemplatesScreen', 'INIT');
  }

  static const colorPresets = [
    Color(0xFF1976D2),
    Color(0xFF424242),
    Color(0xFF388E3C),
    Color(0xFFD32F2F),
    Color(0xFFF57C00),
    Color(0xFF7B1FA2),
  ];

  static const colorPresetHex = [
    '#1976D2',
    '#424242',
    '#388E3C',
    '#D32F2F',
    '#F57C00',
    '#7B1FA2',
  ];

  String? _selectedTemplateId;
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(invoiceTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Template'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(invoiceTemplatesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (templates) {
          if (templates.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('No templates available'),
                ],
              ),
            );
          }

          _selectedTemplateId ??= templates.first.id;

          final selectedTemplate = templates.firstWhere(
            (t) => t.id == _selectedTemplateId,
            orElse: () => templates.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose a template for your documents',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                _buildTemplateCards(templates, selectedTemplate),
                const SizedBox(height: 32),
                _buildCustomizeSection(selectedTemplate, templates),
                const SizedBox(height: 24),
                if (_hasChanges) _buildApplyButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateCards(
    List<InvoiceTemplate> templates,
    InvoiceTemplate selectedTemplate,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: templates.map((template) {
          return _buildTemplateCard(template, selectedTemplate);
        }).toList(),
      ),
    );
  }

  Widget _buildTemplateCard(
    InvoiceTemplate template,
    InvoiceTemplate selectedTemplate,
  ) {
    final isSelected = template.id == _selectedTemplateId;
    final templateColor = Color(
      int.parse(template.primaryColor.replaceFirst('#', '0xFF')),
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTemplateId = template.id;
          _hasChanges = true;
        });
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: templateColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(7),
                ),
              ),
              child: _buildTemplatePreview(template, templateColor),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    )
                  else
                    Icon(
                      Icons.radio_button_unchecked,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatePreview(InvoiceTemplate template, Color templateColor) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (template.headerStyle == HeaderStyle.logoLeft ||
                  template.headerStyle == HeaderStyle.logoCenter)
                _buildLogoPlaceholder(template.headerStyle, templateColor),
              if (template.headerStyle == HeaderStyle.logoCenter)
                const Spacer(),
              Expanded(
                flex: template.headerStyle == HeaderStyle.logoCenter ? 1 : 2,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: templateColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (template.headerStyle == HeaderStyle.logoRight ||
                  template.headerStyle == HeaderStyle.logoCenter)
                const Spacer(),
              if (template.headerStyle == HeaderStyle.logoRight)
                _buildLogoPlaceholder(template.headerStyle, templateColor),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (template.showCustomerIce)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: templateColor, width: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'ICE',
                    style: TextStyle(fontSize: 6, color: templateColor),
                  ),
                ),
              if (template.showCustomerIce && template.showPaymentTerms)
                const SizedBox(width: 4),
              if (template.showPaymentTerms)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!, width: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'PAY',
                    style: TextStyle(fontSize: 6, color: Colors.grey[600]),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder(HeaderStyle style, Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Icon(Icons.business, size: 10, color: color),
    );
  }

  Widget _buildCustomizeSection(
    InvoiceTemplate selectedTemplate,
    List<InvoiceTemplate> allTemplates,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Customize',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        _buildColorPicker(selectedTemplate, allTemplates),
        const SizedBox(height: 24),
        _buildLogoPositionPicker(selectedTemplate, allTemplates),
        const SizedBox(height: 24),
        _buildToggleSwitches(selectedTemplate, allTemplates),
      ],
    );
  }

  Widget _buildColorPicker(
    InvoiceTemplate selectedTemplate,
    List<InvoiceTemplate> allTemplates,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(colorPresets.length, (index) {
            final color = colorPresets[index];
            final hex = colorPresetHex[index];
            final isSelected =
                selectedTemplate.primaryColor.toUpperCase() ==
                hex.toUpperCase();

            return GestureDetector(
              onTap: () =>
                  _onColorSelected(selectedTemplate, allTemplates, hex),
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLogoPositionPicker(
    InvoiceTemplate selectedTemplate,
    List<InvoiceTemplate> allTemplates,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Logo Position',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        SegmentedButton<HeaderStyle>(
          segments: const [
            ButtonSegment<HeaderStyle>(
              value: HeaderStyle.logoLeft,
              icon: Icon(Icons.format_align_left, size: 18),
              label: Text('Left'),
            ),
            ButtonSegment<HeaderStyle>(
              value: HeaderStyle.logoCenter,
              icon: Icon(Icons.format_align_center, size: 18),
              label: Text('Center'),
            ),
            ButtonSegment<HeaderStyle>(
              value: HeaderStyle.logoRight,
              icon: Icon(Icons.format_align_right, size: 18),
              label: Text('Right'),
            ),
            ButtonSegment<HeaderStyle>(
              value: HeaderStyle.noLogo,
              icon: Icon(Icons.not_interested, size: 18),
              label: Text('Hidden'),
            ),
          ],
          selected: {selectedTemplate.headerStyle},
          onSelectionChanged: (Set<HeaderStyle> newSelection) {
            _onHeaderStyleSelected(
              selectedTemplate,
              allTemplates,
              newSelection.first,
            );
          },
        ),
      ],
    );
  }

  Widget _buildToggleSwitches(
    InvoiceTemplate selectedTemplate,
    List<InvoiceTemplate> allTemplates,
  ) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Show customer ICE'),
          value: selectedTemplate.showCustomerIce,
          onChanged: (value) => _toggleOption(
            selectedTemplate,
            allTemplates,
            showCustomerIce: value,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Show payment terms'),
          value: selectedTemplate.showPaymentTerms,
          onChanged: (value) => _toggleOption(
            selectedTemplate,
            allTemplates,
            showPaymentTerms: value,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Show product SKUs'),
          value: selectedTemplate.showProductSkus,
          onChanged: (value) => _toggleOption(
            selectedTemplate,
            allTemplates,
            showProductSkus: value,
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () async {
          final templates =
              ref.read(invoiceTemplatesProvider).valueOrNull ?? [];
          final selectedTemplate = templates.firstWhere(
            (t) => t.id == _selectedTemplateId,
            orElse: () => templates.first,
          );
          await _applyTemplate(selectedTemplate);
          setState(() => _hasChanges = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Template updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: const Text('Apply'),
      ),
    );
  }

  void _onColorSelected(
    InvoiceTemplate selectedTemplate,
    List<InvoiceTemplate> allTemplates,
    String color,
  ) {
    Logger.ui('TemplatesScreen', 'COLOR_SELECTED', color);
    _updateTemplateProperty(
      selectedTemplate,
      allTemplates,
      primaryColor: color,
    );
  }

  void _onHeaderStyleSelected(
    InvoiceTemplate selectedTemplate,
    List<InvoiceTemplate> allTemplates,
    HeaderStyle style,
  ) {
    Logger.ui('TemplatesScreen', 'HEADER_STYLE_CHANGED', style.name);
    _updateTemplateProperty(selectedTemplate, allTemplates, headerStyle: style);
  }

  void _toggleOption(
    InvoiceTemplate selectedTemplate,
    List<InvoiceTemplate> allTemplates, {
    bool? showCustomerIce,
    bool? showPaymentTerms,
    bool? showProductSkus,
  }) {
    String optionKey;
    bool value;
    if (showCustomerIce != null) {
      optionKey = 'showCustomerIce';
      value = showCustomerIce;
    } else if (showPaymentTerms != null) {
      optionKey = 'showPaymentTerms';
      value = showPaymentTerms;
    } else {
      optionKey = 'showProductSkus';
      value = showProductSkus!;
    }
    Logger.ui('TemplatesScreen', 'TOGGLE_OPTION', '$optionKey=$value');
    _updateTemplateProperty(
      selectedTemplate,
      allTemplates,
      showCustomerIce: showCustomerIce,
      showPaymentTerms: showPaymentTerms,
      showProductSkus: showProductSkus,
    );
  }

  Future<void> _applyTemplate(InvoiceTemplate template) async {
    Logger.ui('TemplatesScreen', 'APPLY_TEMPLATE', 'templateId=${template.id}');
    await _updateTemplate(template);
  }

  void _updateTemplateProperty(
    InvoiceTemplate template,
    List<InvoiceTemplate> allTemplates, {
    String? primaryColor,
    HeaderStyle? headerStyle,
    bool? showCustomerIce,
    bool? showPaymentTerms,
    bool? showProductSkus,
  }) {
    final updatedTemplate = InvoiceTemplate(
      id: template.id,
      companyId: template.companyId,
      name: template.name,
      description: template.description,
      headerStyle: headerStyle ?? template.headerStyle,
      primaryColor: primaryColor ?? template.primaryColor,
      showCustomerIce: showCustomerIce ?? template.showCustomerIce,
      showPaymentTerms: showPaymentTerms ?? template.showPaymentTerms,
      showProductSkus: showProductSkus ?? template.showProductSkus,
      footerText: template.footerText,
      isDefault: template.isDefault,
      createdAt: template.createdAt,
      updatedAt: DateTime.now(),
    );

    _updateTemplate(updatedTemplate);
    ref.read(invoiceTemplatesProvider.notifier).updateTemplate(updatedTemplate);

    Logger.info('TEMPLATE_UPDATED: ${template.id}', tag: 'TemplatesScreen');
  }

  Future<void> _updateTemplate(InvoiceTemplate template) async {
    await ref.read(invoiceTemplatesProvider.notifier).updateTemplate(template);
  }
}
