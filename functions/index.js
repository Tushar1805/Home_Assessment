
const functions = require("firebase-functions"); 
const admin = require('firebase-admin');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// }); 
admin.initializeApp(functions.config().firebase);
const db = admin.firestore();
const fcm = admin.messaging();


// export const sendToMessages = functions.firestore
//     .document('messages/messageId')
//     .onCreate(async snapshot => {
//         const message = snapshot.data();

//         const payload: admin.messaging.MessagingPayload = {
//             notification: {
//                 title: 'New message from user',
//                 body: message.messageBody
//             }
//         }
//         fcm.sendToTopic('messages', payload);

//     });


// exports.sendMessageTo = functions.firestore
//     .document('assessments/{id}')
//     .onCreate(async (snapshot, context) => {
//         if (snapshot.empty) {
//             console.log("No Assessments");
//         }
//         const message = snapshot.data();
//         console.log(message);
        

//         // const querySnapshot = await db
//         //     .collection('users')
//         //     .doc(message.therapist) 
//         //     .get();

//         const token = "cqlH-kgHTyGr8iuHDIzByM:APA91bH6Dklqn1thkAg1Xntq61syZU5YyRbJO_xZczu8iqf2egW9eS_hVg0Yft-ingE2BRFlxCo11_EQB0qKFv1BFTHbyxJ8ma92r2zhb5upfNxS486y9uE3hR4YON6Iyc5onxso3qZ0";;
//         console.log(token); 

//         // if (message.data()["currentStatus"] == "Assessment Scheduled") {  
//         var payload = { 
//             notification: {
//                 title: `BHBS | hello`,
//                 body: "You have been allocated as therapist for the assessment",
//                 click_action : 'FLUTTER_NOTIFICATION_CLICK', 
//             } 
//         };
//         try {
//             const response = await admin.messaging().sendToDevice(token, payload);
//             console.log("Notification sent successfully");
//             return response;
//         } catch (error) {
//             console.log();
//         }
//         // return fcm.sendToDevice(token, payload);
//     //    }

//     });

    exports.sendMessageToTherapist = functions.firestore
    .document('assessments/{id}')
    .onCreate(async (snapshot, context) => {
        if (snapshot.empty) {
            console.log("No Assessments");
        }
        const message = snapshot.data();
        console.log(message);
        

        const querySnapshot = await db
            .collection('users')
            .doc(snapshot.data()["therapist"]) 
            .get();

            const querySnapshotPatient = await db
            .collection('users')
            .doc(snapshot.data()["patient"]) 
            .get();

        const token = querySnapshot.data()["token"];
        console.log(token); 

        // if (message.data()["currentStatus"] == "Assessment Scheduled") {  
        var payload = { 
            notification: {
                title: `BHBS | ${querySnapshot.data()["firstName"]} ${querySnapshot.data()["lastName"]}`,
                body: 'Hello, You have been allocated as a therapist for the assessment',
                click_action : 'FLUTTER_NOTIFICATION_CLICK', 
            } 
        };
        try {
            const response = await admin.messaging().sendToDevice(token, payload);
            console.log("Notification sent successfully");
            return response;
        } catch (error) {
            console.log();
        }
        // return fcm.sendToDevice(token, payload);
    //    }

    });

    exports.sendMessageToPatient = functions.firestore
    .document('assessments/{id}')
    .onCreate(async (snapshot, context) => {
        if (snapshot.empty) {
            console.log("No Assessments");
        }
        const message = snapshot.data();
        console.log(message);
        

        const querySnapshot = await db
            .collection('users')
            .doc(snapshot.data()["therapist"]) 
            .get();

            const querySnapshotPatient = await db
            .collection('users')
            .doc(snapshot.data()["patient"]) 
            .get();

        const token = querySnapshot.data()["token"];
        console.log(token); 

        // if (message.data()["currentStatus"] == "Assessment Scheduled") {  
        var payload = { 
            notification: {
                title: `BHBS | Assessment of ${querySnapshotPatient.data()["firstName"]} ${querySnapshotPatient.data()["lastName"]} with therapist ${querySnapshot.data()["firstName"]} ${querySnapshot.data()["lastName"]}`,
                body: 'Hello, Your assessment has been scheduled with our hospital',
                click_action : 'FLUTTER_NOTIFICATION_CLICK', 
            } 
        };
        try {
            const response = await admin.messaging().sendToDevice(token, payload);
            console.log("Notification sent successfully");
            return response;
        } catch (error) {
            console.log();
        }
        // return fcm.sendToDevice(token, payload);
    //    }

    });

    exports.sendMessageToAssessor = functions.firestore
    .document('assessments/{id}')
    .onCreate(async (snapshot, context) => {
        if (snapshot.empty) {
            console.log("No Assessments");
        }
        const message = snapshot.data();
        console.log(message);
        

        const querySnapshot = await db
            .collection('users')
            .doc(snapshot.data()["assessor"]) 
            .get();

            const querySnapshotPatient = await db
            .collection('users')
            .doc(snapshot.data()["patient"]) 
            .get();

        const token = querySnapshot.data()["token"];
        console.log(token); 

        // if (message.data()["currentStatus"] == "Assessment Scheduled") {  
        var payload = { 
            notification: {
                title: `BHBS | ${querySnapshot.data()["firstName"]} ${querySnapshot.data()["lastName"]}`,
                body: 'Hello, You have been allocated as a therapist for the assessment',
                click_action : 'FLUTTER_NOTIFICATION_CLICK', 
            } 
        };
        try {
            const response = await admin.messaging().sendToDevice(token, payload);
            console.log("Notification sent successfully");
            return response;
        } catch (error) {
            console.log();
        }
        // return fcm.sendToDevice(token, payload);
    //    }

    });

    // exports.onStatusUpdate = functions.document("assessments/{id}").onUpdate(async (snapshot, context) => {
    //     const newValues = snapshot.after.data();
    //     const previousValues = snapshot.before.data();

    //     const token = "cqlH-kgHTyGr8iuHDIzByM:APA91bH6Dklqn1thkAg1Xntq61syZU5YyRbJO_xZczu8iqf2egW9eS_hVg0Yft-ingE2BRFlxCo11_EQB0qKFv1BFTHbyxJ8ma92r2zhb5upfNxS486y9uE3hR4YON6Iyc5onxso3qZ0";


    //     if(newValues.currentStatus != previousValues.currentStatus){
    //         var payload = { 
    //         notification: {
    //             title: `BHBS | ${querySnapshot["firstName"]}`,
    //             body: "You have been allocated as therapist for the assessment",
    //             click_action : 'FLUTTER_NOTIFICATION_CLICK', 
    //         } 
    //     };
    //     try {
    //         return await admin.messaging().sendToDevice(token,payload);
    //         // console.log("Notification sent successfully");
    //         // return response;
    //     } catch (error) {
    //         console.log();
    //     }
    //     }
    // });

    exports.onUserCreate = functions.firestore.document("users/{userid}").onCreate(async (snap, context) => {
        const values = snap.data();

        await db.collection("logging").add({description: "Email was sent to user with username: ${values.username}"});
    });