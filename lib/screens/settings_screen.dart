import 'package:flutter/material.dart';
import '../services/preference_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(double)? onUpdateFontSize;
  final Function(String)? onUpdateLanguage;
  
  const SettingsScreen({
    super.key,
    this.onUpdateFontSize,
    this.onUpdateLanguage,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isObscured = true;
  String? _selectedStyle;
  bool _likesExamples = true;
  bool _likesStepByStep = false;
  bool _isDarkMode = false;
  double _fontSize = 1.0;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final apiKey = PreferenceService.getApiKey();
    if (apiKey != null) {
      _apiKeyController.text = apiKey;
    }

    final prefs = PreferenceService.getUserPreferences();
    setState(() {
      _selectedStyle = prefs.explanationStyle;
      _likesExamples = prefs.likesExamples;
      _likesStepByStep = prefs.likesStepByStep;
      _isDarkMode = PreferenceService.getDarkMode();
      _fontSize = PreferenceService.getFontSize();
      _selectedLanguage = PreferenceService.getLanguage();
    });
  }

  Future<void> _saveSettings() async {
    await PreferenceService.saveApiKey(_apiKeyController.text.trim());

    final prefs = PreferenceService.getUserPreferences();
    prefs.updateLearningPattern(
      style: _selectedStyle,
      examples: _likesExamples,
      stepByStep: _likesStepByStep,
    );
    await PreferenceService.savePreferences(prefs);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'API Configuration',
            Icons.key,
            [
              const Text(
                'Get your API key from OpenAI:',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // Copy URL to clipboard or open browser
                },
                child: const Text(
                  'https://platform.openai.com/api-keys',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _apiKeyController,
                obscureText: _isObscured,
                decoration: InputDecoration(
                  labelText: 'OpenAI API Key',
                  hintText: 'sk-...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buAppearance',
            Icons.palette,
            [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark theme'),
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  PreferenceService.setDarkMode(value);
                },
                secondary: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Appearance',
            Icons.palette,
            [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark theme'),
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  PreferenceService.setDarkMode(value);
                },
                secondary: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              ),
              const SizedBox(height: 16),
              const Text(
                'Font Size',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Slider(
                value: _fontSize,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                label: _getFontSizeLabel(_fontSize),
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
                onChangeEnd: (value) {
                  widget.onUpdateFontSize?.call(value);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Small', style: TextStyle(fontSize: 12 * 0.8)),
                  Text('Medium', style: TextStyle(fontSize: 12)),
                  Text('Large', style: TextStyle(fontSize: 12 * 1.2)),
                  Text('XL', style: TextStyle(fontSize: 12 * 1.5)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Language',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                  DropdownMenuItem(value: 'es', child: Text('🇪🇸 Español')),
                  DropdownMenuItem(value: 'fr', child: Text('🇫🇷 Français')),
                  DropdownMenuItem(value: 'de', child: Text('🇩🇪 Deutsch')),
                  DropdownMenuItem(value: 'hi', child: Text('🇮🇳 हिन्दी')),
                  DropdownMenuItem(value: 'zh', child: Text('🇨🇳 中文')),
                  DropdownMenuItem(value: 'ar', child: Text('🇸🇦 العربية')),
                  DropdownMenuItem(value: 'ja', child: Text('🇯🇵 日本語')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                    widget.onUpdateLanguage?.call(value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Learning Preferences',
            Icons.school,
            [
              const Text(
                'Explanation Style',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildStyleOption('short', 'Concise', 'Quick, brief answers'),
              _buildStyleOption('balanced', 'Balanced', 'Clear and complete'),
              _buildStyleOption('detailed', 'Detailed', 'Thorough explanations'),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Include Examples'),
                subtitle: const Text('Show practical examples in explanations'),
                value: _likesExamples,
                onChanged: (value) {
                  setState(() {
                    _likesExamples = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Step-by-Step'),
                subtitle: const Text('Break down complex topics into steps'),
                value: _likesStepByStep,
                onChanged: (value) {
                  setState(() {
                    _likesStepByStep = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStatsSection(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Settings', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStyleOption(String value, String title, String subtitle) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      groupValue: _selectedStyle,
      onChanged: (val) {
        setState(() {
          _selectedStyle = val;
        });
      },
    );
  }

  Widget _buildStatsSection() {
    final prefs = PreferenceService.getUserPreferences();
    return _buildSection(
      'Your Learning Stats',
      Icons.insights,
      [
        _buildStatRow('Total Interactions', '${prefs.totalInteractions}'),
        if (prefs.frequentTopics.isNotEmpty)
          _buildStatRow('Top Topics', prefs.frequentTopics.take(3).join(', ')),
        if (prefs.strengthAreas.isNotEmpty)
          _buildStatRow('Strengths', prefs.strengthAreas.join(', ')),
        if (prefs.weaknessAreas.isNotEmpty)
          _buildStatRow('Learning Areas', prefs.weaknessAreas.join(', ')),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _getFontSizeLabel(double size) {
    if (size <= 0.9) return 'Small';
    if (size <= 1.1) return 'Medium';
    if (size <= 1.3) return 'Large';
    return 'Extra Large';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
