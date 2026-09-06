import 'package:flutter/material.dart';
import '../services/app_state.dart';

class AllDonationHistoryScreen extends StatelessWidget {
  const AllDonationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final history = AppState.instance.donations;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Donation & Distribution History',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.blue.shade700,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Container(
            color: Colors.grey.shade100,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total ${history.length} Records Logged",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
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
                Expanded(
                  child: history.isEmpty
                      ? const Center(
                          child: Text("No donation records found yet."),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final donation = history[index];
                            final isPicked = donation.pickup ||
                                donation.status == 'Approved' ||
                                donation.status == 'Picked Up';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            donation.title,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isPicked
                                                ? Colors.green.shade50
                                                : Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isPicked
                                                  ? Colors.green.shade300
                                                  : Colors.blue.shade300,
                                            ),
                                          ),
                                          child: Text(
                                            isPicked ? "Picked Up / Approved" : "Available",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isPicked
                                                  ? Colors.green.shade800
                                                  : Colors.blue.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text("Description: ${donation.desc}"),
                                    Text("Quantity: ${donation.qty}"),
                                    Text("Expiry: ${donation.expiry}"),
                                    Text(
                                        "Address: ${donation.address} (PIN: ${donation.pincode})"),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          isPicked
                                              ? Icons.check_circle
                                              : Icons.pending,
                                          size: 16,
                                          color: isPicked
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isPicked
                                              ? "Status: Successfully Coordinated"
                                              : "Status: Awaiting NGO Claim",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isPicked
                                                ? Colors.green.shade700
                                                : Colors.orange.shade800,
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
        );
      },
    );
  }
}
