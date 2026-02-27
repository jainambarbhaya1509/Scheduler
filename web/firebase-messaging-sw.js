importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyAQbNA1MCP7It3ykJghJtD95sQtAhuuC48",
    authDomain: "scheduler-1a878.firebaseapp.com",
    projectId: "scheduler-1a878",
    storageBucket: "scheduler-1a878.firebasestorage.app",
    messagingSenderId: "288826539666",
    appId: "1:288826539666:web:70ac13ca0b5f1b3fd0304b",
    measurementId: "G-PSW1VFBRG1",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("SW Background Message ", payload);

  // Show browser notification
  self.registration.showNotification(payload.notification.title, {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png"
  });

  // 🔥 Send message to Flutter UI
  self.clients.matchAll().then(clients => {
    clients.forEach(client => {
      client.postMessage({
        type: "push",
        title: payload.notification.title,
        body: payload.notification.body
      });
    });
  });
});
