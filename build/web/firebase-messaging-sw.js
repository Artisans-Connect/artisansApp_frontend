// Firebase Messaging Service Worker for PWA Web Push Notifications

importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

// Initialize Firebase App in Service Worker
// The options will be automatically handled if initialized with default options or web config
firebase.initializeApp({
  apiKey: "AIzaSyBQw2KaahpF_4_NR_pKENRtOS99p2jmseo",
  authDomain: "artisansk0nnect.firebaseapp.com",
  projectId: "artisansk0nnect",
  storageBucket: "artisansk0nnect.firebasestorage.app",
  messagingSenderId: "266746398570",
  appId: "1:266746398570:web:dcc89b1918599069534713"
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
