import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  List<Customer> _customers = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedArea = 'All';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() {
    _customers = _generateSampleCustomers();
  }

  List<Customer> _generateSampleCustomers() {
    final areas = ['Colombo 01', 'Colombo 02', 'Colombo 03', 'Colombo 04', 'Colombo 05', 'Gampaha', 'Kandy', 'Galle'];
    final shopNames = [
      'Super Market Lanka', 'City Mart', 'Fresh Foods', 'Green Valley Store',
      'Quick Shop', 'Family Store', 'Corner Shop', 'Daily Needs', 'Express Mart',
      'Royal Store', 'Golden Shop', 'Prime Market', 'Best Buy Store', 'Smart Shop'
    ];
    
    List<Customer> sampleCustomers = [];
    for (int i = 0; i < 15; i++) {
      sampleCustomers.add(
        Customer(
          id: 'CUST${String.fromCharCode(65 + (i ~/ 10))}${(i % 10).toString().padLeft(3, '0')}',
          shopName: shopNames[i % shopNames.length],
          phone: '077${(2000000 + i).toString()}',
          area: areas[i % areas.length],
        ),
      );
    }
    return sampleCustomers;
  }

  List<String> get _areas {
    final areas = _customers.map((c) => c.area).toSet().toList();
    areas.sort();
    return ['All', ...areas];
  }

  List<Customer> get _filteredCustomers {
    return _customers.where((customer) {
      bool matchesSearch = _searchController.text.isEmpty ||
          customer.shopName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          customer.phone.contains(_searchController.text) ||
          customer.area.toLowerCase().contains(_searchController.text.toLowerCase());

      bool matchesArea = _selectedArea == 'All' || customer.area == _selectedArea;

      return matchesSearch && matchesArea;
    }).toList();
  }

  Map<String, List<Customer>> get _customersByArea {
    final Map<String, List<Customer>> grouped = {};
    for (final customer in _filteredCustomers) {
      if (!grouped.containsKey(customer.area)) {
        grouped[customer.area] = [];
      }
      grouped[customer.area]!.add(customer);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customer Management',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]
                      : [Colors.white.withOpacity(0.7), Colors.white.withOpacity(0.3)],
                ),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search customers...',
                  prefixIcon: Icon(Icons.search, 
                    color: Theme.of(context).primaryColor.withOpacity(0.7)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),

            // Area Filter Chips
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _areas.length,
                itemBuilder: (context, index) {
                  final area = _areas[index];
                  final isSelected = _selectedArea == area;
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(area),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedArea = area;
                        });
                      },
                      backgroundColor: Colors.transparent,
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Theme.of(context).dividerColor,
                        width: 1.5,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Customer List
            Expanded(
              child: _buildCustomerList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomerDialog,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Customer'),
      ),
    );
  }

  Widget _buildCustomerList() {
    if (_filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No customers found',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).primaryColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedArea == 'All') {
      return _buildAreaWiseList();
    } else {
      return _buildSingleAreaList();
    }
  }

  Widget _buildAreaWiseList() {
    final groupedCustomers = _customersByArea;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedCustomers.length,
      itemBuilder: (context, index) {
        final area = groupedCustomers.keys.elementAt(index);
        final customers = groupedCustomers[area]!;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Area Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      area,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${customers.length} shops',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Customers in this area
              ...customers.map((customer) => _buildCustomerCard(customer)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSingleAreaList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        return _buildCustomerCard(_filteredCustomers[index]);
      },
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]
              : [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.6)],
        ),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.store,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.shopName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        customer.phone,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                ],
              ),
            ),
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                  onTap: () => _showEditCustomerDialog(customer),
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  onTap: () => _deleteCustomer(customer),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomerDialog() {
    _showCustomerDialog();
  }

  void _showEditCustomerDialog(Customer customer) {
    _showCustomerDialog(customer: customer);
  }

  void _showCustomerDialog({Customer? customer}) {
    final isEditing = customer != null;
    final shopNameController = TextEditingController(text: customer?.shopName ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final areaController = TextEditingController(text: customer?.area ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit : Icons.add,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'Edit Customer' : 'Add New Customer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildTextField(
                  controller: shopNameController,
                  label: 'Shop Name',
                  icon: Icons.store,
                  required: true,
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  required: true,
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: areaController,
                  label: 'Area',
                  icon: Icons.location_city,
                  required: true,
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_validateForm([shopNameController, phoneController, areaController])) {
                            _saveCustomer(
                              customer: customer,
                              shopName: shopNameController.text,
                              phone: phoneController.text,
                              area: areaController.text,
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(isEditing ? 'Update' : 'Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: '$label${required ? ' *' : ''}',
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
    );
  }

  bool _validateForm(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      if (controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return false;
      }
    }
    return true;
  }

  void _saveCustomer({
    Customer? customer,
    required String shopName,
    required String phone,
    required String area,
  }) {
    if (customer != null) {
      // Edit existing customer
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = customer.copyWith(
          shopName: shopName,
          phone: phone,
          area: area,
        );
      }
    } else {
      // Add new customer
      final newCustomer = Customer(
        id: 'CUST${DateTime.now().millisecondsSinceEpoch}',
        shopName: shopName,
        phone: phone,
        area: area,
      );
      _customers.add(newCustomer);
    }
    
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(customer != null ? 'Customer updated successfully' : 'Customer added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteCustomer(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.shopName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _customers.removeWhere((c) => c.id == customer.id);
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Customer deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}