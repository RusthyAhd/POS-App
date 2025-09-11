import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        elevation: 8,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Quick Help Section
                _buildSectionCard(
                  context,
                  title: 'Quick Help',
                  icon: Icons.help_outline,
                  children: [
                    _buildHelpTile(
                      context,
                      title: 'Getting Started',
                      subtitle: 'Learn the basics of PegasFlex',
                      icon: Icons.play_circle_outline,
                      onTap: () => _showHelpDialog(context, 'Getting Started', 
                        'Welcome to PegasFlex! Here are the basics:\n\n'
                        '1. Add products to your inventory\n'
                        '2. Select products to create bills\n'
                        '3. Add customer details if needed\n'
                        '4. Apply discounts if applicable\n'
                        '5. Print or save the bill\n\n'
                        'Use the sliding menu to access different features like stock management, customer management, and reports.'
                      ),
                    ),
                    const Divider(height: 1),
                    _buildHelpTile(
                      context,
                      title: 'Managing Products',
                      subtitle: 'Add, edit, and organize your inventory',
                      icon: Icons.inventory_outlined,
                      onTap: () => _showHelpDialog(context, 'Managing Products',
                        'Product Management:\n\n'
                        '• Go to Stock Management from the menu\n'
                        '• Tap the + button to add new products\n'
                        '• Fill in product details like name, price, category\n'
                        '• Set stock quantities\n'
                        '• Use categories to organize products\n'
                        '• Update stock levels when needed\n\n'
                        'Pro Tip: Use descriptive names and categories to make products easy to find!'
                      ),
                    ),
                    const Divider(height: 1),
                    _buildHelpTile(
                      context,
                      title: 'Creating Bills',
                      subtitle: 'Process sales and generate receipts',
                      icon: Icons.receipt_long_outlined,
                      onTap: () => _showHelpDialog(context, 'Creating Bills',
                        'Creating Bills:\n\n'
                        '1. From the home screen, tap on products to add them to the bill\n'
                        '2. Items will appear in the current bill section\n'
                        '3. Tap the bill button to proceed to bill details\n'
                        '4. Add customer information (optional)\n'
                        '5. Apply discounts if needed\n'
                        '6. Review the total and print or save\n\n'
                        'You can edit quantities and prices in the bill details screen.'
                      ),
                    ),
                    const Divider(height: 1),
                    _buildHelpTile(
                      context,
                      title: 'Customer Management',
                      subtitle: 'Manage your customer database',
                      icon: Icons.people_outline,
                      onTap: () => _showHelpDialog(context, 'Customer Management',
                        'Customer Management:\n\n'
                        '• Access Customer Management from the menu\n'
                        '• Add new customers with contact details\n'
                        '• View customer purchase history\n'
                        '• Filter customers by type (Regular, Premium, VIP)\n'
                        '• Search customers by name, phone, or email\n'
                        '• Track customer analytics and spending\n\n'
                        'Having customer data helps in building relationships and marketing.'
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Contact Support Section
                _buildSectionCard(
                  context,
                  title: 'Contact Support',
                  icon: Icons.support_agent_outlined,
                  children: [
                    _buildContactTile(
                      context,
                      title: 'Email Support',
                      subtitle: 'support@pegas.lk',
                      icon: Icons.email_outlined,
                      onTap: () => _copyToClipboard(context, 'support@pegas.lk', 'Email copied to clipboard'),
                    ),
                    const Divider(height: 1),
                    _buildContactTile(
                      context,
                      title: 'Phone Support',
                      subtitle: '+94 11 234 5678',
                      icon: Icons.phone_outlined,
                      onTap: () => _copyToClipboard(context, '+94 11 234 5678', 'Phone number copied to clipboard'),
                    ),
                    const Divider(height: 1),
                    _buildContactTile(
                      context,
                      title: 'WhatsApp Support',
                      subtitle: '+94 77 234 5678',
                      icon: Icons.chat_outlined,
                      onTap: () => _copyToClipboard(context, '+94 77 234 5678', 'WhatsApp number copied to clipboard'),
                    ),
                    const Divider(height: 1),
                    _buildContactTile(
                      context,
                      title: 'Business Hours',
                      subtitle: 'Monday - Friday, 9:00 AM - 6:00 PM',
                      icon: Icons.access_time_outlined,
                      onTap: null,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // FAQ Section
                _buildSectionCard(
                  context,
                  title: 'Frequently Asked Questions',
                  icon: Icons.quiz_outlined,
                  children: [
                    _buildFAQTile(
                      context,
                      question: 'How do I backup my data?',
                      answer: 'Go to Settings > Data Management > Backup Data. This will create a secure backup of all your products, customers, and sales data.',
                    ),
                    const Divider(height: 1),
                    _buildFAQTile(
                      context,
                      question: 'Can I use this app offline?',
                      answer: 'Yes! PegasFlex works completely offline. All your data is stored locally on your device.',
                    ),
                    const Divider(height: 1),
                    _buildFAQTile(
                      context,
                      question: 'How do I change the currency?',
                      answer: 'Currently, the app uses Sri Lankan Rupees (LKR). Currency selection will be available in future updates.',
                    ),
                    const Divider(height: 1),
                    _buildFAQTile(
                      context,
                      question: 'Is my data secure?',
                      answer: 'Yes, all your data is stored securely on your device. We recommend regular backups to prevent data loss.',
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Feedback Section
                _buildSectionCard(
                  context,
                  title: 'Feedback & Suggestions',
                  icon: Icons.feedback_outlined,
                  children: [
                    Text(
                      'Help us improve PegasFlex by sharing your thoughts, suggestions, or reporting any issues you encounter.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showFeedbackDialog(context);
                            },
                            icon: const Icon(Icons.star_outline, size: 18),
                            label: const Text('Rate App'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showFeedbackDialog(context);
                            },
                            icon: const Icon(Icons.bug_report_outlined, size: 18),
                            label: const Text('Report Bug'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              side: BorderSide(color: Theme.of(context).primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // App Info
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'PegasFlex',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Powered by Pegas (Pvt) Ltd',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: onTap != null 
          ? Icon(Icons.copy, color: Colors.grey[400], size: 20)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildFAQTile(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Your feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
