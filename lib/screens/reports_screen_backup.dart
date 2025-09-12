import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  List<Bill> _bills = [];
  String _selectedPeriod = 'Daily';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _loadReportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _loadReportData() async {
    // Sample bill data for reports - In a real app, this would come from a database
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading delay for smooth animation
    await Future.delayed(const Duration(milliseconds: 500));
    
    _bills = _generateSampleBills();
    
    setState(() {
      _isLoading = false;
    });
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
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
              shopName: 'Customer ${i + j + 1}',
              phone: '+94 ${7000000000 + i + j}',
              area: 'Area ${(i + j) % 3 + 1}',
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
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    final today = DateTime.now();
    final todayBills = _bills.where((bill) => _isSameDay(bill.date, today)).toList();
    final thisWeekBills = _bills.where((bill) => _isThisWeek(bill.date)).toList();
    final thisMonthBills = _bills.where((bill) => _isThisMonth(bill.date)).toList();

    final todayRevenue = todayBills.fold<double>(0.0, (sum, bill) => sum + bill.total);
    final weekRevenue = thisWeekBills.fold<double>(0.0, (sum, bill) => sum + bill.total);
    final monthRevenue = thisMonthBills.fold<double>(0.0, (sum, bill) => sum + bill.total);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting and refresh button
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track your business performance',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _refreshData,
                          icon: Icon(
                            Icons.refresh,
                            color: Theme.of(context).primaryColor,
                          ),
                          tooltip: 'Refresh Data',
                        ),
                        IconButton(
                          onPressed: _showDatePicker,
                          icon: Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).primaryColor,
                          ),
                          tooltip: 'Select Date',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Animated Stats Section
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Performance Metrics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // First Row of Stats
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
                      const SizedBox(width: 16),
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
                  const SizedBox(height: 16),
                  
                  // Second Row of Stats
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
                      const SizedBox(width: 16),
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
                ],
              ),
            ),

            // Animated Trend Chart Section
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Recent Performance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildTrendChart(),
                  ),
                ],
              ),
            ),

            // Animated Categories Section
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Top Selling Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildTopCategories(),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  shadowColor: color.withOpacity(0.3),
                  child: InkWell(
                    onTap: () {
                      // Add haptic feedback
                      HapticFeedback.lightImpact();
                      // Could navigate to detailed view
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.9),
                            color,
                            color.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: Colors.white, size: 24),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).cardColor,
                Theme.of(context).cardColor.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Last 7 Days Revenue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: last7Days.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final maxRevenue = last7Days.map((d) => d['revenue'] as double).reduce((a, b) => a > b ? a : b);
                    final height = maxRevenue > 0 ? ((data['revenue'] as double) / maxRevenue) * 120 + 20 : 20.0;
                    
                    return AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'LKR ${(data['revenue'] as double).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 800 + (index * 100)),
                                curve: Curves.easeOutCubic,
                                tween: Tween(begin: 0, end: height),
                                builder: (context, animatedHeight, child) {
                                  return Container(
                                    width: 32,
                                    height: animatedHeight,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).primaryColor,
                                          Theme.of(context).primaryColor.withOpacity(0.7),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['day'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
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

    final maxRevenue = sortedCategories.isNotEmpty ? sortedCategories.first.value : 1;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).cardColor,
                Theme.of(context).cardColor.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.category,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Top Categories by Revenue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (sortedCategories.isEmpty)
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'No category data available',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              else
                ...sortedCategories.take(5).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final categoryEntry = entry.value;
                  final progress = categoryEntry.value / maxRevenue;
                  
                  return AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          (1 - _slideAnimation.value) * 100.0,
                          0.0,
                        ),
                        child: Opacity(
                          opacity: _slideAnimation.value,
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: 16,
                              top: index == 0 ? 0 : 0,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]?.withOpacity(0.3)
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            categoryEntry.key,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Theme.of(context).textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'LKR ${categoryEntry.value.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Theme.of(context).textTheme.bodySmall?.color,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${(progress * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 1000 + (index * 200)),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween(begin: 0, end: progress),
                                  builder: (context, animatedProgress, child) {
                                    return Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: (animatedProgress * 100).round().clamp(0, 100),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Theme.of(context).primaryColor,
                                                    Theme.of(context).primaryColor.withOpacity(0.7),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: ((1 - animatedProgress) * 100).round().clamp(0, 100),
                                            child: const SizedBox(),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
            ],
          ),
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
                      customer.shopName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.shopName,
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

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Reports...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing your business data',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _refreshData() async {
    // Reset animations
    _fadeController.reset();
    _slideController.reset();
    _scaleController.reset();
    
    // Reload data
    _loadReportData();
    
    // Show success feedback
    if (mounted) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Reports refreshed successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
