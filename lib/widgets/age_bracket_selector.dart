import 'package:flutter/material.dart';

class AgeBracketSelector extends StatefulWidget {
  final String? selectedBracket;
  final Function(String) onBracketSelected;

  const AgeBracketSelector({
    Key? key,
    this.selectedBracket,
    required this.onBracketSelected,
  }) : super(key: key);

  @override
  State<AgeBracketSelector> createState() => _AgeBracketSelectorState();
}

class _AgeBracketSelectorState extends State<AgeBracketSelector> {
  static const List<Map<String, String>> ageBrackets = [
    {'value': '18-23', 'label': '18-23 (Young Adult)'},
    {'value': '24-29', 'label': '24-29 (Early Career)'},
    {'value': '30-35', 'label': '30-35 (Mid Career)'},
    {'value': '36-41', 'label': '36-41 (Experienced)'},
    {'value': '42-47', 'label': '42-47 (Senior)'},
    {'value': '48-53', 'label': '48-53 (Veteran)'},
    {'value': '54-59', 'label': '54-59 (Pre-retirement)'},
    {'value': '60-65', 'label': '60-65 (Senior Citizen)'},
    {'value': '66+', 'label': '66+ (Elder)'},
  ];

  String? _selectedBracket;

  @override
  void initState() {
    super.initState();
    _selectedBracket = widget.selectedBracket;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.cake,
                  color: Color(0xFF4CA1AF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Age Range',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Select your age bracket for privacy protection',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF636E72),
              ),
            ),
            const SizedBox(height: 16),
            
            // Age bracket grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: ageBrackets.length,
              itemBuilder: (context, index) {
                final bracket = ageBrackets[index];
                final isSelected = _selectedBracket == bracket['value'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBracket = bracket['value'];
                    });
                    widget.onBracketSelected(bracket['value']!);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4CA1AF).withOpacity(0.1)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4CA1AF)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        bracket['value']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF4CA1AF)
                              : const Color(0xFF636E72),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Selected bracket description
            if (_selectedBracket != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CA1AF).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4CA1AF).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4CA1AF),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selected: ${ageBrackets.firstWhere((b) => b['value'] == _selectedBracket)['label']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4CA1AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}