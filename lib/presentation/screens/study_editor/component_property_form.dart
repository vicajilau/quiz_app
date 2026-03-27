// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/blocs/study_editor_cubit/study_editor_cubit.dart';
import 'package:quizdy/presentation/screens/study_editor/property_form_editors.dart';
import 'package:quizdy/presentation/screens/study_editor/property_form_field.dart';

export 'package:quizdy/presentation/screens/study_editor/property_form_controls.dart';
export 'package:quizdy/presentation/screens/study_editor/property_form_editors.dart';
export 'package:quizdy/presentation/screens/study_editor/property_form_field.dart';

/// Form that renders the appropriate fields for any [StudyComponentType]
/// and saves changes to [StudyEditorCubit] when [save] is called.
class ComponentPropertyForm extends StatefulWidget {
  final int chunkIndex;
  final int pageIndex;
  final int componentIndex;

  /// Called after the cubit has been updated (e.g. to close the panel).
  final VoidCallback onSave;

  const ComponentPropertyForm({
    super.key,
    required this.chunkIndex,
    required this.pageIndex,
    required this.componentIndex,
    required this.onSave,
  });

  @override
  State<ComponentPropertyForm> createState() => ComponentPropertyFormState();
}

class ComponentPropertyFormState extends State<ComponentPropertyForm> {
  late StudyComponentType _type;
  late Map<String, dynamic> _originalProps;
  bool _triedToSave = false;

  // All controllers tracked for disposal
  final List<TextEditingController> _disposables = [];

  // Simple fields
  TextEditingController? _title;
  TextEditingController? _subtitle;
  TextEditingController? _body;
  TextEditingController? _term;
  TextEditingController? _author;
  TextEditingController? _equation;
  TextEditingController? _equationLabel;

  // List<String> fields
  List<TextEditingController> _prosControllers = [];
  List<TextEditingController> _consControllers = [];
  List<TextEditingController> _conceptControllers = [];

  // List<Map<field, controller>> fields
  List<Map<String, TextEditingController>> _itemRows = [];

  // comparisonTable
  List<TextEditingController> _columnControllers = [];
  List<PropertyTableRow> _tableRows = [];
  TextEditingController? _labelHeader;

  TextEditingController _c(String text) {
    final c = TextEditingController(text: text);
    _disposables.add(c);
    return c;
  }

  String _str(Map<String, dynamic> props, String key) =>
      props[key]?.toString() ?? '';

  List<dynamic> _list(Map<String, dynamic> props, String key) {
    final v = props[key];
    if (v is List) return v;
    return [];
  }

  @override
  void initState() {
    super.initState();
    final element = context
        .read<StudyEditorCubit>()
        .state
        .chunks[widget.chunkIndex]
        .pages[widget.pageIndex]
        .uiElements[widget.componentIndex];
    _type = element.componentType;
    _originalProps = Map<String, dynamic>.from(element.props);
    _initControllers(_originalProps);
  }

