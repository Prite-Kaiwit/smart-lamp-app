import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class SettingsDialog extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback onSaved;

  const SettingsDialog({
    super.key,
    required this.apiService,
    required this.onSaved,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _urlController;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.apiService.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _runTest() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final success = await widget.apiService.testConnection(_urlController.text);

    setState(() {
      _isTesting = false;
      _testSuccess = success;
      _testResult = success
          ? '✅ เชื่อมต่อเซิร์ฟเวอร์สำเร็จ!'
          : '❌ ไม่สามารถเชื่อมต่อได้ (ตรวจสอบ URL หรือเครือข่าย)';
    });
  }

  Future<void> _save() async {
    await widget.apiService.setBaseUrl(_urlController.text);
    widget.onSaved();
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกการตั้งค่า Backend สำเร็จ'),
          backgroundColor: AppColors.emerald,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      color: AppColors.emeraldLight,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ตั้งค่าการเชื่อมต่อ (Server)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warmText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                'Backend API URL:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 6),

              TextField(
                controller: _urlController,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.warmText,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: 'https://...',
                  hintStyle: TextStyle(color: AppColors.dimText),
                  filled: true,
                  fillColor: AppColors.innerCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.emerald,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Presets
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildPresetChip(
                    'Render Cloud (ค่าเริ่มต้น)',
                    'https://smart-lamp-dashboardv2.onrender.com',
                  ),
                  _buildPresetChip(
                    'Localhost (คอมพิวเตอร์)',
                    'http://127.0.0.1:5000',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Test Connection Status
              if (_testResult != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _testSuccess
                        ? AppColors.emerald950.withValues(alpha: 0.65)
                        : AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _testSuccess ? AppColors.emerald : AppColors.red,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    _testResult!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _testSuccess
                          ? AppColors.emeraldLight
                          : AppColors.red,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isTesting ? null : _runTest,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.wifi_tethering_rounded, size: 16),
                    label: const Text('ทดสอบ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.sky,
                      side: BorderSide(color: AppColors.sky),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber500,
                      foregroundColor: AppColors.warmText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('บันทึก'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, String url) {
    return InkWell(
      onTap: () {
        setState(() {
          _urlController.text = url;
          _testResult = null;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}
