import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  final Function onFoodLog;
  final Function onImageUpload;
  final Function onNavigation;

  QuickActionButton({
    required this.onFoodLog,
    required this.onImageUpload,
    required this.onNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Show the quick action options when the button is pressed
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return QuickActionOptions(
              onFoodLog: onFoodLog,
              onImageUpload: onImageUpload,
              onNavigation: onNavigation,
            );
          },
        );
      },
      child: Icon(Icons.add),
      tooltip: 'Quick Actions',
    );
  }
}

class QuickActionOptions extends StatelessWidget {
  final Function onFoodLog;
  final Function onImageUpload;
  final Function onNavigation;

  QuickActionOptions({
    required this.onFoodLog,
    required this.onImageUpload,
    required this.onNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      height: 200.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.fastfood),
            title: Text('Log Food'),
            onTap: () {
              onFoodLog();
              Navigator.pop(context); // Close the bottom sheet
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Upload Food Image'),
            onTap: () {
              onImageUpload();
              Navigator.pop(context); // Close the bottom sheet
            },
          ),
          ListTile(
            leading: Icon(Icons.navigate_next),
            title: Text('Navigate to Another Screen'),
            onTap: () {
              onNavigation();
              Navigator.pop(context); // Close the bottom sheet
            },
          ),
        ],
      ),
    );
  }
}