  void _initControllers(Map<String, dynamic> p) {
    switch (_type) {
      case StudyComponentType.sectionTitle:
        _title = _c(_str(p, 'title'));
        _subtitle = _c(_str(p, 'subtitle'));

      case StudyComponentType.paragraph:
        _title = _c(_str(p, 'title'));
        _body = _c(_str(p, 'body'));

      case StudyComponentType.keyDefinition:
        _term = _c(_str(p, 'term'));
        _body = _c(_str(p, 'body'));

      case StudyComponentType.quote:
        _body = _c(_str(p, 'body'));
        _author = _c(_str(p, 'author'));

      case StudyComponentType.warning:
        _body = _c(_str(p, 'body'));

      case StudyComponentType.reminder:
        _body = _c(_str(p, 'body'));

      case StudyComponentType.formula:
        _title = _c(_str(p, 'title'));
        _equation = _c(_str(p, 'equation'));
        _equationLabel = _c(_str(p, 'equation_label'));
        _body = _c(_str(p, 'body'));

      case StudyComponentType.keyConcepts:
        _title = _c(_str(p, 'title'));
        _conceptControllers = _list(
          p,
          'items',
        ).map((e) => _c(e?.toString() ?? '')).toList();

      case StudyComponentType.numberedList:
        _title = _c(_str(p, 'title'));
        _itemRows = _list(p, 'items').map((e) {
          final m = e is Map
              ? Map<String, dynamic>.from(e)
              : <String, dynamic>{};
          return {
            'title': _c(m['title']?.toString() ?? ''),
            'description': _c(m['description']?.toString() ?? ''),
          };
        }).toList();

      case StudyComponentType.timeline:
        _title = _c(_str(p, 'title'));
        _itemRows = _list(p, 'items').map((e) {
          final m = e is Map
              ? Map<String, dynamic>.from(e)
              : <String, dynamic>{};
          return {
            'date': _c(m['date']?.toString() ?? ''),
            'title': _c(m['title']?.toString() ?? ''),
            'description': _c(m['description']?.toString() ?? ''),
          };
        }).toList();

      case StudyComponentType.iconCards:
        _title = _c(_str(p, 'title'));
        _itemRows = _list(p, 'items').map((e) {
          final m = e is Map
              ? Map<String, dynamic>.from(e)
              : <String, dynamic>{};
          return {
            'title': _c(m['title']?.toString() ?? ''),
            'description': _c(m['description']?.toString() ?? ''),
          };
        }).toList();

      case StudyComponentType.prosCons:
        final items = p['items'];
        final pros = items is Map
            ? _list(Map<String, dynamic>.from(items), 'pros')
            : [];
        final cons = items is Map
            ? _list(Map<String, dynamic>.from(items), 'cons')
            : [];
        _prosControllers = pros.map((e) => _c(e?.toString() ?? '')).toList();
        _consControllers = cons.map((e) => _c(e?.toString() ?? '')).toList();

      case StudyComponentType.comparisonTable:
        _title = _c(_str(p, 'title'));
        _labelHeader = _c(_str(p, 'labelHeader'));
        final cols = _list(p, 'columns');
        _columnControllers = cols.map((e) => _c(e?.toString() ?? '')).toList();
        _tableRows = _list(p, 'rows').map((e) {
          final m = e is Map
              ? Map<String, dynamic>.from(e)
              : <String, dynamic>{};
          final values = (m['values'] is List)
              ? List<String>.from(m['values'])
              : List.filled(_columnControllers.length, '');
          return PropertyTableRow(
            label: _c(m['label']?.toString() ?? ''),
            values: values.map(_c).toList(),
          );
        }).toList();
    }
  }

