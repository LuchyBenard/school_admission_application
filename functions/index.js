const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { logger } = require('firebase-functions/v2');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Sends a push notification whenever a `notifications` document is created
 * for a student (e.g. when an admin accepts/rejects an application or
 * requests more documents in ApplicantDetailScreen).
 *
 * The student's FCM token (registered by the app on login) is read from
 * `users/{userId}/fcmToken`. If the token is stale it is removed so future
 * pushes skip that device instead of failing.
 */
exports.sendApplicationNotificationPush = onDocumentCreated(
  { document: 'notifications/{notifId}', region: 'us-central1' },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const notification = snapshot.data();
    const userId = notification.userId;
    const title = notification.title || 'CampusApply';
    const body = notification.message || '';
    const type = notification.type || 'update';

    if (!userId) {
      logger.info('Notification has no userId, skipping push');
      return;
    }

    const userRef = db.collection('users').doc(userId);
    const userSnap = await userRef.get();
    const token = userSnap.exists ? userSnap.get('fcmToken') : null;

    if (!token) {
      logger.info(`No FCM token for user ${userId}, skipping push`);
      return;
    }

    const message = {
      notification: { title, body },
      data: {
        notificationId: snapshot.id,
        type,
      },
      token,
    };

    try {
      await messaging.send(message);
      logger.info(`Push sent to ${userId} (${type})`);
    } catch (error) {
      if (
        error.code === 'messaging/registration-token-not-registered' ||
        error.code === 'messaging/invalid-registration-token'
      ) {
        logger.warn(`Removing stale FCM token for user ${userId}`);
        await userRef.update({
          fcmToken: admin.firestore.FieldValue.delete(),
        });
      } else {
        logger.error('Push send failed', error);
      }
    }
  },
);
