import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../models/billing_item.dart';
import '../models/customer.dart';
import '../models/product.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Bill> _bills = [];
  String _selectedPeriod = 'Daily';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadReportData() {
    // Sample bill data for reports - In a real app, this would come from a database
    _bills = _generateSampleBills();
  }

  List<Bill> _generateSampleBills() {
    List<Bill> sampleBills = [];
    final now = DateTime.now();
    
    for (int i = 0; i < 90; i++) {
      final billDate = now.subtract(Duration(days: i));
      final billCount = (i % 5) + 1; // 1-5 bills per day
      
      for (int j = 0; j < billCount; j++) {
        sampleBills.add(
          Bill(
            id: 'BILL${(i * 5) + j + 1000}',
            date: billDate.add(Duration(hours: j * 2)),
            customer: i % 3 == 0 ? Customer(
              id: 'CUST${i + j}',
              name: 'Customer ${i + j + 1}',
              phone: '+94 ${7000000000 + i + j}',
              email: 'customer${i + j + 1}@email.com',
            ) : null,
            items: [
              BillingItem(
                product: Product(
                  id: 'PROD${i + j}',
                  name: 'Product ${i + j + 1}',
                  description: 'Sample product',
                  price: 100.0 + ((i + j) * 10),
                  category: ['Electronics', 'Clothing', 'Food & Beverages'][i % 3],
                  image: '',
                ),
                quantity: 1 + ((i + j) % 3),
                price: 100.0 + ((i + j) * 10),
              ),
            ],
            subtotal: (100.0 + ((i + j) * 10)) * (1 + ((i + j) % 3)),
            discountPercentage: (i + j) % 4 == 0 ? 10.0 : 0.0,
            discountAmount: (i + j) % 4 == 0 ? 
                ((100.0 + ((i + j) * 10)) * (1 + ((i + j) % 3))) * 0.1 : 0.0,
            total: (i + j) % 4 == 0 ? 
                ((100.0 + ((i + j) * 10)) * (1 + ((i + j) % 3))) * 0.9 : 
                (100.0 + ((i + j) * 10)) * (1 + ((i + j) % 3)),
            paymentMethod: (i + j) % 2 == 0 ? 'Cash' : 'Card',
          ),
        );
      }
    }
    
    return sampleBills;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports & Analytics',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).appBarTheme.foregroundColor,
          labelColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedLabelColor: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Sales'),
            Tab(text: 'Products'),
            Tab(text: 'Customers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSalesTab(),
          _buildProductsTab(),
          _buildCustomersTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final today = DateTime.now();
    final todayBills = _bills.where((bill) => _isSameDay(bill.date, today)).toList();
    final thisWeekBills = _bills.where((bill) => _isThisWeek(bill.date)).toList();
    final thisMonthBills = _bills.where((bill) => _isThisMonth(bill.date)).toList();

    final todayRevenue = todayBills.fold<double>(0.0, (sum, bill) => sum + bill.total);
    final weekRevenue = thisWeekBills.fold<double>(0.0, (sum, bill) => sum + bill.total);
    final monthRevenue = thisMonthBills.fold<double>(0.0, (sum, bill) => sum + bill.total);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          Row(
            children: [
              const Text(
                'Quick Stats',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showDatePicker(),
                icon: const Icon(Icons.calendar_today),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Today',
                  'LKR ${todayRevenue.toStringAsFixed(2)}',
                  '${todayBills.length} orders',
                  Colors.green,
                  Icons.today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'This Week',
                  'LKR ${weekRevenue.toStringAsFixed(2)}',
                  '${thisWeekBills.length} orders',
                  Colors.blue,
                  Icons.date_range,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'This Month',
                  'LKR ${monthRevenue.toStringAsFixed(2)}',
                  '${thisMonthBills.length} orders',
                  Colors.purple,
                  Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'All Time',
                  'LKR ${_bills.fold<double>(0.0, (sum, bill) => sum + bill.total).toStringAsFixed(2)}',
                  '${_bills.length} orders',
                  Colors.orange,
                  Icons.trending_up,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Trends
          const Text(
            'Recent Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildTrendChart(),

          const SizedBox(height: 24),

          // Top Categories
          const Text(
            'Top Selling Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildTopCategories(),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          Row(
            children: [
              const Text(
                'Sales Analysis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedPeriod,
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                },
                items: ['Daily', 'Weekly', 'Monthly'].map((period) {
                  return DropdownMenuItem(value: period, child: Text(period));
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sales Summary
          _buildSalesSummary(),

          const SizedBox(height: 24),

          // Payment Methods
          const Text(
            'Payment Methods',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildPaymentMethodsChart(),

          const SizedBox(height: 24),

          // Hourly Sales (for daily view)
          if (_selectedPeriod == 'Daily') ...[
            const Text(
              'Hourly Sales Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildHourlySales(),
          ],
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Performance',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Top Products
          _buildTopProducts(),

          const SizedBox(height: 24),

          // Category Performance
          const Text(
            'Category Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildCategoryPerformance(),

          const SizedBox(height: 24),

          // Low Stock Alert
          const Text(
            'Inventory Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildInventoryStatus(),
        ],
      ),
    );
  }

  Widget _buildCustomersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Customer Summary
          _buildCustomerSummary(),

          const SizedBox(height: 24),

          // Top Customers
          const Text(
            'Top Customers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildTopCustomers(),

          const SizedBox(height: 24),

          // Customer Types Distribution
          const Text(
            'Customer Types',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildCustomerTypes(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Card(
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, color: Colors.white, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    final last7Days = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final dayBills = _bills.where((bill) => _isSameDay(bill.date, date)).toList();
      final revenue = dayBills.fold<double>(0.0, (sum, bill) => sum + bill.total);
      return {
        'day': DateFormat('E').format(date),
        'revenue': revenue,
        'orders': dayBills.length,
      };
    });

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last 7 Days Revenue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: last7Days.map((data) {
                  final maxRevenue = last7Days.map((d) => d['revenue'] as double).reduce((a, b) => a > b ? a : b);
                  final height = maxRevenue > 0 ? ((data['revenue'] as double) / maxRevenue) * 100 : 0.0;
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'LKR ${(data['revenue'] as double).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: height,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['day'] as String,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategories() {
    final categoryRevenue = <String, double>{};
    
    for (final bill in _bills) {
      for (final item in bill.items) {
        categoryRevenue[item.product.category] = 
            (categoryRevenue[item.product.category] ?? 0) + item.totalPrice;
      }
    }

    final sortedCategories = categoryRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedCategories.take(5).map((entry) {
            final percentage = (entry.value / sortedCategories.first.value) * 100;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('LKR ${entry.value.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSalesSummary() {
    List<Bill> periodBills;
    String periodLabel;

    switch (_selectedPeriod) {
      case 'Daily':
        periodBills = _bills.where((bill) => _isSameDay(bill.date, _selectedDate)).toList();
        periodLabel = DateFormat('dd MMM yyyy').format(_selectedDate);
        break;
      case 'Weekly':
        periodBills = _bills.where((bill) => _isThisWeek(bill.date)).toList();
        periodLabel = 'This Week';
        break;
      case 'Monthly':
        periodBills = _bills.where((bill) => _isThisMonth(bill.date)).toList();
        periodLabel = 'This Month';
        break;
      default:
        periodBills = [];
        periodLabel = '';
    }

    final totalRevenue = periodBills.fold<double>(0.0, (sum, bill) => sum + bill.total);
    final totalOrders = periodBills.length;
    final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
    final totalDiscount = periodBills.fold<double>(0.0, (sum, bill) => sum + bill.discountAmount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Summary - $periodLabel',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem('Total Revenue', 'LKR ${totalRevenue.toStringAsFixed(2)}', Colors.green),
                ),
                Expanded(
                  child: _buildSummaryItem('Total Orders', '$totalOrders', Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem('Avg Order Value', 'LKR ${avgOrderValue.toStringAsFixed(2)}', Colors.orange),
                ),
                Expanded(
                  child: _buildSummaryItem('Total Discounts', 'LKR ${totalDiscount.toStringAsFixed(2)}', Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsChart() {
    final paymentMethods = <String, int>{};
    
    for (final bill in _bills) {
      paymentMethods[bill.paymentMethod] = (paymentMethods[bill.paymentMethod] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: paymentMethods.entries.map((entry) {
            final percentage = (entry.value / _bills.length) * 100;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(entry.key),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.key == 'Cash' ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${percentage.toStringAsFixed(1)}%'),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHourlySales() {
    final hourlySales = <int, double>{};
    
    final todayBills = _bills.where((bill) => _isSameDay(bill.date, DateTime.now())).toList();
    
    for (final bill in todayBills) {
      final hour = bill.date.hour;
      hourlySales[hour] = (hourlySales[hour] ?? 0) + bill.total;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(24, (hour) {
              final sales = hourlySales[hour] ?? 0;
              final maxSales = hourlySales.values.isNotEmpty 
                  ? hourlySales.values.reduce((a, b) => a > b ? a : b) 
                  : 1;
              final height = maxSales > 0 ? (sales / maxSales) * 150 : 0.0;
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (sales > 0)
                    Text(
                      sales.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 8),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: height,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hour % 4 == 0)
                    Text(
                      '${hour.toString().padLeft(2, '0')}h',
                      style: const TextStyle(fontSize: 8),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    final productSales = <String, double>{};
    final productQuantity = <String, int>{};
    
    for (final bill in _bills) {
      for (final item in bill.items) {
        productSales[item.product.name] = 
            (productSales[item.product.name] ?? 0) + item.totalPrice;
        productQuantity[item.product.name] = 
            (productQuantity[item.product.name] ?? 0) + item.quantity;
      }
    }

    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Selling Products',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortedProducts.take(5).map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${productQuantity[entry.key]} units sold',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'LKR ${entry.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPerformance() {
    final categoryData = <String, Map<String, dynamic>>{};
    
    for (final bill in _bills) {
      for (final item in bill.items) {
        final category = item.product.category;
        if (!categoryData.containsKey(category)) {
          categoryData[category] = {'revenue': 0.0, 'quantity': 0};
        }
        categoryData[category]!['revenue'] += item.totalPrice;
        categoryData[category]!['quantity'] += item.quantity;
      }
    }

    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value['revenue'].compareTo(a.value['revenue']));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedCategories.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
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
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${entry.value['quantity']} items sold',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'LKR ${entry.value['revenue'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInventoryStatus() {
    // Mock inventory data - in real app this would come from actual inventory
    final inventoryItems = [
      {'name': 'Product 1', 'stock': 5, 'status': 'Low'},
      {'name': 'Product 2', 'stock': 25, 'status': 'Good'},
      {'name': 'Product 3', 'stock': 2, 'status': 'Critical'},
      {'name': 'Product 4', 'stock': 15, 'status': 'Good'},
      {'name': 'Product 5', 'stock': 0, 'status': 'Out of Stock'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: inventoryItems.map((item) {
            Color statusColor;
            switch (item['status']) {
              case 'Critical':
                statusColor = Colors.red;
                break;
              case 'Low':
                statusColor = Colors.orange;
                break;
              case 'Out of Stock':
                statusColor = Colors.red[800]!;
                break;
              default:
                statusColor = Colors.green;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: statusColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(item['name'] as String),
                  ),
                  Text('${item['stock']} units'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['status'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCustomerSummary() {
    final uniqueCustomers = _bills
        .where((bill) => bill.customer != null)
        .map((bill) => bill.customer!.id)
        .toSet()
        .length;

    final totalCustomerRevenue = _bills
        .where((bill) => bill.customer != null)
        .fold<double>(0.0, (sum, bill) => sum + bill.total);

    final avgCustomerValue = uniqueCustomers > 0 ? totalCustomerRevenue / uniqueCustomers : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Customers',
            '$uniqueCustomers',
            'Active customers',
            Colors.blue,
            Icons.people,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg. Customer Value',
            'LKR ${avgCustomerValue.toStringAsFixed(2)}',
            'Per customer',
            Colors.green,
            Icons.attach_money,
          ),
        ),
      ],
    );
  }

  Widget _buildTopCustomers() {
    final customerRevenue = <String, double>{};
    final customerOrders = <String, int>{};
    
    for (final bill in _bills) {
      if (bill.customer != null) {
        final customerId = bill.customer!.id;
        customerRevenue[customerId] = (customerRevenue[customerId] ?? 0) + bill.total;
        customerOrders[customerId] = (customerOrders[customerId] ?? 0) + 1;
      }
    }

    final sortedCustomers = customerRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedCustomers.take(5).map((entry) {
            final customer = _bills
                .firstWhere((bill) => bill.customer?.id == entry.key)
                .customer!;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      customer.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${customerOrders[entry.key]} orders',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'LKR ${entry.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCustomerTypes() {
    // Mock data for customer types
    final customerTypes = {
      'Regular': 45,
      'Premium': 25,
      'VIP': 15,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: customerTypes.entries.map((entry) {
            final total = customerTypes.values.reduce((a, b) => a + b);
            final percentage = (entry.value / total) * 100;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(entry.key),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCustomerTypeColor(entry.key),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getCustomerTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'vip':
        return Colors.purple;
      case 'premium':
        return Colors.orange;
      case 'regular':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
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

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }
}
