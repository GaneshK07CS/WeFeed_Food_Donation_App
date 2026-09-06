import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'donar_screen.dart';
import 'donation_history.dart';
import 'signin_screen.dart';
import '../services/app_state.dart';

class DonarHomeScreen extends StatelessWidget {
  const DonarHomeScreen({super.key});

  void _navigateToDonarScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DonarScreen()),
    );
  }

  void _logout(BuildContext context) {
    AppState.instance.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  void _showEditDonationDialog(BuildContext context, FoodDonationItem item) {
    final titleController = TextEditingController(text: item.title);
    final qtyController = TextEditingController(text: item.qty);
    final expiryController = TextEditingController(text: item.expiry);
    final addressController = TextEditingController(text: item.address);
    final pincodeController = TextEditingController(text: item.pincode);
    String selectedCategory = item.foodType;

    final List<String> categories = [
      'Cooked Food',
      'Raw Food / Grocery',
      'Bakery & Breads',
      'Packaged Food',
      'Fruits & Vegetables',
    ];

    if (!categories.contains(selectedCategory)) {
      categories.add(selectedCategory);
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.blue.shade700, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    "Edit Food Donation",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Changes will immediately reflect on the NGO food pickup feed in real time.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: "Food Title",
                            prefixIcon: const Icon(Icons.fastfood),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? "Enter food title" : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: InputDecoration(
                            labelText: "Food Category",
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: categories
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedCategory = val);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: qtyController,
                          decoration: InputDecoration(
                            labelText: "Quantity (e.g. 30 Packets)",
                            prefixIcon: const Icon(Icons.scale),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? "Enter quantity" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: expiryController,
                          decoration: InputDecoration(
                            labelText: "Expiry / Best Before",
                            prefixIcon: const Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? "Enter expiry" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: addressController,
                          decoration: InputDecoration(
                            labelText: "Pickup Address",
                            prefixIcon: const Icon(Icons.location_on),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          maxLines: 2,
                          validator: (v) =>
                              v == null || v.isEmpty ? "Enter address" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: pincodeController,
                          decoration: InputDecoration(
                            labelText: "Pincode",
                            prefixIcon: const Icon(Icons.pin_drop),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || v.isEmpty ? "Enter pincode" : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await AppState.instance.editDonation(
                        id: item.id,
                        title: titleController.text.trim(),
                        desc: "${titleController.text.trim()} - $selectedCategory",
                        qty: qtyController.text.trim(),
                        expiry: expiryController.text.trim(),
                        address: addressController.text.trim(),
                        pincode: pincodeController.text.trim(),
                        foodType: selectedCategory,
                      );

                      if (context.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "🎉 Donation updated! New details are now live on NGO portal."),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text("Save & Update NGO Feed"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String donationId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Donation Listing?"),
        content: const Text(
            "Are you sure you want to remove this donation? It will no longer be visible to NGOs."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              AppState.instance.deleteDonation(donationId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Donation removed."),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final appState = AppState.instance;
        final donations = appState.donations;
        final ngos = appState.ngos;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "WeFeed - Donor Dashboard",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.blue.shade700,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: "Create Donation",
                onPressed: () => _navigateToDonarScreen(context),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: "Logout",
                onPressed: () => _logout(context),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Donor Profile Header Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      radius: 26,
                      child: Icon(Icons.volunteer_activism,
                          color: Colors.blue.shade700, size: 28),
                    ),
                    title: Text(
                      "Hi, ${appState.currentUserName.isNotEmpty ? appState.currentUserName : 'Donor'}",
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Active Donor • WeFeed Community"),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: const Text(
                            "Designed by Ganesh Kothule",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Quick Action & Stats Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Food Donation Actions",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Chip(
                              label: Text(
                                "${donations.length} Active Listings",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.blue.shade600,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Have extra food from a party, hotel, or household? Donate now or manage your active listings below.",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToDonarScreen(context),
                            icon: const Icon(Icons.volunteer_activism, color: Colors.white),
                            label: const Text(
                              "+ Upload New Food Donation",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Active Donations Section with Edit Button
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Manage Your Food Donations",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AllDonationHistoryScreen(),
                                  ),
                                );
                              },
                              child: const Text("View All"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (donations.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text("No donations yet. Click above to create one!"),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: donations.length,
                            separatorBuilder: (context, i) =>
                                const Divider(height: 18),
                            itemBuilder: (context, index) {
                              final item = donations[index];
                              final isPicked = item.pickup ||
                                  item.status == 'Picked Up' ||
                                  item.status == 'Approved';

                              return Card(
                                color: Colors.grey.shade50,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isPicked
                                                  ? Colors.green.shade50
                                                  : Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isPicked
                                                    ? Colors.green.shade300
                                                    : Colors.blue.shade300,
                                              ),
                                            ),
                                            child: Text(
                                              item.status,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isPicked
                                                    ? Colors.green.shade700
                                                    : Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                          "📦 Qty: ${item.qty}  •  Category: ${item.foodType}"),
                                      Text("⏰ Expiry: ${item.expiry}"),
                                      Text(
                                          "📍 Pickup: ${item.address} (PIN: ${item.pincode})"),
                                      const Divider(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () =>
                                                _confirmDelete(context, item.id),
                                            icon: const Icon(Icons.delete_outline,
                                                size: 16, color: Colors.redAccent),
                                            label: const Text("Delete",
                                                style: TextStyle(
                                                    color: Colors.redAccent)),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                  color: Colors.redAccent),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 6),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                _showEditDonationDialog(
                                                    context, item),
                                            icon: const Icon(Icons.edit,
                                                size: 16, color: Colors.white),
                                            label: const Text(
                                              "Edit Details",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blue.shade700,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // NGOs Nearby
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Partner NGOs Near You",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ngos.length,
                          separatorBuilder: (context, i) =>
                              const Divider(height: 14),
                          itemBuilder: (context, index) {
                            final ngo = ngos[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple.shade50,
                                child: Icon(Icons.apartment,
                                    color: Colors.purple.shade700),
                              ),
                              title: Text(
                                ngo.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  "${ngo.address} • Contact: ${ngo.phone}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.phone, color: Colors.green),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Calling ${ngo.name}: ${ngo.phone}"),
                                      backgroundColor: Colors.green.shade800,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.25)),
                    ),
                    child: const Text(
                      "WeFeed • Designed by Ganesh Kothule",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.add_box), label: "Donate"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history), label: "History"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.logout), label: "Logout"),
            ],
            selectedItemColor: Colors.blue.shade700,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index == 1) {
                _navigateToDonarScreen(context);
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AllDonationHistoryScreen()),
                );
              } else if (index == 3) {
                _logout(context);
              }
            },
          ),
        );
      },
    );
  }
}
