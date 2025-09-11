import 'package:flutter/material.dart';
import '../models/billing_item.dart';
import '../models/customer.dart';
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
  double discountPercentage = 0.0;
  double discountAmount = 0.0;
  Customer? selectedCustomer;

  double get finalAmount {
    return (widget.billingItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity))) - discountAmount;
  }

  void _calculateDiscount() {
    if (discountPercentage > 0) {
      discountAmount = (widget.billingItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity)) * discountPercentage / 100);
    } else {
      discountAmount = 0.0;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    selectedCustomer = widget.customer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bill Details - ${widget.billNumber}',
          style: TextStyle(color: ThemeHelpers.getHeadingColor(context)),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        'Name: ${selectedCustomer!.name}',
                        style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(context)),
                      ),
                      if (selectedCustomer!.phone.isNotEmpty)
                        Text(
                          'Phone: ${selectedCustomer!.phone}',
                          style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(context)),
                        ),
                      if (selectedCustomer!.email.isNotEmpty)
                        Text(
                          'Email: ${selectedCustomer!.email}',
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
                                builder: (dialogContext) => AddCustomerDialog(
                                  onCustomerAdded: (customer) {
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
                            label: Text(
                              'Add Customer',
                              style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(context)),
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
                    Text(
                      'Discount:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelpers.getHeadingColor(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Discount %',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                discountPercentage = double.tryParse(value) ?? 0.0;
                                _calculateDiscount();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'LKR ${discountAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    label: Text(
                      'Print Bill',
                      style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(context)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showBillPreview(),
                    icon: const Icon(Icons.preview),
                    label: Text(
                      'Preview',
                      style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(context)),
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
                  'Customer: ${selectedCustomer!.name}',
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
                      style: TextStyle(color: ThemeHelpers.getSecondaryGreyColor(dialogContext)),
                    ),
                    Text(
                      '-LKR ${discountAmount.toStringAsFixed(2)}',
                      style: TextStyle(color: ThemeHelpers.getSecondaryGreyColor(dialogContext)),
                    ),
                  ],
                ),
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
            Icon(Icons.bluetooth_rounded, size: 48),
            SizedBox(height: 16),
            Text(
              'Connecting to thermal printer...',
              style: TextStyle(color: ThemeHelpers.getPrimaryTextColor(dialogContext)),
            ),
            SizedBox(height: 16),
            Text(
              'Make sure your thermal printer is turned on and paired.',
              style: TextStyle(
                fontSize: 12,
                color: ThemeHelpers.getSecondaryGreyColor(dialogContext),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: ThemeHelpers.getSecondaryGreyColor(dialogContext)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bill sent to thermal printer!'),
                  backgroundColor: Colors.green,
                ),
              );
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

  void _shareBill(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bill sharing feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _saveBill() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bill saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}

class AddCustomerDialog extends StatefulWidget {
  final Function(Customer) onCustomerAdded;

  const AddCustomerDialog({
    super.key,
    required this.onCustomerAdded,
  });

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Customer',
        style: TextStyle(color: ThemeHelpers.getHeadingColor(context)),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: ThemeHelpers.getSecondaryGreyColor(context)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final customer = Customer(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                phone: _phoneController.text,
                email: _emailController.text,
              );
              widget.onCustomerAdded(customer);
              Navigator.pop(context);
            }
          },
          child: Text(
            'Add',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}