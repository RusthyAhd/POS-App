import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
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
                    '2. Create bills for customers\n'
                    '3. Manage customer information\n'
                    '4. Track your sales and reports\n'
                    '5. Customize settings as needed'),
                ),
                _buildHelpTile(
                  context,
                  title: 'Adding Products',
                  subtitle: 'How to add and manage products',
                  icon: Icons.add_box_outlined,
                  onTap: () => _showHelpDialog(context, 'Adding Products',
                    'To add products:\n\n'
                    '1. Tap the "+" button on the home screen\n'
                    '2. Enter product name and price\n'
                    '3. Set stock quantity\n'
                    '4. Add product description (optional)\n'
                    '5. Save the product'),
                ),
                _buildHelpTile(
                  context,
                  title: 'Creating Bills',
                  subtitle: 'How to create and manage bills',
                  icon: Icons.receipt_long_outlined,
                  onTap: () => _showHelpDialog(context, 'Creating Bills',
                    'To create a bill:\n\n'
                    '1. Select products from the home screen\n'
                    '2. Adjust quantities as needed\n'
                    '3. Add customer information\n'
                    '4. Apply discounts if applicable\n'
                    '5. Generate and print the bill'),
                ),
                _buildHelpTile(
                  context,
                  title: 'Managing Customers',
                  subtitle: 'Customer management guide',
                  icon: Icons.people_outline,
                  onTap: () => _showHelpDialog(context, 'Managing Customers',
                    'Customer management features:\n\n'
                    '1. Add new customers with contact details\n'
                    '2. View customer purchase history\n'
                    '3. Track customer analytics\n'
                    '4. Export customer data\n'
                    '5. Manage customer preferences'),
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
                  answer: 'You can backup your data by going to Settings > Security > Data Export. This will create a backup file that you can save to your device or cloud storage.',
                ),
                _buildFAQTile(
                  context,
                  question: 'Can I customize the receipt format?',
                  answer: 'Yes! Go to Settings > Business > Receipt Format to customize your receipt layout, add your business logo, and modify the information displayed.',
                ),
                _buildFAQTile(
                  context,
                  question: 'How do I change the currency?',
                  answer: 'Navigate to Settings > Business > Currency to change your default currency. PegasFlex supports multiple currencies including LKR, USD, EUR, and more.',
                ),
                _buildFAQTile(
                  context,
                  question: 'Is my data secure?',
                  answer: 'Yes, your data is stored locally on your device and is protected. You can enable additional security features like App Lock in the Settings menu.',
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
                _buildContactTile(
                  context,
                  title: 'Phone Support',
                  subtitle: '+94 11 123 4567',
                  icon: Icons.phone_outlined,
                  onTap: () => _copyToClipboard(context, '+94 11 123 4567', 'Phone number copied to clipboard'),
                ),
                _buildContactTile(
                  context,
                  title: 'WhatsApp Support',
                  subtitle: '+94 77 123 4567',
                  icon: Icons.chat_outlined,
                  onTap: () => _copyToClipboard(context, '+94 77 123 4567', 'WhatsApp number copied to clipboard'),
                ),
                _buildContactTile(
                  context,
                  title: 'Website',
                  subtitle: 'www.pegas.lk',
                  icon: Icons.language_outlined,
                  onTap: () => _copyToClipboard(context, 'www.pegas.lk', 'Website URL copied to clipboard'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Feedback Section
            _buildSectionCard(
              context,
              title: 'Feedback',
              icon: Icons.feedback_outlined,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'We value your feedback!',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                  Text(
                    'PegasFlex',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 1,
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
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0.5,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue[700],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[600],
      ),
      onTap: onTap,
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.green[700],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.copy,
        size: 16,
        color: Colors.grey[600],
      ),
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
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.grey[700],
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
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Thank You!',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Your feedback is important to us. Please contact our support team at support@pegas.lk to share your thoughts.',
            style: TextStyle(
              height: 1.5,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
