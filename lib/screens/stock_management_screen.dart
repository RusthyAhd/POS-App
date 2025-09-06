import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../models/stock_update.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<StockUpdate> _stockUpdates = [];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Electronics',
    'Clothing',
    'Food & Beverages',
    'Books',
    'Home & Garden',
    'Sports',
    'Beauty',
    'Automotive',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    // Sample product data - In a real app, this would come from a database
    _products = _generateSampleProducts();
    _filteredProducts = _products;
  }

  List<Product> _generateSampleProducts() {
    List<Product> sampleProducts = [];
    final categories = ['Electronics', 'Clothing', 'Food & Beverages', 'Books', 'Home & Garden'];
    
    for (int i = 0; i < 50; i++) {
      sampleProducts.add(
        Product(
          id: 'PROD${1000 + i}',
          name: 'Product ${i + 1}',
          description: 'Sample product description for product ${i + 1}',
          price: 50.0 + (i * 25),
          category: categories[i % categories.length],
          image: '',
          stock: (i % 20) + 5, // Stock between 5-25
        ),
      );
    }
    
    return sampleProducts;
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        bool matchesSearch = _searchController.text.isEmpty ||
            product.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            product.id.toLowerCase().contains(_searchController.text.toLowerCase());

        bool matchesCategory = _selectedCategory == 'All' ||
            product.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showStockHistory,
            icon: const Icon(Icons.history),
            tooltip: 'Stock History',
          ),
          IconButton(
            onPressed: _showLowStockAlert,
            icon: const Icon(Icons.warning_amber_rounded),
            tooltip: 'Low Stock Alert',
          ),
        ],
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
                  onChanged: (value) => _filterProducts(),
                  decoration: InputDecoration(
                    hintText: 'Search products by name or ID',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterProducts();
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
                
                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                              _filterProducts();
                            }
                          },
                          selectedColor: Colors.white,
                          checkmarkColor: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_filteredProducts[index]);
                    },
                  ),
          ),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isLowStock = product.stock < 10;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${product.id}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'LKR ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLowStock ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isLowStock ? Colors.red : Colors.green,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLowStock ? Icons.warning : Icons.check_circle,
                            size: 16,
                            color: isLowStock ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.stock} units',
                            style: TextStyle(
                              color: isLowStock ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUpdateStockDialog(product),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Update Stock'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditProductDialog(product),
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Edit Product'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No products match your current filters',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showUpdateStockDialog(Product product) {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    String updateType = 'add'; // 'add', 'remove', 'adjust'

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Update Stock - ${product.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Stock: ${product.stock} units'),
                const SizedBox(height: 16),
                
                // Update Type
                const Text('Update Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: updateType,
                  onChanged: (value) => setState(() => updateType = value!),
                  items: const [
                    DropdownMenuItem(value: 'add', child: Text('Add Stock')),
                    DropdownMenuItem(value: 'remove', child: Text('Remove Stock')),
                    DropdownMenuItem(value: 'adjust', child: Text('Adjust to Exact Count')),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Quantity
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: updateType == 'adjust' ? 'New Stock Count' : 'Quantity',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.inventory),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Reason
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (quantityController.text.isNotEmpty) {
                  _updateStock(product, updateType, int.parse(quantityController.text), reasonController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStock(Product product, String type, int quantity, String reason) {
    final oldStock = product.stock;
    int newStock;

    switch (type) {
      case 'add':
        newStock = oldStock + quantity;
        break;
      case 'remove':
        newStock = (oldStock - quantity).clamp(0, double.infinity).toInt();
        break;
      case 'adjust':
        newStock = quantity;
        break;
      default:
        return;
    }

    // Create stock update record
    final update = StockUpdate(
      productId: product.id,
      productName: product.name,
      oldStock: oldStock,
      newStock: newStock,
      quantity: type == 'adjust' ? newStock - oldStock : quantity,
      type: type,
      date: DateTime.now(),
      reason: reason,
    );

    _stockUpdates.add(update);

    // Update product stock
    final productIndex = _products.indexWhere((p) => p.id == product.id);
    if (productIndex != -1) {
      setState(() {
        _products[productIndex] = Product(
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          category: product.category,
          image: product.image,
          stock: newStock,
        );
      });
      _filterProducts();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stock updated successfully for ${product.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());
    String selectedCategory = product.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price (Rs.)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  onChanged: (value) => setState(() => selectedCategory = value!),
                  items: _categories.skip(1).map((category) => 
                    DropdownMenuItem(value: category, child: Text(category))).toList(),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  _updateProduct(product, nameController.text, descriptionController.text, 
                               double.parse(priceController.text), selectedCategory);
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProduct(Product product, String name, String description, double price, String category) {
    final productIndex = _products.indexWhere((p) => p.id == product.id);
    if (productIndex != -1) {
      setState(() {
        _products[productIndex] = Product(
          id: product.id,
          name: name,
          description: description,
          price: price,
          category: category,
          image: product.image,
          stock: product.stock,
        );
      });
      _filterProducts();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    String selectedCategory = _categories[1]; // Skip 'All'

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price (Rs.)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Initial Stock',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  onChanged: (value) => setState(() => selectedCategory = value!),
                  items: _categories.skip(1).map((category) => 
                    DropdownMenuItem(value: category, child: Text(category))).toList(),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && 
                    priceController.text.isNotEmpty && 
                    stockController.text.isNotEmpty) {
                  _addProduct(nameController.text, descriptionController.text, 
                           double.parse(priceController.text), selectedCategory, 
                           int.parse(stockController.text));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _addProduct(String name, String description, double price, String category, int stock) {
    final newProduct = Product(
      id: 'PROD${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      price: price,
      category: category,
      image: '',
      stock: stock,
    );

    setState(() {
      _products.add(newProduct);
    });
    _filterProducts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showStockHistory() {
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
                
                const Text(
                  'Stock Update History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: _stockUpdates.isEmpty
                      ? const Center(
                          child: Text('No stock updates yet'),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _stockUpdates.length,
                          itemBuilder: (context, index) {
                            final update = _stockUpdates.reversed.toList()[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(update.productName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${update.oldStock} → ${update.newStock} units'),
                                    Text(
                                      '${update.type.toUpperCase()} • ${update.date.toString().split('.')[0]}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                    if (update.reason.isNotEmpty)
                                      Text('Reason: ${update.reason}', 
                                           style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: _getUpdateTypeColor(update.type),
                                  child: Icon(
                                    _getUpdateTypeIcon(update.type),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLowStockAlert() {
    final lowStockProducts = _products.where((product) => product.stock < 10).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Low Stock Alert'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: lowStockProducts.isEmpty
              ? const Text('All products have sufficient stock!')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${lowStockProducts.length} product(s) have low stock:'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: lowStockProducts.length,
                        itemBuilder: (context, index) {
                          final product = lowStockProducts[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text('Only ${product.stock} units left'),
                            leading: const Icon(Icons.warning, color: Colors.red),
                            trailing: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showUpdateStockDialog(product);
                              },
                              child: const Text('Update'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getUpdateTypeColor(String type) {
    switch (type) {
      case 'add':
        return Colors.green;
      case 'remove':
        return Colors.red;
      case 'adjust':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getUpdateTypeIcon(String type) {
    switch (type) {
      case 'add':
        return Icons.add;
      case 'remove':
        return Icons.remove;
      case 'adjust':
        return Icons.edit;
      default:
        return Icons.inventory;
    }
  }
}
