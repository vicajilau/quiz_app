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

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:platform_detail/platform_detail.dart';

/// Full-screen PDF viewer dialog with a close button and a configurable
/// save action.
///
/// [onSave] is called when the user taps the download button. It must return
/// `true` if the file was saved successfully (which closes the dialog) or
/// `false` if the operation was cancelled (which keeps the dialog open).
class PdfViewerDialog extends StatefulWidget {
  const PdfViewerDialog({
    super.key,
    required this.pdfBytes,
    required this.title,
    required this.onSave,
  });

  final Uint8List pdfBytes;
  final String title;
  final Future<bool> Function() onSave;

  @override
  State<PdfViewerDialog> createState() => _PdfViewerDialogState();
}

class _PdfViewerDialogState extends State<PdfViewerDialog> {
  final _controller = PdfViewerController();
  bool _initialZoomSet = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (_controller.isReady && !_initialZoomSet) {
      _initialZoomSet = true;
      if (PlatformDetail.isDesktop) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _controller.setZoom(Offset.zero, 1.0);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(false),
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final saved = await widget.onSave();
              if (saved && context.mounted) context.pop(true);
            },
          ),
        ],
      ),
      body: PdfViewer.data(
        widget.pdfBytes,
        sourceName: widget.title,
        controller: _controller,
        params: const PdfViewerParams(
          scrollByMouseWheel: 1,
          useAlternativeFitScaleAsMinScale: false,
        ),
      ),
    );
  }
}
