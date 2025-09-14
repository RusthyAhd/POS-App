import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/billing_item.dart';
import '../models/bill.dart';
import '../models/customer.dart';
import '../providers/firebase_bill_provider.dart';
import '../providers/firebase_product_provider.dart';
import '../providers/firebase_customer_provider.dart';
import '../utils/theme_helpers.dart';

class BillDetailsScreen extends StatefulWidget {
  final List<BillingItem> billingItems;
  final String billNumber;
  final Customer? customer;
  final Function(Customer)? onCustomerAdded;

  const BillDetailsScreen({
    super.key,
    required this.billingItems,
    required this.billNumber,
    this.customer,
    this.onCustomerAdded,
  });

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  double discountAmount = 0.0;
  Customer? selectedCustomer;
  final TextEditingController _discountController = TextEditingController();

  double get subtotalAmount {
    return widget.billingItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get finalAmount {
    return subtotalAmount - discountAmount;
  }

  double get discountPercentage {
    if (subtotalAmount > 0) {
      return (discountAmount / subtotalAmount) * 100;
    }
    return 0.0;
  }

  void _applyDiscount(String value) {
    setState(() {
      double enteredAmount = double.tryParse(value) ?? 0.0;
      // Ensure discount doesn't exceed subtotal
      if (enteredAmount <= subtotalAmount) {
        discountAmount = enteredAmount;
      } else {
        discountAmount = subtotalAmount;
        _discountController.text = subtotalAmount.toStringAsFixed(2);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    selectedCustomer = widget.customer;
    // Initialize discount controller with "0"
    _discountController.text = "0";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bill Details - ${widget.billNumber}',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _showPrintDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: () => _showBillPreview(),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBill,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Header
            Card(
              shape: ThemeHelpers.getCardShape(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bill No: ${widget.billNumber}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThemeHelpers.getHeadingColor(context),
                          ),
                        ),
                        Text(
                          'Date: ${DateTime.now().toString().split(' ')[0]}',
                          style: TextStyle(
                            color: ThemeHelpers.getSecondaryGreyColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (selectedCustomer != null) ...[
                      Text(
                        'Customer Details:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemeHelpers.getHeadingColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Shop: ${selectedCustomer!.shopName}',
                        style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(context)),
                      ),
                      if (selectedCustomer!.phone.isNotEmpty)
                        Text(
                          'Phone: ${selectedCustomer!.phone}',
                          style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(context)),
                        ),
                      if (selectedCustomer!.area.isNotEmpty)
                        Text(
                          'Area: ${selectedCustomer!.area}',
                          style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(context)),
                        ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Customer: Walk-in',
                            style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(context)),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (dialogContext) => CustomerSelectionDialog(
                                  onCustomerSelected: (customer) {
                                    setState(() {
                                      selectedCustomer = customer;
                                    });
                                    if (widget.onCustomerAdded != null) {
                                      widget.onCustomerAdded!(customer);
                                    }
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text(
                              'Add Customer',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Items Section
            Card(
              shape: ThemeHelpers.getCardShape(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelpers.getHeadingColor(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.billingItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.name,
                              style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(context)),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${item.quantity}x',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: ThemeHelpers.getSecondaryGreyColor(context)),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'LKR ${item.price.toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(context)),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'LKR ${(item.price * item.quantity).toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeHelpers.getPrimaryTextColor(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ThemeHelpers.getHeadingColor(context),
                          ),
                        ),
                        Text(
                          'LKR ${widget.billingItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ThemeHelpers.getHeadingColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Discount Section
            Card(
              shape: ThemeHelpers.getCardShape(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Apply Discount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThemeHelpers.getHeadingColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Subtotal display
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal:',
                            style: TextStyle(
                              fontSize: 16,
                              color: ThemeHelpers.getSecondaryGreyColor(context),
                            ),
                          ),
                          Text(
                            'LKR ${subtotalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeHelpers.getPrimaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _discountController,
                            decoration: InputDecoration(
                              labelText: 'Discount Amount (LKR)',
                              prefixIcon: Icon(
                                Icons.money_off,
                                color: Theme.of(context).primaryColor,
                              ),
                              border: const OutlineInputBorder(),
                              hintText: '0.00',
                              helperText: 'Tap to edit discount amount',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: _applyDiscount,
                            onTap: () {
                              // Auto-select all text when tapped
                              _discountController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _discountController.text.length,
                              );
                            },
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: ThemeHelpers.getPrimaryTextColor(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Percentage',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ThemeHelpers.getSecondaryGreyColor(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${discountPercentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (discountAmount > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Discount of LKR ${discountAmount.toStringAsFixed(2)} applied (${discountPercentage.toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  discountAmount = 0.0;
                                  _discountController.clear();
                                });
                              },
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Total Section
            Card(
              shape: ThemeHelpers.getCardShape(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ThemeHelpers.getHeadingColor(context),
                          ),
                        ),
                        Text(
                          'LKR ${finalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showPrintDialog(),
                    icon: const Icon(Icons.print),
                    label: const Text(
                      'Print Bill',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showBillPreview(),
                    icon: const Icon(Icons.preview),
                    label: const Text(
                      'Preview',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPrintDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Print Options',
          style: TextStyle(color: ThemeHelpers.getHeadingColor(dialogContext)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.print),
              title: Text(
                'Thermal Printer',
                style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(dialogContext)),
              ),
              onTap: () {
                Navigator.pop(dialogContext);
                _connectThermalPrinter(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(
                'Share Bill',
                style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(dialogContext)),
              ),
              onTap: () {
                Navigator.pop(dialogContext);
                _shareBill(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBillPreview() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Bill Preview',
          style: TextStyle(color: ThemeHelpers.getHeadingColor(dialogContext)),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PEGAS POS SYSTEM',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeHelpers.getHeadingColor(dialogContext),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Bill No: ${widget.billNumber}',
                style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(dialogContext)),
              ),
              Text(
                'Date: ${DateTime.now().toString().split(' ')[0]}',
                style: TextStyle(color: ThemeHelpers.getSecondaryGreyColor(dialogContext)),
              ),
              if (selectedCustomer != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Customer: ${selectedCustomer!.shopName}',
                  style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(dialogContext)),
                ),
                if (selectedCustomer!.phone.isNotEmpty)
                  Text(
                    'Phone: ${selectedCustomer!.phone}',
                    style: TextStyle(color: ThemeHelpers.getSecondaryGreyColor(dialogContext)),
                  ),
              ],
              const SizedBox(height: 16),
              Text(
                'Items:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemeHelpers.getHeadingColor(dialogContext),
                ),
              ),
              const SizedBox(height: 8),
              ...widget.billingItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name} x${item.quantity}',
                        style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(dialogContext)),
                      ),
                    ),
                    Text(
                      'LKR ${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(dialogContext)),
                    ),
                  ],
                ),
              )),
              const Divider(),
              if (discountAmount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discount (${discountPercentage.toStringAsFixed(1)}%):',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '-LKR ${discountAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ThemeHelpers.getHeadingColor(dialogContext),
                    ),
                  ),
                  Text(
                    'LKR ${finalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ThemeHelpers.getHeadingColor(dialogContext),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for your business!',
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeHelpers.getSecondaryGreyColor(dialogContext),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Close',
                  style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(dialogContext)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _connectThermalPrinter(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Thermal Printer',
          style: TextStyle(color: ThemeHelpers.getHeadingColor(dialogContext)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bluetooth_rounded, 
              size: 48,
              color: Theme.of(dialogContext).primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Connecting to thermal printer...',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Make sure your thermal printer is turned on and paired.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Save bill to Firebase after printing
              await _saveBillToHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bill printed and saved to history!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Clear current bill and go back to home
                Navigator.pop(context, true);
              }
            },
            child: Text(
              'Print',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _shareBill(BuildContext context) async {
    try {
      // Create bill text for sharing
      final billText = _generateBillText();
      
      // Try different WhatsApp sharing methods
      await _shareToWhatsApp(billText, context);
      
      // Save bill to Firebase after sharing
      await _saveBillToHistory();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill shared and saved to history!'),
            backgroundColor: Colors.green,
          ),
        );
        // Clear current bill and go back to home
        Navigator.pop(context, true);
      }
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share bill: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareToWhatsApp(String billText, BuildContext context) async {
    try {
      // Method 1: Try WhatsApp direct URL (most reliable)
      final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(billText)}';
      
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening WhatsApp...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Method 2: Try WhatsApp app URL scheme
      final whatsappAppUrl = 'whatsapp://send?text=${Uri.encodeComponent(billText)}';
      
      if (await canLaunchUrl(Uri.parse(whatsappAppUrl))) {
        await launchUrl(
          Uri.parse(whatsappAppUrl),
          mode: LaunchMode.externalApplication,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening WhatsApp...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // If WhatsApp is not available, show message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp not found. Please install WhatsApp to share bills.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share to WhatsApp. Please check your internet connection.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  String _generateBillText() {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('🧾 *PEGAS FLEX - BILL RECEIPT*');
    buffer.writeln('─────────────────────────');
    buffer.writeln('📄 Bill: ${widget.billNumber}');
    buffer.writeln('📅 ${DateTime.now().toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1].substring(0, 5)}');
    
    // Customer info
    if (selectedCustomer != null) {
      buffer.writeln('');
      buffer.writeln('👤 *${selectedCustomer!.shopName}*');
      if (selectedCustomer!.phone.isNotEmpty) {
        buffer.writeln('📞 ${selectedCustomer!.phone}');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('🛒 *ITEMS:*');
    
    // Items - more compact format
    for (int i = 0; i < widget.billingItems.length; i++) {
      final item = widget.billingItems[i];
      buffer.writeln('${i + 1}. *${item.name}*');
      buffer.writeln('   ${item.quantity} × Rs.${item.price.toStringAsFixed(2)} = Rs.${item.totalPrice.toStringAsFixed(2)}');
    }
    
    // Totals
    buffer.writeln('');
    buffer.writeln('─────────────────────────');
    buffer.writeln('💰 *BILL SUMMARY*');
    buffer.writeln('Subtotal: Rs.${subtotalAmount.toStringAsFixed(2)}');
    if (discountAmount > 0) {
      buffer.writeln('Discount: -Rs.${discountAmount.toStringAsFixed(2)}');
    }
    buffer.writeln('');
    buffer.writeln('🎯 *TOTAL: Rs.${finalAmount.toStringAsFixed(2)}*');
    buffer.writeln('─────────────────────────');
    buffer.writeln('');
    buffer.writeln('Thank you for shopping with us! 🙏');
    buffer.writeln('_Powered by Pegas Flex POS_');
    
    return buffer.toString();
  }

  Future<void> _saveBillToHistory() async {
    try {
      final billProvider = Provider.of<FirebaseBillProvider>(context, listen: false);
      final productProvider = Provider.of<FirebaseProductProvider>(context, listen: false);
      
      // First, reduce stock for all products in the bill
      await productProvider.reduceStockForBillingItems(widget.billingItems);
      
      // Create bill object
      final bill = Bill(
        billNumber: widget.billNumber,
        customerName: selectedCustomer?.name ?? 'Walk-in Customer',
        customerPhone: selectedCustomer?.phone ?? '',
        items: widget.billingItems,
        subtotal: subtotalAmount,
        discount: discountAmount,
        tax: 0.0, // You can add tax calculation if needed
        totalAmount: finalAmount,
        paymentMethod: 'Cash', // You can add payment method selection
        timestamp: DateTime.now(),
      );
      
      // Save bill to Firestore
      await billProvider.addBill(bill);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving bill: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow; // Re-throw to prevent further processing if stock reduction fails
    }
  }

  void _saveBill() async {
    try {
      await _saveBillToHistory();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill saved to cloud successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving bill: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }
}

class CustomerSelectionDialog extends StatefulWidget {
  final Function(Customer) onCustomerSelected;

  const CustomerSelectionDialog({
    super.key,
    required this.onCustomerSelected,
  });

  @override
  State<CustomerSelectionDialog> createState() => _CustomerSelectionDialogState();
}

class _CustomerSelectionDialogState extends State<CustomerSelectionDialog> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;

  // New customer form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _loadCustomers();
    _animationController.forward();
    
    _searchController.addListener(_filterCustomers);
  }

  void _loadCustomers() async {
    try {
      final customerProvider = Provider.of<FirebaseCustomerProvider>(context, listen: false);
      await customerProvider.loadCustomers();
      
      if (mounted) {
        setState(() {
          _customers = customerProvider.customers;
          _filteredCustomers = _customers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _customers = [];
          _filteredCustomers = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading customers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        return customer.shopName.toLowerCase().contains(query) ||
               customer.phone.contains(query) ||
               customer.area.toLowerCase().contains(query);
      }).toList();
    });
  }



  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).cardColor,
                      Theme.of(context).cardColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Select Customer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    
                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).primaryColor,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.search),
                            text: 'Existing Customers',
                          ),
                          Tab(
                            icon: Icon(Icons.person_add),
                            text: 'Add New',
                          ),
                        ],
                      ),
                    ),
                    
                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildExistingCustomersTab(),
                          _buildNewCustomerTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExistingCustomersTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search customers by name, phone, or email...',
              prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterCustomers();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[100]
                  : Colors.grey[800],
            ),
          ),
        ),
        
        // Customer List
        Expanded(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading customers...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : _filteredCustomers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.white60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No customers found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search criteria',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildCustomerCard(customer),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          widget.onCustomerSelected(customer);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.shopName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelpers.getHeadingColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
                      style: TextStyle(
                        color: ThemeHelpers.getSecondaryTextColor(context),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      customer.area,
                      style: TextStyle(
                        color: ThemeHelpers.getSecondaryTextColor(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildNewCustomerTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelpers.getHeadingColor(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name *',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter customer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number *',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final customer = Customer(
                          id: 'CUST${DateTime.now().millisecondsSinceEpoch}',
                          shopName: _nameController.text,
                          phone: _phoneController.text,
                          area: _emailController.text,
                        );
                        widget.onCustomerSelected(customer);
                        Navigator.pop(context);
                        
                        // Show success animation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('Customer "${customer.shopName}" added successfully!'),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Customer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

// Animation Configuration Helper Class
class AnimationConfiguration {
  static Widget staggeredList({
    required int position,
    required Duration duration,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 100 + (position * 50)),
      curve: Curves.easeOut,
      child: child,
    );
  }
}

// Slide Animation Widget
class SlideAnimation extends StatefulWidget {
  final double verticalOffset;
  final Widget child;

  const SlideAnimation({
    super.key,
    required this.verticalOffset,
    required this.child,
  });

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, widget.verticalOffset / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}

// Fade In Animation Widget
class FadeInAnimation extends StatefulWidget {
  final Widget child;

  const FadeInAnimation({
    super.key,
    required this.child,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}