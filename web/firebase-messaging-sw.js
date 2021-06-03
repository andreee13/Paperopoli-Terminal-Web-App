importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts(
  "https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js"
);

firebase.initializeApp({
  apiKey: "AIzaSyBfumL6wAQrRQz1qg0oGSEyCoH3MoWMA_E",
  authDomain: "paperopoli-terminal.firebaseapp.com",
  projectId: "paperopoli-terminal",
  storageBucket: "paperopoli-terminal.appspot.com",
  messagingSenderId: "1094311692688",
  appId: "1:1094311692688:web:0836643acff8f308fd0b15",
  measurementId: "G-GW1YBLG8EZ",
});
firebase.analytics();

const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
  const promiseChain = clients
    .matchAll({
      type: "window",
      includeUncontrolled: true,
    })
    .then((windowClients) => {
      for (let i = 0; i < windowClients.length; i++) {
        const windowClient = windowClients[i];
        windowClient.postMessage(payload);
      }
    })
    .then(() => {
      return registration.showNotification(payload.notification.title, {
        body: payload.notification.body,
      });
    });
  return promiseChain;
});
self.addEventListener("notificationclick", function (event) {
  console.log("notification received: ", event);
});
