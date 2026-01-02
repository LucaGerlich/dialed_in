import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:pasteboard/pasteboard.dart';
import '../models/models.dart';
import '../widgets/shot_sticker.dart';

class ShareShotDialog extends StatefulWidget {
  final Shot shot;
  final Bean bean;
  final String? machineName;
  final String? grinderName;

  const ShareShotDialog({
    super.key,
    required this.shot,
    required this.bean,
    this.machineName,
    this.grinderName,
  });

  @override
  State<ShareShotDialog> createState() => _ShareShotDialogState();
}

class _ShareShotDialogState extends State<ShareShotDialog> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;
  bool _isSaving = false;
  bool _isCopying = false;

  Future<Uint8List?> _captureSticker() async {
    return await _screenshotController.capture(
      delay: const Duration(milliseconds: 10),
      pixelRatio: 3.0,
    );
  }

  Future<void> _shareSticker() async {
    setState(() => _isSharing = true);
    try {
      final imageBytes = await _captureSticker();
      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/dialed_in_shot.png').create();
        await file.writeAsBytes(imageBytes);

        if (mounted) {
            // ignore: deprecated_member_use
            await Share.shareXFiles(
              [XFile(file.path)], 
              text: 'Check out my shot with ${widget.bean.name}!',
            );
        }
      }
    } catch (e) {
      _showError('Error sharing: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    try {
      final imageBytes = await _captureSticker();
      if (imageBytes != null) {
        // Save to temporary file first as Gal expects a path
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/dialed_in_shot_${DateTime.now().millisecondsSinceEpoch}.png').create();
        await file.writeAsBytes(imageBytes);

        // Check permissions
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
           await Gal.requestAccess();
        }
        
        // Save
        await Gal.putImage(file.path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved to Photos!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      _showError('Error saving: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _copyToClipboard() async {
    setState(() => _isCopying = true);
    try {
      final imageBytes = await _captureSticker();
      if (imageBytes != null) {
        await Pasteboard.writeImage(imageBytes);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Copied to Clipboard! Open Instagram Story and Paste.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showError('Error copying: $e');
    } finally {
      if (mounted) setState(() => _isCopying = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share Sticker',
                  style: TextStyle(fontFamily: 'RobotoMono',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          
          // Preview Area
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          // image: const DecorationImage(
                            // image: NetworkImage('https://images.unsplash.com/photo-1497935586351-b67a49e012bf?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60'),
                            // fit: BoxFit.cover,
                            // opacity: 0.5,
                          // ),
                        ),
                      ),
                      Screenshot(
                        controller: _screenshotController,
                        child: ShotSticker(
                          shot: widget.shot,
                          bean: widget.bean,
                          machineName: widget.machineName,
                          grinderName: widget.grinderName,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const Divider(color: Colors.white10, height: 1),
          
          // Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Copy Button (Best for Instagram)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isCopying ? null : _copyToClipboard,
                    icon: _isCopying
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.copy),
                    label: Text(
                      'Copy (Best for Insta Story)',
                      style: TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    // Save Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSaving ? null : _saveToGallery,
                        icon: _isSaving
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save_alt),
                        label: Text('Save Image', style: TextStyle(fontFamily: 'RobotoMono')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                          side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Regular Share Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSharing ? null : _shareSticker,
                        icon: _isSharing
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.share),
                        label: Text('Share', style: TextStyle(fontFamily: 'RobotoMono')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                          side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
