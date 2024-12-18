import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get context => navigatorKey.currentContext;

  void updateContext(BuildContext newContext) {
    navigatorKey.currentState?.context;
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BehaviorSubject<List<Map<String, dynamic>>> _notificationQueue =
  BehaviorSubject<List<Map<String, dynamic>>>.seeded([]);

  Stream<List<Map<String, dynamic>>> get notificationQueue => _notificationQueue.stream;

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

  void _addToNotificationQueue(Map<String, dynamic> notification) {
    final currentQueue = _notificationQueue.value;
    currentQueue.add(notification);
    _notificationQueue.add(currentQueue);

    if (currentQueue.length == 1) {
      _processNextNotification();
    }
  }

  void _processNextNotification() async {
    final currentQueue = _notificationQueue.value;
    if (currentQueue.isEmpty) return;

    final notification = currentQueue.first;

    showScaffoldNotification(notification);

    await _markNotificationAsRead(notification['docId']);

    currentQueue.removeAt(0);
    _notificationQueue.add(currentQueue);

    if (currentQueue.isNotEmpty) {
      _processNextNotification();
    }
  }

  void showScaffoldNotification(Map<String, dynamic> notification) {
    BuildContext? context = _getCurrentContext();
    if (context == null) return;

    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.grey],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title'] ?? 'Notification',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              notification['body'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _markNotificationAsRead(String docId) async {
    await _firestore.collection('notifications').doc(docId).update({'status': true});
  }

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

