import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/billing_item.dart';
import '../widgets/sliding_menu.dart';
import '../utils/theme_helpers.dart';
import '../providers/firebase_product_provider.dart';
import 'bill_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<BillingItem> _billingItems = [];
  int _currentCategoriesLength = 0;
  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeTabController();
  }

  void _initializeTabController() {
    if (_isDisposing) return;
    
    try {
      final productProvider = Provider.of<FirebaseProductProvider>(context, listen: false);
      if (_currentCategoriesLength != productProvider.categories.length) {
        // Safely dispose old controller
        if (_tabController != null) {
          _tabController!.dispose();
          _tabController = null;
        }
        _tabController = TabController(length: productProvider.categories.length, vsync: this);
        _currentCategoriesLength = productProvider.categories.length;
      }
    } catch (e) {
      // Handle any errors during initialization
      debugPrint('Error initializing TabController: $e');
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }



  void _addToBilling(Product product) {
    setState(() {
      // Check if product already exists in billing items
      final existingIndex = _billingItems.indexWhere((item) => item.id == product.id);
      if (existingIndex != -1) {
        // If exists, increase quantity
        _billingItems[existingIndex] = _billingItems[existingIndex].copyWith(
          quantity: _billingItems[existingIndex].quantity + 1,
        );
      } else {
        // If doesn't exist, add new billing item
        _billingItems.add(BillingItem(product: product));
      }
    });
  }

  void _removeFromBilling(int index) {
    setState(() {
      _billingItems.removeAt(index);
    });
  }

  double get _totalBill {
    return _billingItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'anchor':
        return Icons.opacity_rounded; // Milk/liquid related
      case 'kotmalee':
        return Icons.local_cafe_rounded; // Tea/coffee
      case 'sunsilk':
        return Icons.face_retouching_natural_rounded; // Beauty/hair care
      case 'baby cheramy':
        return Icons.child_care_rounded; // Baby products
      case 'beverages':
        return Icons.local_drink_rounded; // Drinks
      case 'snacks':
        return Icons.cookie_rounded; // Snacks/biscuits
      case 'rice & grains':
        return Icons.grain_rounded; // Rice/grains
      default:
        return Icons.inventory_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'anchor':
        return const Color(0xFF1976D2); // Blue for dairy
      case 'kotmalee':
        return const Color(0xFF388E3C); // Green for tea
      case 'sunsilk':
        return const Color(0xFFE91E63); // Pink for beauty
      case 'baby cheramy':
        return const Color(0xFFFF9800); // Orange for baby products
      case 'beverages':
        return const Color(0xFF3F51B5); // Indigo for beverages
      case 'snacks':
        return const Color(0xFFFF5722); // Deep orange for snacks
      case 'rice & grains':
        return const Color(0xFF795548); // Brown for grains
      default:
        return const Color(0xFF051650);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseProductProvider>(
      builder: (context, productProvider, child) {
        final filteredProducts = productProvider.getFilteredProducts(_selectedCategory, _searchController.text);
        
        // Check if we need to update tab controller
        if (_currentCategoriesLength != productProvider.categories.length) {
          _initializeTabController();
        }
        
        return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pegas Flex',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        elevation: 0,
      ),
      drawer: const SlidingMenu(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Billing section
              if (_billingItems.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Current Bill',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'Total: Rs. ${_totalBill.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: _billingItems.length > 3 ? 240 : double.infinity, // 80px per item * 3 = 240px
                        ),
                        child: SingleChildScrollView(
                          physics: _billingItems.length > 3 
                              ? const AlwaysScrollableScrollPhysics() 
                              : const NeverScrollableScrollPhysics(),
                          child: Column(
                            children: _billingItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(item.category),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(item.category),
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: ThemeHelpers.getPrimaryTextColor(context),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Text(
                                                'Rs. ${item.price.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context).primaryColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                ' x ${item.quantity}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ThemeHelpers.getSecondaryGreyColor(context),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'Total: Rs. ${(item.price * item.quantity).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: ThemeHelpers.getSubtleTextColor(context),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () => _showEditBillItemDialog(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Theme.of(context).brightness == Brightness.dark
                                                    ? Colors.white.withValues(alpha: 0.3)
                                                    : Colors.transparent,
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        InkWell(
                                          onTap: () => _removeFromBilling(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Theme.of(context).brightness == Brightness.dark
                                                    ? Colors.white.withValues(alpha: 0.3)
                                                    : Colors.transparent,
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                ],
              ),
            ),

              // Search bar
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[100]
                        : Colors.grey[800],
                  ),
                ),
              ),
              
              // Category tabs
              if (_tabController != null && _tabController!.length == productProvider.categories.length)
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    onTap: (index) {
                      if (index < productProvider.categories.length) {
                        setState(() {
                          _selectedCategory = productProvider.categories[index];
                        });
                      }
                    },
                    tabs: productProvider.categories.map((category) => Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          category,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              
              // Products grid
              filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(filteredProducts[index]);
                      },
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: _billingItems.isNotEmpty 
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BillDetailsScreen(
                      billingItems: _billingItems,
                      billNumber: 'BILL-${DateTime.now().millisecondsSinceEpoch}',
                    ),
                  ),
                );
                
                // Clear billing items if bill was saved/shared
                if (result == true && mounted) {
                  setState(() {
                    _billingItems.clear();
                  });
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.receipt_long_rounded),
              label: Text('Bill Rs. ${_totalBill.toStringAsFixed(2)}'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(product.category);
    
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ]
              : [
                  Colors.white.withValues(alpha: 0.7),
                  Colors.white.withValues(alpha: 0.3),
                ],
        ),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.2),
          width: Theme.of(context).brightness == Brightness.dark ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () {
              _addToBilling(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${product.name} added to bill',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: categoryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(milliseconds: 1500),
                ),
              );
            },
            onLongPress: () {
              _showProductDetails(product);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 140,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product icon with glassmorphism effect
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            categoryColor.withValues(alpha: 0.8),
                            categoryColor.withValues(alpha: 0.6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background blur effect
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.2),
                                    Colors.white.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Icon
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                _getCategoryIcon(product.category),
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Shine effect
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: isDark ? 0.3 : 0.6),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Product details with enhanced typography
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Product name
                        Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: ThemeHelpers.getHeadingColor(context),
                            letterSpacing: 0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Price and stock row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Price with currency
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  colors: [
                                    categoryColor.withValues(alpha: 0.1),
                                    categoryColor.withValues(alpha: 0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color: categoryColor.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Rs. ${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                            
                            // Stock indicator with glassmorphism
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: product.stock > 10
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : Colors.orange.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: product.stock > 10
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : Colors.orange.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${product.stock}',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: product.stock > 10
                                      ? (Theme.of(context).brightness == Brightness.dark ? Colors.green[300] : Colors.green[700])
                                      : (Theme.of(context).brightness == Brightness.dark ? Colors.orange[300] : Colors.orange[700]),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or category filter',
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelpers.getSecondaryGreyColor(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
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
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[600] 
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Product icon
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getCategoryColor(product.category).withValues(alpha: 0.8),
                          _getCategoryColor(product.category),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(product.category),
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Product details
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ThemeHelpers.getBrightTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.category,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeHelpers.getContentTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeHelpers.getSecondaryTextColor(context),
                          ),
                        ),
                        Text(
                          'Rs. ${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'In Stock',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeHelpers.getSecondaryTextColor(context),
                          ),
                        ),
                        Text(
                          '${product.stock} units',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: product.stock > 10 
                                ? (Theme.of(context).brightness == Brightness.dark ? Colors.green[300] : Colors.green[700])
                                : (Theme.of(context).brightness == Brightness.dark ? Colors.orange[300] : Colors.orange[700]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Edit product
                        },
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _addToBilling(product);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to bill'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart_rounded),
                        label: const Text('Add to Bill'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Extra spacing at bottom
              ],
            ),
          ),
          );
        },
      ),
    );
  }

  void _showEditBillItemDialog(int index) {
    final item = _billingItems[index];
    final priceController = TextEditingController(text: item.price.toString());
    final quantityController = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getCategoryColor(item.category),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Item',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14, 
                      color: ThemeHelpers.getSecondaryGreyColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Original price display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Original Price:'),
                    Text(
                      'Rs. ${item.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Current price input
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onTap: () {
                  // Auto-select all text when field is tapped
                  priceController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: priceController.text.length,
                  );
                },
                decoration: InputDecoration(
                  labelText: 'Current Price (Rs.)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),

              // Quantity input
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onTap: () {
                  // Auto-select all text when field is tapped
                  quantityController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: quantityController.text.length,
                  );
                },
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),

              // Total calculation display
              ValueListenableBuilder(
                valueListenable: priceController,
                builder: (context, value, child) {
                  return ValueListenableBuilder(
                    valueListenable: quantityController,
                    builder: (context, value, child) {
                      final price = double.tryParse(priceController.text) ?? 0.0;
                      final quantity = int.tryParse(quantityController.text) ?? 0;
                      final total = price * quantity;
                      
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Rs. ${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          // Delete button
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation(index);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          
          // Update button
          ElevatedButton.icon(
            onPressed: () {
              final newPrice = double.tryParse(priceController.text);
              final newQuantity = int.tryParse(quantityController.text);
              
              if (newPrice != null && newPrice > 0 && newQuantity != null && newQuantity > 0) {
                _updateBillItem(index, newPrice, newQuantity);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} updated successfully'),
                    backgroundColor: Colors.green,
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid price and quantity'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.update),
            label: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _updateBillItem(int index, double newPrice, int newQuantity) {
    setState(() {
      _billingItems[index] = _billingItems[index].copyWith(
        price: newPrice,
        quantity: newQuantity,
      );
    });
  }

  void _showDeleteConfirmation(int index) {
    final item = _billingItems[index];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to remove "${item.name}" from the bill?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFromBilling(index);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name} removed from bill'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(milliseconds: 1500),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

}
