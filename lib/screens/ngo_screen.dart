import 'package:flutter/material.dart';
import 'package:flutterapk/screens/ngohome_screen.dart';
import 'package:flutterapk/services/app_state.dart';

class NgoScreen extends StatefulWidget {
  const NgoScreen({super.key});

  @override
  _NgoScreenState createState() => _NgoScreenState();
}

class _NgoScreenState extends State<NgoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ngoNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  bool _isRegistering = false;

  @override
  void dispose() {
    _ngoNameController.dispose();
    _registrationNumberController.dispose();
    _contactPersonController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _registerNgo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isRegistering = true);

      await AppState.instance.registerNgo(
        name: _ngoNameController.text.trim(),
        registrationNo: _registrationNumberController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        phone: _phoneNumberController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );

      setState(() => _isRegistering = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 NGO Registered Successfully! Welcome to WeFeed.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NgoHomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NGO Partner Registration",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
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
                          "Organization Information",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _ngoNameController,
                          decoration: InputDecoration(
                            labelText: 'NGO / Organization Name',
                            prefixIcon: const Icon(Icons.apartment),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter NGO name'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _registrationNumberController,
                          decoration: InputDecoration(
                            labelText: 'Government Reg. Number (e.g. NGO-MH-2023-456)',
                            prefixIcon: const Icon(Icons.badge),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter registration number'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _contactPersonController,
                          decoration: InputDecoration(
                            labelText: 'Point of Contact / Director Name',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter contact person name'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            labelText: 'Official Phone Number',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter phone number'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Official Email Address',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter email'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Office Address & City',
                            prefixIcon: const Icon(Icons.location_on),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          maxLines: 2,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter address'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _pincodeController,
                          decoration: InputDecoration(
                            labelText: 'Pincode',
                            prefixIcon: const Icon(Icons.pin_drop),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter pincode'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isRegistering ? null : _registerNgo,
                    icon: _isRegistering
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.verified_user),
                    label: Text(
                      _isRegistering ? "Registering..." : 'Register NGO Partner',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NgoHomeScreen()),
                    );
                  },
                  icon: const Icon(Icons.skip_next, color: Colors.deepPurple),
                  label: const Text(
                    "Skip Registration & Go to NGO Dashboard",
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    "WeFeed • Designed by Ganesh Kothule",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
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
}
