import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

// First, ensure you have this NavigationService class
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get context => navigatorKey.currentContext;
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BehaviorSubject<List<Map<String, dynamic>>> _notificationQueue =
  BehaviorSubject<List<Map<String, dynamic>>>.seeded([]);

  Stream<List<Map<String, dynamic>>> get notificationQueue => _notificationQueue.stream;

  // Global listener for notifications
  void startNotificationListener(int currentUserId) {
    _firestore
        .collection('notifications')
        .where('receiverID', isEqualTo: currentUserId)
        .where('status', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final notification = change.doc.data() ?? {};
          notification['docId'] = change.doc.id;
          _addToNotificationQueue(notification);
        }
      }
    });
  }

  // Add notification to queue
  void _addToNotificationQueue(Map<String, dynamic> notification) {
    final currentQueue = _notificationQueue.value;
    currentQueue.add(notification);
    _notificationQueue.add(currentQueue);

    // If this is the only notification, start processing
    if (currentQueue.length == 1) {
      _processNextNotification();
    }
  }

  // Process next notification in queue
  void _processNextNotification() async {
    final currentQueue = _notificationQueue.value;
    if (currentQueue.isEmpty) return;

    final notification = currentQueue.first;

    // Show bottom sheet notification
    await _showBottomSheetNotification(notification);

    // Mark notification as read
    await _markNotificationAsRead(notification['docId']);

    // Remove from queue
    currentQueue.removeAt(0);
    _notificationQueue.add(currentQueue);

    // Process next notification if exists
    if (currentQueue.isNotEmpty) {
      _processNextNotification();
    }
  }

  // Show bottom sheet notification
  Future<void> _showBottomSheetNotification(Map<String, dynamic> notification) async {
    BuildContext? context = _getCurrentContext();
    if (context == null) return;

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification['title'] ?? 'Notification',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                notification['body'] ?? '',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to notifications page
                  _navigateToNotificationsPage();
                },
                child: Text('View All Notifications'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Mark individual notification as read
  Future<void> _markNotificationAsRead(String docId) async {
    await _firestore
        .collection('notifications')
        .doc(docId)
        .update({'status': true});
  }

  // Navigate to notifications page and mark all as read
  void _navigateToNotificationsPage() async {
    BuildContext? context = _getCurrentContext();
    if (context == null) return;

    // Navigate to notifications page using your app's navigation method
    // For example, if using named routes:
    Navigator.of(context).pushNamed('/notifications');

    // Or if using a specific page:
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (context) => NotificationsPage()),
    // );
  }

  // Utility to get current context using NavigationService
  BuildContext? _getCurrentContext() {
    return NavigationService().context;
  }
}

/*// Notifications page to display all notifications
class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _markAllNotificationsAsRead();
  }

  Future<void> _markAllNotificationsAsRead() async {
    // Get current user ID (you'll need to implement this)


    // Fetch and update all unread notifications for the current user
    QuerySnapshot unreadNotifications = await _firestore
        .collection('notifications')
        .where('receiverID', isEqualTo: _userID)
        .where('status', isEqualTo: false)
        .get();

    // Batch update to mark all as read
    WriteBatch batch = _firestore.batch();
    for (var doc in unreadNotifications.docs) {
      batch.update(doc.reference, {'status': true});
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    // Implement your notifications list UI here
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('notifications')
            .where('receiverID', isEqualTo: getCurrentUserId())
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var notification = snapshot.data!.docs[index];
              return ListTile(
                title: Text(notification['title']),
                subtitle: Text(notification['body']),
              );
            },
          );
        },
      ),
    );
  }
}*/

