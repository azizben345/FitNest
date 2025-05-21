import 'package:flutter/material.dart';

class GoogleFitActivityUI extends StatelessWidget {
  const GoogleFitActivityUI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ActivityPage(),
      theme: ThemeData.dark(),
    );
  }
}

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  void _showAddActivityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add activity'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: '',
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showActivitySelectionPage(context);
                  },
                  child: const IgnorePointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Activity',
                        hintText: '',
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Start',
                    hintText: '',
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Duration',
                    hintText: '',
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Energy expended',
                    hintText: '',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                // Add your logic to save the activity here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showActivitySelectionPage(BuildContext context) {
    final List<String> recentActivities = ['Aerobics', 'Jogging'];
    final List<String> popularActivities = [
      'Walking',
      'Cycling',
      'Strength training',
      'Aerobics',
      'American football',
      'Australian football',
      'Badminton',
      'Baseball',
      'Basketball'
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Choose activity'),
          ),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search activities',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              _buildActivitySection('Recent', recentActivities),
              _buildActivitySection('Popular', popularActivities),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySection(String title, List<String> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
        ),
        ...activities.map((activity) => ListTile(
              title: Text(activity),
              onTap: () {
                // Return the selected activity to the previous screen
                Navigator.pop(activity as BuildContext);
              },
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddActivityDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionCard(
            title: 'Your weekly recap',
            subtitle: '12 – 18 May\nCheck your trends and spot opportunities to improve',
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Your daily goals',
            subtitle: 'Last 7 days\n1/7 Achieved',
            customContent: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: 'W T F S S M T'.split(' ').map((day) {
                return Column(
                  children: [
                    const Icon(Icons.radio_button_checked, size: 16, color: Colors.cyanAccent),
                    Text(day),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Your weekly target',
            subtitle: '19 – 25 May\n120 of 150\nScoring 150 Heart Points a week can help you live longer, sleep better and boost your mood',
            customContent: LinearProgressIndicator(
              value: 120 / 150,
              backgroundColor: Colors.grey[800],
              color: Colors.cyanAccent,
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Heart Points',
            subtitle: 'Last 7 days\n120 pts Today',
            customContent: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: 'W T F S S M T'.split(' ').map((day) {
                return Column(
                  children: [
                    Container(height: 40, width: 6, color: day == 'T' ? Colors.cyanAccent : Colors.grey),
                    Text(day),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? customContent;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.white70)),
            if (customContent != null) ...[
              const SizedBox(height: 12),
              customContent!,
            ]
          ],
        ),
      ),
    );
  }
}
