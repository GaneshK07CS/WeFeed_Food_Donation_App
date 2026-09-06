import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NgoProfileScreen extends StatefulWidget {
  @override
  _NgoProfileScreenState createState() => _NgoProfileScreenState();
}

class _NgoProfileScreenState extends State<NgoProfileScreen> {
  Map<String, dynamic>? ngoData;

  @override
  void initState() {
    super.initState();
    fetchNgoData();
  }

  Future<void> fetchNgoData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('ngo').doc(uid).get();

      if (doc.exists) {
        setState(() {
          ngoData = doc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("Error fetching NGO data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NGO Profile")),
      body: ngoData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoTile("NGO Name", ngoData!['name']),
                      _buildInfoTile("Registration Number", ngoData!['reg_no']),
                      _buildInfoTile("Contact Person", ngoData!['poc_name']),
                      _buildInfoTile("Phone Number", ngoData!['poc_no']),
                      _buildInfoTile("Email", ngoData!['email']),
                      _buildInfoTile("Address", ngoData!['address']),
                      _buildInfoTile(
                          "Area of Operation", ngoData!['area'] ?? "Not Specified"),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to edit profile screen (to be implemented)
                          },
                          child: Text("Edit Profile"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(value),
        ),
        Divider(),
      ],
    );
  }
}
