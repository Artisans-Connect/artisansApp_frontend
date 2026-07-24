// Firebase Messaging Service Worker for PWA Web Push Notifications

importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

// Initialize Firebase App in Service Worker
// The options will be automatically handled if initialized with default options or web config
firebase.initializeApp({
  apiKey: "dummy-key-for-sw",
  authDomain: "dummy.firebaseapp.com",
  projectId: "dummy-project",
  storageBucket: "dummy.appspot.com",
  messagingSenderId: "35491862087",
  appId: "1:35491862087:web:dummy"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification ? payload.notification.title : 'CraftMatch';
  const notificationOptions = {
    body: payload.notification ? payload.notification.body : '',
    icon: '/icons/Icon-192.png',
    data: payload.data
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
