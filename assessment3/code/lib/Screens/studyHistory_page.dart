import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';

class StudyHistoryScreen extends StatefulWidget {
  const StudyHistoryScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StudyHistoryScreenState();
}

class _StudyHistoryScreenState extends State<StudyHistoryScreen> {
  List<Map<String, dynamic>> _studyPlans = [];
  bool _isLoading = true;

  bool _isUpcomingFilter = false;
  int? _durationFilterExact;
  int? _durationFilterMin;
  String _subjectFilter = "";

  Future<void> _fetchStudyPlans() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user is signed in')));
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('studyPlans')
          .orderBy('subject') // Sort alphabetically by subject
          .get();

      var studyPlans = querySnapshot.docs.map((doc) {
        final data = doc.data()!;
        return {
          'id': doc.id,
          'subject': data['subject'],
          'material': data['material'],
          'duration': data['duration'],
          'date': DateTime.parse(data['date']),
        };
      }).toList();

      if (_isUpcomingFilter) {
        print(_isUpcomingFilter);
        studyPlans = studyPlans.where((plan) => plan['date'].isAfter(DateTime.now())).toList();
      }
      if (_durationFilterExact != null) {
        studyPlans = studyPlans
            .where((plan) => int.tryParse(plan['duration']) != null && int.parse(plan['duration']) == _durationFilterExact)
            .toList();
      }
      if (_durationFilterMin != null) {
        studyPlans = studyPlans
            .where((plan) => int.tryParse(plan['duration']) != null && int.parse(plan['duration']) >= _durationFilterMin!)
            .toList();
      }
      if (_subjectFilter.isNotEmpty) {
        studyPlans = studyPlans.where((plan) => plan['subject'].toLowerCase().contains(_subjectFilter.toLowerCase())).toList();
      }

      setState(() {
        _studyPlans = studyPlans;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching study plans: $error')),
      );
    }
  }

  void _showFilterDialog(String filterType) {
    switch (filterType) {
      case 'Duration (Exact Match)':
        _showDurationFilterDialog(exact: true);
        break;
      case 'Duration (Minimum)':
        _showDurationFilterDialog(exact: false);
        break;
      case 'Subject Name':
        _showSubjectFilterDialog();
        break;
      case 'Upcoming Plans':
        setState(() {
          _isUpcomingFilter = true;
          _durationFilterExact = null;
          _durationFilterMin = null;
          _subjectFilter = "";
        });
        _fetchStudyPlans();
        break;
      case 'All Plans':
        _resetFilters();
        break;
    }
  }

  void _resetFilters() {
    setState(() {
      _isUpcomingFilter = false;
      _durationFilterExact = null;
      _durationFilterMin = null;
      _subjectFilter = "";
    });
    _fetchStudyPlans();
  }

  void _showDurationFilterDialog({required bool exact}) {
    TextEditingController _durationController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(exact ? 'Filter by Duration (Exact Match)' : 'Filter by Duration (Minimum)'),
          content: TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter duration (hours)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final filterValue = int.tryParse(_durationController.text);
                if (filterValue != null && filterValue > 0) {
                  setState(() {
                    if (exact) {
                      _durationFilterExact = filterValue;
                      _durationFilterMin = null;
                    } else {
                      _durationFilterMin = filterValue;
                      _durationFilterExact = null;
                    }
                  });
                  Navigator.pop(context);
                  _fetchStudyPlans();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid duration')));
                }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showSubjectFilterDialog() {
    TextEditingController _subjectController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Subject Name'),
          content: TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Enter Subject Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _subjectFilter = _subjectController.text;
                });
                Navigator.pop(context);
                _fetchStudyPlans();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  // Edit Study Plan
  void _editStudyPlan(Map<String, dynamic> plan) {
    TextEditingController _subjectController = TextEditingController(text: plan['subject']);
    TextEditingController _materialController = TextEditingController(text: plan['material']);
    TextEditingController _durationController = TextEditingController(text: plan['duration'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Study Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: _materialController,
                decoration: const InputDecoration(labelText: 'Material'),
              ),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (hours)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedPlan = {
                  'subject': _subjectController.text,
                  'material': _materialController.text,
                  'duration': _durationController.text,
                  'date': plan['date'].toIso8601String(),
                };

                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('studyPlans')
                      .doc(plan['id'])
                      .update(updatedPlan);
                  Navigator.pop(context);
                  _fetchStudyPlans();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchStudyPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Study History', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _resetFilters,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => AuthService.signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Filter by Duration (Exact Match)', style: TextStyle(fontSize: 20)),
                          onTap: () => _showFilterDialog('Duration (Exact Match)'),
                        ),
                        ListTile(
                          title: const Text('Filter by Duration (Minimum)', style: TextStyle(fontSize: 20)),
                          onTap: () => _showFilterDialog('Duration (Minimum)'),
                        ),
                        ListTile(
                          title: const Text('Filter by Subject Name', style: TextStyle(fontSize: 20)),
                          onTap: () => _showFilterDialog('Subject Name'),
                        ),
                        ListTile(
                          title: const Text('Upcoming Plans', style: TextStyle(fontSize: 20)),
                          onTap: () => _showFilterDialog('Upcoming Plans'),
                        ),
                        ListTile(
                          title: const Text('Show All Plans', style: TextStyle(fontSize: 20)),
                          onTap: () => _showFilterDialog('All Plans'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Filters', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _studyPlans.isEmpty
                ? const Center(child: Text('No Study Plans to Display', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
                : Expanded(
              child: ListView.builder(
                itemCount: _studyPlans.length,
                itemBuilder: (context, index) {
                  final plan = _studyPlans[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading:const Icon(Icons.book, color: Colors.blue),
                      title: Text(
                        plan['subject'],
                        style: const TextStyle(color: Colors.blue, fontSize: 20),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Material: ${plan['material']}', style: const TextStyle(fontSize: 16)),
                          Text('Duration: ${plan['duration']} hours', style: const TextStyle(fontSize: 16)),
                          Text('Date: ${DateFormat('dd-MM-yyyy').format(plan['date'])}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editStudyPlan(plan),
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/studyPlan');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(16.0),
                    ),
                    child: const Text(
                      'Create New Study Plan',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
