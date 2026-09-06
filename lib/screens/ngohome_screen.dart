import 'package:flutter/material.dart';
import 'Ngo_food.dart';
import 'profile_screen.dart';
import 'signin_screen.dart';
import '../services/app_state.dart';

class NgoHomeScreen extends StatefulWidget {
  const NgoHomeScreen({super.key});

  @override
  _NgoHomeScreenState createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends State<NgoHomeScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final availableFood = AppState.instance.availableDonations;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Smile Foundation (NGO Hub)',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.deepPurple,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NGOFoodDisplayScreen()),
                  );
                },
                icon: const Icon(Icons.fastfood),
                tooltip: "View Food Donations",
              ),
              IconButton(
                onPressed: () {
                  AppState.instance.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                },
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(availableFood.length),
                _buildTabSection(),
                selectedTab == 0 ? _buildMyPosts(availableFood) : _buildDonorsPosts(),
                _buildFoodDonors(),
                _buildFAQsSection(),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.deepPurple.withValues(alpha: 0.2)),
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
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavBar(),
        );
      },
    );
  }

  Widget _buildUserInfo(int availableCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'NGO / Receiver Portal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: const Text(
                'By Ganesh Kothule',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                  '520+', 'Meals Served', Icons.rice_bowl, Colors.green),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInfoCard(
                  '$availableCount', 'Available Food', Icons.fastfood, Colors.orange),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInfoCard(
                  'Verified', 'NGO Status', Icons.verified, Colors.deepPurple),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(thickness: 1),
      ],
    );
  }

  Widget _buildInfoCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          _buildTabItem(0, 'Available Food Listings'),
          _buildTabItem(1, 'Incoming Donor Posts'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    selectedTab == index ? FontWeight.bold : FontWeight.normal,
                color: selectedTab == index ? Colors.deepPurple : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            if (selectedTab == index)
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPosts(List<FoodDonationItem> foodList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        if (foodList.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No active food listings found.')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: foodList.length > 3 ? 3 : foodList.length,
            itemBuilder: (context, i) {
              final food = foodList[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.fastfood, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    food.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${food.qty} • ${food.address}\nExpiry: ${food.expiry}"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NGOFoodDisplayScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: const Text("View / Claim"),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NGOFoodDisplayScreen()),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text("Browse All Food Listings & Collect"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const Divider(thickness: 1, height: 35),
      ],
    );
  }

  Widget _buildDonorsPosts() {
    return Column(
      children: [
        _buildPostItem(
            'Ganesh Kothule listed 30 Surplus Veg Meals ready for pickup.',
            'Hotel Grand, FC Road'),
        _buildPostItem(
            'BakeHouse Bakery listed 40 Fresh Bread Loaves.',
            'MG Road, Camp'),
        _buildPostItem(
            'Green Mart listed 50 Packaged Fruit Boxes.',
            'Kothrud Hub'),
        const Divider(thickness: 1, height: 35),
      ],
    );
  }

  Widget _buildPostItem(String message, String location) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.food_bank, color: Colors.deepPurple, size: 30),
        title: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("📍 $location"),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NGOFoodDisplayScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Claim'),
        ),
      ),
    );
  }

  Widget _buildFoodDonors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Active Food Donors in Your City',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ),
        _buildDonorItem('Ganesh Kothule (Catering Partner)', '2.1 km', '120 meals donated this week', '+91 9699468358'),
        _buildDonorItem('Grand Heritage Hotel', '3.5 km', '340 meals served till now', '+91 98221 33445'),
        _buildDonorItem('BakeHouse Confectioners', '4.2 km', '215 bakery packs provided', '+91 98550 66778'),
        const Divider(thickness: 1, height: 35),
      ],
    );
  }

  Widget _buildDonorItem(String name, String distance, String details, String phone) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.restaurant, color: Colors.white, size: 20),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$distance • $details\nPhone: $phone'),
        trailing: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Calling $name at $phone..."),
                backgroundColor: Colors.green.shade800,
              ),
            );
          },
          icon: const Icon(Icons.phone, size: 16),
          label: const Text('Connect'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQsSection() {
    return const ExpansionTile(
      title: Text('Frequently Asked Questions (FAQs)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      children: [
        ListTile(
          title: Text('Who arranges food pickup?',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              'The NGO representative or volunteer visits the donor location to collect the surplus food.'),
        ),
        ListTile(
          title: Text('How is food freshness ensured?',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              'Donors provide preparation timestamp and expiration guidelines for every listing.'),
        ),
        ListTile(
          title: Text('How does MySQL manage database storage?',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              'All user, donor, NGO, and donation records are securely structured in the MySQL relational database schema.'),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Food Feed'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
      ],
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NGOFoodDisplayScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        } else if (index == 3) {
          AppState.instance.logout();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
      },
    );
  }
}
