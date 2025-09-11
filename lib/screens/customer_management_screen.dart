import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() {
    // Sample customer data - In a real app, this would come from a database
    _customers = _generateSampleCustomers();
    _filteredCustomers = _customers;
  }

  List<Customer> _generateSampleCustomers() {
    List<Customer> sampleCustomers = [];
    final customerTypes = ['regular', 'premium', 'vip'];
    final cities = ['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata'];
    final states = ['Maharashtra', 'Delhi', 'Karnataka', 'Tamil Nadu', 'West Bengal'];
    
    for (int i = 0; i < 25; i++) {
      sampleCustomers.add(
        Customer(
          id: 'CUST${1000 + i}',
          name: 'Customer ${i + 1}',
          phone: '+94 ${7000000000 + i}',
          email: 'customer${i + 1}@email.com',
          address: '${i + 1}, Sample Street, Sample Area',
          city: cities[i % cities.length],
          state: states[i % states.length],
          pincode: '${400000 + i}',
          dateAdded: DateTime.now().subtract(Duration(days: i * 5)),
          totalPurchases: (i + 1) * 1000.0,
          totalOrders: (i + 1) * 3,
          customerType: customerTypes[i % customerTypes.length],
          notes: i % 3 == 0 ? 'VIP customer with special discounts' : '',
        ),
      );
    }
    
    return sampleCustomers;
  }

  void _filterCustomers() {
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        bool matchesSearch = _searchController.text.isEmpty ||
            customer.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            customer.phone.contains(_searchController.text) ||
            customer.email.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            customer.id.toLowerCase().contains(_searchController.text.toLowerCase());

        bool matchesFilter = _selectedFilter == 'All' ||
            customer.customerType == _selectedFilter.toLowerCase();

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showCustomerStats,
            icon: const Icon(Icons.analytics),
            tooltip: 'Customer Statistics',
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
                  onChanged: (value) => _filterCustomers(),
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, email or ID',
                    prefixIcon: const Icon(Icons.search),
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
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter Chips
                Wrap(
                  spacing: 8,
                  children: ['All', 'Regular', 'Premium', 'VIP']
                      .map((filter) => FilterChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                                _filterCustomers();
                              }
                            },
                            selectedColor: Colors.white,
                            checkmarkColor: Theme.of(context).primaryColor,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          // Customers List
          Expanded(
            child: _filteredCustomers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      return _buildCustomerCard(_filteredCustomers[index]);
                    },
                  ),
          ),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomerDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
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
        onTap: () => _showCustomerDetails(customer),
        borderRadius: BorderRadius.circular(12),
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
                          customer.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${customer.id}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCustomerTypeColor(customer.customerType),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      customer.customerType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(customer.phone, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(width: 16),
                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      customer.email,
                      style: TextStyle(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              if (customer.city.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${customer.city}, ${customer.state}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Purchases',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'LKR ${customer.totalPurchases.toStringAsFixed(2)}',
                        style: TextStyle(
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
                        'Total Orders',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${customer.totalOrders}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Customers Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No customers match your current filters',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final pincodeController = TextEditingController();
    final notesController = TextEditingController();
    String selectedType = 'regular';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Customer'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.home),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: stateController,
                          decoration: InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pincodeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Pincode',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    onChanged: (value) => setState(() => selectedType = value!),
                    items: const [
                      DropdownMenuItem(value: 'regular', child: Text('Regular')),
                      DropdownMenuItem(value: 'premium', child: Text('Premium')),
                      DropdownMenuItem(value: 'vip', child: Text('VIP')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Customer Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.star),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  _addCustomer(
                    nameController.text,
                    phoneController.text,
                    emailController.text,
                    addressController.text,
                    cityController.text,
                    stateController.text,
                    pincodeController.text,
                    selectedType,
                    notesController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Customer'),
            ),
          ],
        ),
      ),
    );
  }

  void _addCustomer(String name, String phone, String email, String address,
                   String city, String state, String pincode, String type, String notes) {
    final newCustomer = Customer(
      id: 'CUST${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: email,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      customerType: type,
      notes: notes,
    );

    setState(() {
      _customers.add(newCustomer);
    });
    _filterCustomers();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Customer ${name} added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCustomerDetails(Customer customer) {
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
                  
                  // Customer Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: _getCustomerTypeColor(customer.customerType),
                        child: Text(
                          customer.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ID: ${customer.id}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCustomerTypeColor(customer.customerType),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                customer.customerType.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Contact Information
                  _buildSectionTitle('Contact Information'),
                  _buildInfoTile(Icons.phone, 'Phone', customer.phone),
                  if (customer.email.isNotEmpty)
                    _buildInfoTile(Icons.email, 'Email', customer.email),
                  
                  const SizedBox(height: 20),
                  
                  // Address Information
                  if (customer.address.isNotEmpty || customer.city.isNotEmpty) ...[
                    _buildSectionTitle('Address'),
                    if (customer.address.isNotEmpty)
                      _buildInfoTile(Icons.home, 'Address', customer.address),
                    if (customer.city.isNotEmpty)
                      _buildInfoTile(Icons.location_city, 'City', customer.city),
                    if (customer.state.isNotEmpty)
                      _buildInfoTile(Icons.map, 'State', customer.state),
                    if (customer.pincode.isNotEmpty)
                      _buildInfoTile(Icons.location_on, 'Pincode', customer.pincode),
                    
                    const SizedBox(height: 20),
                  ],
                  
                  // Purchase Summary
                  _buildSectionTitle('Purchase Summary'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'LKR ${customer.totalPurchases.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const Text('Total Purchases'),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${customer.totalOrders}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Total Orders'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Member Since
                  _buildSectionTitle('Member Since'),
                  _buildInfoTile(Icons.calendar_today, 'Date Joined', 
                                DateFormat('dd MMM yyyy').format(customer.dateAdded)),
                  
                  // Notes
                  if (customer.notes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle('Notes'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(customer.notes),
                    ),
                  ],
                  
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditCustomerDialog(customer),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: View purchase history
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Purchase history will be shown here')),
                            );
                          },
                          icon: const Icon(Icons.history),
                          label: const Text('Purchase History'),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog(Customer customer) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final emailController = TextEditingController(text: customer.email);
    final addressController = TextEditingController(text: customer.address);
    final cityController = TextEditingController(text: customer.city);
    final stateController = TextEditingController(text: customer.state);
    final pincodeController = TextEditingController(text: customer.pincode);
    final notesController = TextEditingController(text: customer.notes);
    String selectedType = customer.customerType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Customer'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.home),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: stateController,
                          decoration: InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pincodeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Pincode',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    onChanged: (value) => setState(() => selectedType = value!),
                    items: const [
                      DropdownMenuItem(value: 'regular', child: Text('Regular')),
                      DropdownMenuItem(value: 'premium', child: Text('Premium')),
                      DropdownMenuItem(value: 'vip', child: Text('VIP')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Customer Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.star),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  _updateCustomer(
                    customer,
                    nameController.text,
                    phoneController.text,
                    emailController.text,
                    addressController.text,
                    cityController.text,
                    stateController.text,
                    pincodeController.text,
                    selectedType,
                    notesController.text,
                  );
                  Navigator.pop(context);
                  Navigator.pop(context); // Close the details sheet too
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateCustomer(Customer customer, String name, String phone, String email, 
                      String address, String city, String state, String pincode, 
                      String type, String notes) {
    final customerIndex = _customers.indexWhere((c) => c.id == customer.id);
    if (customerIndex != -1) {
      setState(() {
        _customers[customerIndex] = customer.copyWith(
          name: name,
          phone: phone,
          email: email,
          address: address,
          city: city,
          state: state,
          pincode: pincode,
          customerType: type,
          notes: notes,
        );
      });
      _filterCustomers();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Customer ${name} updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCustomerStats() {
    final totalCustomers = _customers.length;
    final regularCustomers = _customers.where((c) => c.customerType == 'regular').length;
    final premiumCustomers = _customers.where((c) => c.customerType == 'premium').length;
    final vipCustomers = _customers.where((c) => c.customerType == 'vip').length;
    final totalRevenue = _customers.fold<double>(0.0, (sum, c) => sum + c.totalPurchases);
    final avgOrderValue = totalCustomers > 0 ? totalRevenue / totalCustomers : 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Customer Statistics'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatTile('Total Customers', '$totalCustomers', Icons.people),
            _buildStatTile('Regular Customers', '$regularCustomers', Icons.person),
            _buildStatTile('Premium Customers', '$premiumCustomers', Icons.star_half),
            _buildStatTile('VIP Customers', '$vipCustomers', Icons.star),
            _buildStatTile('Total Revenue', 'LKR ${totalRevenue.toStringAsFixed(2)}', Icons.attach_money),
            _buildStatTile('Avg. Customer Value', 'LKR ${avgOrderValue.toStringAsFixed(2)}', Icons.trending_up),
          ],
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

  Widget _buildStatTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
