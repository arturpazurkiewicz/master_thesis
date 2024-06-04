import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Witaj!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          children: <Widget>[
            _buildHomeScreenButton(
              context: context,
              icon: Icons.list,
              label: 'Transakcje',
              onPressed: () {
                Navigator.pushNamed(context, '/transactions');
              },
            ),
            _buildHomeScreenButton(
              context: context,
              icon: Icons.add_shopping_cart,
              label: 'Lista zakupowa',
              onPressed: () {
                Navigator.pushNamed(context, '/lists');
              },
            ),
            _buildHomeScreenButton(
              context: context,
              icon: Icons.settings,
              label: 'Ustawienia',
              onPressed: () {
                // Navigate to settings screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScreenButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required void Function() onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.blueAccent,
        padding: EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.white),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