  @override
  void dispose() {
    for (final c in _disposables) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _buildProps() {
    String text(TextEditingController? c) => c?.text ?? '';
    String? optional(TextEditingController? c) {
      final t = c?.text ?? '';
      return t.isNotEmpty ? t : null;
    }

    switch (_type) {
      case StudyComponentType.sectionTitle:
        return {
          'title': text(_title),
          if (optional(_subtitle) != null) 'subtitle': optional(_subtitle),
        };

      case StudyComponentType.paragraph:
        return {
          'body': text(_body),
          if (optional(_title) != null) 'title': optional(_title),
        };

      case StudyComponentType.keyDefinition:
        return {'term': text(_term), 'body': text(_body)};

      case StudyComponentType.quote:
        return {
          'body': text(_body),
          if (optional(_author) != null) 'author': optional(_author),
        };

      case StudyComponentType.warning:
        return {'body': text(_body)};

      case StudyComponentType.reminder:
        return {'body': text(_body)};

      case StudyComponentType.formula:
        return {
          'equation': text(_equation),
          if (optional(_title) != null) 'title': optional(_title),
          if (optional(_equationLabel) != null)
            'equation_label': optional(_equationLabel),
          if (optional(_body) != null) 'body': optional(_body),
        };

      case StudyComponentType.keyConcepts:
        return {
          'title': text(_title),
          'items': _conceptControllers
              .map((c) => c.text.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
        };

      case StudyComponentType.numberedList:
        return {
          'title': text(_title),
          'items': _itemRows
              .map(
                (r) => {
                  'title': r['title']!.text,
                  'description': r['description']!.text,
                },
              )
              .toList(),
        };

      case StudyComponentType.timeline:
        return {
          'title': text(_title),
          'items': _itemRows
              .map(
                (r) => {
                  'date': r['date']!.text,
                  'title': r['title']!.text,
                  'description': r['description']!.text,
                },
              )
              .toList(),
        };

      case StudyComponentType.iconCards:
        return {
          'title': text(_title),
          'items': _itemRows
              .map(
                (r) => {
                  'title': r['title']!.text,
                  'description': r['description']!.text,
                },
              )
              .toList(),
        };

      case StudyComponentType.prosCons:
        return {
          'items': {
            'pros': _prosControllers
                .map((c) => c.text.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
            'cons': _consControllers
                .map((c) => c.text.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
          },
        };

      case StudyComponentType.comparisonTable:
        return {
          if (optional(_title) != null) 'title': optional(_title),
          if (optional(_labelHeader) != null)
            'labelHeader': optional(_labelHeader),
          'columns': _columnControllers.map((c) => c.text).toList(),
          'rows': _tableRows
              .map(
                (r) => {
                  'label': r.label.text,
                  'values': r.values.map((c) => c.text).toList(),
                },
              )
              .toList(),
        };
    }
  }

  bool _validateRequiredControllers() {
    final required = <TextEditingController?>[];
    switch (_type) {
      case StudyComponentType.sectionTitle:
        required.addAll([_title]);
      case StudyComponentType.paragraph:
        required.addAll([_body]);
      case StudyComponentType.keyDefinition:
        required.addAll([_term, _body]);
      case StudyComponentType.quote:
        required.addAll([_body]);
      case StudyComponentType.warning:
        required.addAll([_body]);
      case StudyComponentType.reminder:
        required.addAll([_body]);
      case StudyComponentType.formula:
        required.addAll([_equation]);
      case StudyComponentType.iconCards:
        required.addAll([_title]);
        for (final row in _itemRows) {
          required.addAll(row.values);
        }
      case StudyComponentType.numberedList:
        required.addAll([_title]);
        for (final row in _itemRows) {
          required.addAll(row.values);
        }
      case StudyComponentType.timeline:
        required.addAll([_title]);
        for (final row in _itemRows) {
          required.addAll(row.values);
        }
      case StudyComponentType.keyConcepts:
        required.addAll([_title]);
        required.addAll(_conceptControllers);
      case StudyComponentType.prosCons:
      case StudyComponentType.comparisonTable:
        break;
    }
    return required.every((c) => c != null && c.text.trim().isNotEmpty);
  }

  void save() {
    if (!_validateRequiredControllers()) {
      setState(() => _triedToSave = true);
      return;
    }
    context.read<StudyEditorCubit>().updateComponent(
      widget.chunkIndex,
      widget.pageIndex,
      widget.componentIndex,
      StudyComponent(componentType: _type, props: _buildProps()),
    );
    widget.onSave();
  }

  // ── List helpers ─────────────────────────────────────────────────────────────

  void _addItemRow(List<String> fields) {
    setState(() {
      _itemRows.add({for (final f in fields) f: _c('')});
    });
  }

  void _removeItemRow(int index) {
    setState(() => _itemRows.removeAt(index));
  }

  void _addStringItem(List<TextEditingController> list) {
    setState(() => list.add(_c('')));
  }

  void _removeStringItem(List<TextEditingController> list, int index) {
    setState(() => list.removeAt(index));
  }

  void _addColumn() {
    setState(() {
      _columnControllers.add(_c(''));
      for (final row in _tableRows) {
        row.values.add(_c(''));
      }
    });
  }

  void _removeColumn(int index) {
    setState(() {
      _columnControllers.removeAt(index);
      for (final row in _tableRows) {
        if (index < row.values.length) row.values.removeAt(index);
      }
    });
  }

  void _addTableRow() {
    setState(() {
      _tableRows.add(
        PropertyTableRow(
          label: _c(''),
          values: List.generate(_columnControllers.length, (_) => _c('')),
        ),
      );
    });
  }

  void _removeTableRow(int index) {
    setState(() => _tableRows.removeAt(index));
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _buildForm(l);
  }

  Widget _buildForm(AppLocalizations l) {
    switch (_type) {
      case StudyComponentType.sectionTitle:
        return PropertySimpleForm(
          children: [
            PropertyField(
              label: l.studyEditorFieldTitle,
              controller: _title!,
              forceShowError: _triedToSave,
            ),
            PropertyField(
              label: l.componentFieldSubtitle,
              controller: _subtitle!,
              optional: true,
            ),
          ],
        );

      case StudyComponentType.paragraph:
        return PropertySimpleForm(
          children: [
            PropertyField(
              label: l.studyEditorFieldTitle,
              controller: _title!,
              optional: true,
            ),
            PropertyField(
              label: l.studyEditorFieldBody,
              controller: _body!,
              multiline: true,
              forceShowError: _triedToSave,
            ),
          ],
        );

      case StudyComponentType.keyDefinition:
        return PropertySimpleForm(
          children: [
            PropertyField(
              label: l.componentFieldTerm,
              controller: _term!,
              forceShowError: _triedToSave,
            ),
            PropertyField(
              label: l.componentFieldDefinition,
              controller: _body!,
              multiline: true,
              forceShowError: _triedToSave,
            ),
          ],
        );

      case StudyComponentType.quote:
        return PropertySimpleForm(
          children: [
            PropertyField(
              label: l.componentFieldQuote,
              controller: _body!,
              multiline: true,
              forceShowError: _triedToSave,
            ),
            PropertyField(
              label: l.componentFieldAuthor,
              controller: _author!,
              optional: true,
            ),
          ],
        );

      case StudyComponentType.warning:
        return PropertySimpleForm(
          children: [
            PropertyField(
              label: l.studyEditorFieldBody,
              controller: _body!,
              multiline: true,
              forceShowError: _triedToSave,
            ),
          ],
        );

      case StudyComponentType.reminder:
        return PropertySimpleForm(
          children: [
            PropertyField(
              label: l.studyEditorFieldBody,
              controller: _body!,
              multiline: true,
              forceShowError: _triedToSave,
            ),
          ],
        );

      case StudyComponentType.formula:
        return PropertySimpleForm(
          children: [
            PropertyField(
              label: l.studyEditorFieldTitle,
              controller: _title!,
              optional: true,
            ),
            PropertyField(
              label: l.componentFieldEquation,
              controller: _equation!,
              forceShowError: _triedToSave,
            ),
            PropertyField(
              label: l.componentFieldEquationLabel,
              controller: _equationLabel!,
              optional: true,
            ),
            PropertyField(
              label: l.componentFieldExplanation,
              controller: _body!,
              optional: true,
              multiline: true,
            ),
          ],
        );

      case StudyComponentType.keyConcepts:
        return PropertySimpleForm(
          children: [
            PropertyField(
              label: l.studyEditorFieldTitle,
              controller: _title!,
              forceShowError: _triedToSave,
            ),
            PropertyStringListEditor(
              label: l.componentFieldItems,
              controllers: _conceptControllers,
              itemLabel: l.componentFieldConcept,
              onAdd: () => _addStringItem(_conceptControllers),
              onRemove: (i) => _removeStringItem(_conceptControllers, i),
              forceShowError: _triedToSave,
            ),
          ],
        );

      case StudyComponentType.numberedList:
        return PropertySimpleForm(
          children: [
            PropertyField(
              label: l.studyEditorFieldTitle,
              controller: _title!,
              forceShowError: _triedToSave,
            ),
            PropertyObjectListEditor(
              label: l.componentFieldItems,
              rows: _itemRows,
              fieldLabels: {
                'title': l.studyEditorFieldTitle,
                'description': l.componentFieldDescription,
              },
              onAdd: () => _addItemRow(['title', 'description']),
              onRemove: _removeItemRow,
              forceShowError: _triedToSave,
            ),
          ],
        );

      case StudyComponentType.timeline:
        return PropertySimpleForm(
          children: [
            PropertyField(
              label: l.studyEditorFieldTitle,
              controller: _title!,
              forceShowError: _triedToSave,
            ),
            PropertyObjectListEditor(
              label: l.componentFieldEvents,
              rows: _itemRows,
              fieldLabels: {
                'date': l.componentFieldDate,
                'title': l.studyEditorFieldTitle,
                'description': l.componentFieldDescription,
              },
              onAdd: () => _addItemRow(['date', 'title', 'description']),
              onRemove: _removeItemRow,
              forceShowError: _triedToSave,
            ),
          ],
        );

      case StudyComponentType.iconCards:
        return PropertySimpleForm(
          children: [
            PropertyField(
              label: l.studyEditorFieldTitle,
              controller: _title!,
              forceShowError: _triedToSave,
            ),
            PropertyObjectListEditor(
              label: l.componentFieldCards,
              rows: _itemRows,
              fieldLabels: {
                'title': l.studyEditorFieldTitle,
                'description': l.componentFieldDescription,
              },
              onAdd: () => _addItemRow(['title', 'description']),
              onRemove: _removeItemRow,
              forceShowError: _triedToSave,
            ),
          ],
        );

      case StudyComponentType.prosCons:
        return PropertySimpleForm(
          children: [
            PropertyStringListEditor(
              label: l.componentFieldPros,
              controllers: _prosControllers,
              itemLabel: l.componentFieldPro,
              onAdd: () => _addStringItem(_prosControllers),
              onRemove: (i) => _removeStringItem(_prosControllers, i),
            ),
            PropertyStringListEditor(
              label: l.componentFieldCons,
              controllers: _consControllers,
              itemLabel: l.componentFieldCon,
              onAdd: () => _addStringItem(_consControllers),
              onRemove: (i) => _removeStringItem(_consControllers, i),
            ),
          ],
        );

      case StudyComponentType.comparisonTable:
        return PropertySimpleForm(
          children: [
            PropertyField(
              label: l.studyEditorFieldTitle,
              controller: _title!,
              optional: true,
            ),
            PropertyComparisonTableEditor(
              columnControllers: _columnControllers,
              tableRows: _tableRows,
              labelHeaderController: _labelHeader!,
              onAddColumn: _addColumn,
              onRemoveColumn: _removeColumn,
              onAddRow: _addTableRow,
              onRemoveRow: _removeTableRow,
              columnLabel: l.componentFieldColumn,
              rowLabel: l.componentFieldRow,
              labelLabel: l.componentFieldLabel,
              labelHeaderLabel: l.componentFieldLabelColumn,
            ),
          ],
        );
    }
  }
}
