let admin = require('firebase-admin');

let serviceAccount = {
  "type": "service_account",
  "project_id": process.env.FIREBASE_PROJECT_ID,
  "private_key_id": process.env.FIREBASE_PRIVATE_KEY_ID,
  "private_key": process.env.FIREBASE_PRIVATE_KEY,
  "client_email": process.env.FIREBASE_CLIENT_EMAIL,
  "client_id": process.env.FIREBASE_CLIENT_ID,
  "auth_uri": process.env.FIREBASE_AUTH_URI,
  "token_uri": process.env.FIREBASE_TOKEN_URI,
};

async function initializeFirebase() {
  try {
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
    }
    console.log('✅ Firebase initialized successfully');
  } catch (error) {
    console.error('❌ Firebase initialization failed:', error);
    throw error;
  }
}

async function sendPushNotification(userToken, title, message, data = {}) {
  try {
    const payload = {
      notification: {
        title: title,
        body: message,
        sound: 'default',
      },
      data: data,
      token: userToken
    };

    const response = await admin.messaging().send(payload);
    console.log('✅ Push notification sent successfully:', response);
    return response;
  } catch (error) {
    console.error('❌ Error sending push notification:', error);
    throw error;
  }
}

async function sendMulticastNotification(tokens, title, message, data = {}) {
  try {
    const payload = {
      notification: {
        title: title,
        body: message,
        sound: 'default',
      },
      data: data,
      tokens: tokens
    };

    const response = await admin.messaging().sendMulticast(payload);
    console.log('✅ Multicast notification sent:', response);
    return response;
  } catch (error) {
    console.error('❌ Error sending multicast notification:', error);
    throw error;
  }
}

module.exports = {
  admin,
  initializeFirebase,
  sendPushNotification,
  sendMulticastNotification
};
