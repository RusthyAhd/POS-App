import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/billing_item.dart';

class BillHistoryScreen extends StatefulWidget {
  const BillHistoryScreen({super.key});

  @override
  State<BillHistoryScreen> createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  List<Bill> _bills = [];
  List<Bill> _filteredBills = [];
  DateTime? _selectedDate;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBillHistory();
  }

  void _loadBillHistory() {
    // Sample bill data - In a real app, this would come from a database
    _bills = _generateSampleBills();
    _filteredBills = _bills;
  }

  List<Bill> _generateSampleBills() {
    // Generate sample bills for demonstration
    List<Bill> sampleBills = [];
    final now = DateTime.now();
    
    for (int i = 0; i < 20; i++) {
      final billDate = now.subtract(Duration(days: i));
      sampleBills.add(
        Bill(
          id: 'BILL${1000 + i}',
          date: billDate,
          customer: i % 3 == 0 ? Customer(
            id: 'CUST$i',
            name: 'Customer ${i + 1}',
            phone: '+94 ${7000000000 + i}',
            email: 'customer${i + 1}@email.com',
          ) : null,
          items: [
            BillingItem(
              product: Product(
                id: 'PROD$i',
                name: 'Product ${i + 1}',
                description: 'Sample product',
                price: 100.0 + (i * 10),
                category: 'Electronics',
                image: '',
              ),
              quantity: 1 + (i % 3),
              price: 100.0 + (i * 10),
            ),
          ],
          subtotal: (100.0 + (i * 10)) * (1 + (i % 3)),
          discountPercentage: i % 4 == 0 ? 10.0 : 0.0,
          discountAmount: i % 4 == 0 ? ((100.0 + (i * 10)) * (1 + (i % 3))) * 0.1 : 0.0,
          total: i % 4 == 0 
              ? ((100.0 + (i * 10)) * (1 + (i % 3))) * 0.9 
              : (100.0 + (i * 10)) * (1 + (i % 3)),
          paymentMethod: i % 2 == 0 ? 'Cash' : 'Card',
        ),
      );
    }
    
    return sampleBills;
  }

  void _filterBills() {
    setState(() {
      _filteredBills = _bills.where((bill) {
        bool matchesSearch = _searchController.text.isEmpty ||
            bill.id.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            (bill.customer?.name.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);

        bool matchesDate = _selectedDate == null ||
            (bill.date.year == _selectedDate!.year &&
             bill.date.month == _selectedDate!.month &&
             bill.date.day == _selectedDate!.day);

        bool matchesFilter = _selectedFilter == 'All' ||
            (_selectedFilter == 'Today' && _isToday(bill.date)) ||
            (_selectedFilter == 'This Week' && _isThisWeek(bill.date)) ||
            (_selectedFilter == 'This Month' && _isThisMonth(bill.date));

        return matchesSearch && matchesDate && matchesFilter;
      }).toList();
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1)));
  }

  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill History'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _filterBills(),
                  decoration: InputDecoration(
                    hintText: 'Search by Bill ID or Customer Name',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterBills();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter Chips and Date Picker
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: ['All', 'Today', 'This Week', 'This Month']
                            .map((filter) => FilterChip(
                                  label: Text(filter),
                                  selected: _selectedFilter == filter,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedFilter = filter;
                                        _selectedDate = null;
                                      });
                                      _filterBills();
                                    }
                                  },
                                  selectedColor: Colors.white,
                                  checkmarkColor: Theme.of(context).primaryColor,
                                ))
                            .toList(),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                            _selectedFilter = 'Custom';
                          });
                          _filterBills();
                        }
                      },
                      icon: const Icon(Icons.calendar_today, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bills List
          Expanded(
            child: _filteredBills.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBills.length,
                    itemBuilder: (context, index) {
                      return _buildBillCard(_filteredBills[index]);
                    },
                  ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildBillCard(Bill bill) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showBillDetails(bill),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bill.id,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(bill.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bill.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(bill.date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              if (bill.customer != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      bill.customer!.name,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${bill.items.length} item(s)',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (bill.discountAmount > 0)
                        Text(
                          'LKR ${bill.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      Text(
                        'LKR ${bill.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Bills Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No bills match your current filters',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showBillDetails(Bill bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Bill Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bill.id,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(bill.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          bill.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Date and Customer Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(DateFormat('dd MMM yyyy, hh:mm a').format(bill.date)),
                          ],
                        ),
                        if (bill.customer != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16),
                              const SizedBox(width: 8),
                              Text(bill.customer!.name),
                            ],
                          ),
                          if (bill.customer!.phone.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16),
                                const SizedBox(width: 8),
                                Text(bill.customer!.phone),
                              ],
                            ),
                          ],
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.payment, size: 16),
                            const SizedBox(width: 8),
                            Text(bill.paymentMethod),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Items List
                  ...bill.items.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'LKR ${item.price.toStringAsFixed(2)} x ${item.quantity}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'LKR ${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )).toList(),
                  
                  const SizedBox(height: 20),
                  
                  // Bill Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text('LKR ${bill.subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        if (bill.discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Discount (${bill.discountPercentage}%):'),
                              Text(
                                '-Rs.${bill.discountAmount.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'LKR ${bill.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Share bill
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Share functionality will be implemented')),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Print bill
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Print functionality will be implemented')),
                            );
                          },
                          icon: const Icon(Icons.print),
                          label: const Text('Print'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
