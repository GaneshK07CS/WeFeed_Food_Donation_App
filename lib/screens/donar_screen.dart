import 'package:flutter/material.dart';
import 'package:flutterapk/screens/donarhome_screen.dart';
import 'package:flutterapk/services/app_state.dart';

class DonarScreen extends StatefulWidget {
  const DonarScreen({super.key});

  @override
  _DonarScreenState createState() => _DonarScreenState();
}

class _DonarScreenState extends State<DonarScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController(text: "Ganesh Kothule");
  final TextEditingController _mobileController =
      TextEditingController(text: "+91 9699468358");
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  String _selectedFoodType = 'Cooked Food';
  bool _isSubmitting = false;

  final List<String> _foodTypes = [
    'Cooked Food',
    'Raw Food / Grocery',
    'Bakery & Breads',
    'Packaged Food',
    'Fruits & Vegetables',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _foodNameController.dispose();
    _quantityController.dispose();
    _expiryDateController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      await AppState.instance.addDonation(
        title: _foodNameController.text.trim(),
        desc: _foodNameController.text.trim() + " - " + _selectedFoodType,
        qty: _quantityController.text.trim(),
        expiry: _expiryDateController.text.trim(),
        address: _addressController.text.trim(),
        pincode: _pinCodeController.text.trim(),
        foodType: _selectedFoodType,
        donorName: _nameController.text.trim(),
        donorPhone: _mobileController.text.trim(),
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 Food Donation Created Successfully! NGOs have been notified."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DonarHomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Food Donation",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Donor Information",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          _nameController,
                          "Donor Name",
                          Icons.person,
                        ),
                        _buildTextField(
                          _mobileController,
                          "Contact Mobile Number",
                          Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Food Details",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          _foodNameController,
                          "Food Title (e.g. Veg Meals, Bread)",
                          Icons.fastfood,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedFoodType,
                          decoration: InputDecoration(
                            labelText: "Food Category",
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items: _foodTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedFoodType = val);
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          _quantityController,
                          "Quantity (e.g. 25 Packets, 10 Kgs)",
                          Icons.scale,
                        ),
                        _buildTextField(
                          _expiryDateController,
                          "Best Before / Expiry (e.g. Today 10 PM)",
                          Icons.access_time,
                        ),
                        _buildTextField(
                          _addressController,
                          "Pickup Address & Landmark",
                          Icons.location_on,
                          maxLines: 2,
                        ),
                        _buildTextField(
                          _pinCodeController,
                          "Pincode",
                          Icons.pin_drop,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, size: 22),
                    label: Text(
                      _isSubmitting ? "Submitting..." : "Submit Donation",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade900,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    "WeFeed • Designed by Ganesh Kothule",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
      ),
    );
  }
}
