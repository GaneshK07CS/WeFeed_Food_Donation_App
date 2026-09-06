import 'package:flutter/material.dart';
import 'package:flutterapk/screens/ngohome_screen.dart';
import 'package:flutterapk/services/app_state.dart';

class NGOFoodDisplayScreen extends StatefulWidget {
  const NGOFoodDisplayScreen({super.key});

  @override
  _NGOFoodDisplayScreenState createState() => _NGOFoodDisplayScreenState();
}

class _NGOFoodDisplayScreenState extends State<NGOFoodDisplayScreen> {
  void acceptFoodRequest(String id) async {
    await AppState.instance.updateDonationStatus(id, 'Approved', true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Food pickup request APPROVED! Donor has been notified."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void declineFoodRequest(String id) async {
    await AppState.instance.updateDonationStatus(id, 'Rejected', false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Food request declined."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final availableFood = AppState.instance.availableDonations;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Available Food Donations',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Showing ${availableFood.length} donations",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade900,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Designed by Ganesh Kothule",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: availableFood.isEmpty
                      ? const Center(
                          child: Text(
                            "No food donations available right now.\nCheck back soon!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80, left: 12, right: 12),
                          itemCount: availableFood.length,
                          itemBuilder: (context, index) {
                            final food = availableFood[index];
                            final isApproved = food.pickup || food.status == 'Approved';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            food.title,
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple.shade900,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isApproved
                                                ? Colors.green.shade50
                                                : Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isApproved
                                                  ? Colors.green.shade400
                                                  : Colors.orange.shade400,
                                            ),
                                          ),
                                          child: Text(
                                            isApproved ? "Approved / Claimed" : "Available",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isApproved
                                                  ? Colors.green.shade700
                                                  : Colors.orange.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      food.desc,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey.shade800),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(Icons.scale, size: 16, color: Colors.deepPurple),
                                        const SizedBox(width: 4),
                                        Text("Qty: ${food.qty}",
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 16),
                                        Icon(Icons.timer_outlined, size: 16, color: Colors.deepPurple),
                                        const SizedBox(width: 4),
                                        Text("Expiry: ${food.expiry}",
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 16, color: Colors.deepPurple),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            "${food.address} (PIN: ${food.pincode})",
                                            style: TextStyle(color: Colors.grey.shade700),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline,
                                            size: 16, color: Colors.deepPurple),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Donor: ${food.donorName ?? 'Anonymous'} • ${food.donorPhone ?? ''}",
                                          style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    if (!isApproved)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () => declineFoodRequest(food.id),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.redAccent,
                                              side: const BorderSide(color: Colors.redAccent),
                                            ),
                                            child: const Text("Decline"),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton.icon(
                                            onPressed: () => acceptFoodRequest(food.id),
                                            icon: const Icon(Icons.check, size: 18),
                                            label: const Text("Claim & Arrange Pickup"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.deepPurple,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Row(
                                        children: [
                                          Icon(Icons.verified, color: Colors.green.shade600, size: 20),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Pickup Assigned to your NGO",
                                            style: TextStyle(
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Spacer(),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Connecting to donor at ${food.donorPhone ?? '+91 9699468358'}..."),
                                                  backgroundColor: Colors.green.shade800,
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.phone, size: 16),
                                            label: const Text("Call Donor"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green.shade700,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8),
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
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => NgoHomeScreen()),
                (route) => false,
              );
            },
            backgroundColor: Colors.deepPurple,
            icon: const Icon(Icons.home, color: Colors.white),
            label: const Text("NGO Dashboard", style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }
}
