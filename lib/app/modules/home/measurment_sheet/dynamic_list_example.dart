import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Example of how the dynamic system works
class DynamicListExample extends StatelessWidget {
  const DynamicListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dynamic List Example')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'This demonstrates how your list can handle dynamic API responses:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildExampleCard(
                  'Current API Response',
                  _getCurrentApiExample(),
                ),
                const SizedBox(height: 16),
                _buildExampleCard(
                  'Future API Response (with new fields)',
                  _getFutureApiExample(),
                ),
                const SizedBox(height: 16),
                _buildExampleCard(
                  'How It Works',
                  _getHowItWorksExample(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String title, String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  String _getCurrentApiExample() {
    return '''
{
  "app_column_details": {
    "columns": ["System ID", "PBOQ Name", "CBOQ No", "Package Name", "UOM", "Zones", "PBOQ Qty", "MS Qty"],
    "front_display_columns": ["PBOQ Name", "CBOQ No", "PBOQ Qty"],
    "button_display_column": ["MS Qty"]
  },
  "data": [{
    "System ID": "1",
    "PBOQ Name": "CBOQ001",
    "CBOQ No": "CBOQ001",
    "Package Name": "HB Interior Design",
    "UOM": "Sq. Ft.",
    "Zones": "Zone 1,Zone 2",
    "PBOQ Qty": "1200",
    "MS Qty": 0
  }]
}''';
  }

  String _getFutureApiExample() {
    return '''
{
  "app_column_details": {
    "columns": ["System ID", "PBOQ Name", "CBOQ No", "Package Name", "UOM", "Zones", "PBOQ Qty", "MS Qty", "Priority", "Status", "Contractor"],
    "front_display_columns": ["PBOQ Name", "Status", "Priority"],
    "button_display_column": ["MS Qty", "Priority"]
  },
  "data": [{
    "System ID": "1",
    "PBOQ Name": "CBOQ001",
    "CBOQ No": "CBOQ001",
    "Package Name": "HB Interior Design",
    "UOM": "Sq. Ft.",
    "Zones": "Zone 1,Zone 2",
    "PBOQ Qty": "1200",
    "MS Qty": 0,
    "Priority": "High",
    "Status": "In Progress",
    "Contractor": "ABC Construction"
  }]
}''';
  }

  String _getHowItWorksExample() {
    return '''
1. The AllData model now stores all fields in a Map<String, dynamic>
2. The API response defines which columns to show via app_column_details
3. Your UI automatically adapts to show:
   - front_display_columns: Main visible fields
   - button_display_column: Fields shown as buttons
   - All other columns: Shown when expanded

Benefits:
✅ No code changes needed when API adds/removes fields
✅ UI layout controlled by backend configuration
✅ Backward compatible with existing data
✅ Supports any number of dynamic fields

The controller methods handle all the dynamic field access:
- getFieldValue(item, columnName)
- getFrontDisplayColumns()
- getButtonDisplayColumns()
- getAllColumns()''';
  }
}