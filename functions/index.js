
const functions = require("firebase-functions");
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

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

exports.notifyToTherapist = functions.firestore
    .document('assessments/{id}')
    .onCreate(async (snapshot, context) => {
        if (snapshot.empty) {
            console.log("No Assessments");
        }

        const querySnapshot = await db
            .collection('users')
            .doc(snapshot["therapist"])
            .get();

        const token = querySnapshot["token"];
        console.log(token);

        var body;

        if (snapshot["assessor"].toString() == snapshot["therapist"].toString()) {
            body = 'Hello, You have been allocated as a therapist for the assessment. Please complete the assessment and provide the necessary recommedations!\n\n Thank You!!';
        }

        var payload = {
            notification: {
                title: `BHBS | ${querySnapshot.data()["firstName"]} ${querySnapshot.data()["lastName"]} `,
                body: body,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            }
        };
        try {
            const response = await admin.messaging().sendToDevice(token, payload);
            console.log("Notification sent successfully");
            return response;
        } catch (error) {
            console.log();
        }

    });

exports.sendMessageToTherapist = functions.firestore
    .document('assessments/{id}')
    .onUpdate(async (snapshot, context) => {
        if (snapshot.empty) {
            console.log("No Assessments");
        }
        // const message = snapshot.data();
        // console.log(message);


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

        var currentStatus = snapshot.after.data()["currentStatus"];
        var body;

        if (currentStatus == "Assessment Scheduled" && snapshot.data()["assessor"] == snapshot.data()["therapist"]) {
            body = 'Hello, You have been allocated as a therapist for the assessment. Please complete the assessment and provide the necessary recommedations!\n\n Thank You!!';
        } else if (currentStatus == "Assessment Scheduled") {
            body = 'Hello, You have been allocated as a therapist for the assessment. Assessor will soon began the assessment wait untill then.\n\n Thank You!!';
        } else if (currentStatus == "Assessment Scheduled") {
            body = 'Hello, Assessment completely filled by the assessor. Now, please provide the recommendations to the assessment!\n\n Thank You!!';
        } else {
            body = 'Thank You!!\n\n You have completed the assessment.'
        }

        var payload = {
            notification: {
                title: `BHBS | ${querySnapshot.data()["firstName"]} ${querySnapshot.data()["lastName"]} `,
                body: body,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
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
    .onUpdate(async (snapshot, context) => {
        if (snapshot.empty) {
            console.log("No Assessments");
        }
        // const message = snapshot.data();
        // console.log(message);


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
        var currentStatus = snapshot.after.data()["currentStatus"];
        var body;

        if (currentStatus == "Assessment Finished") {
            body = 'Hello, Your assessment has been finished by the assessor. Therapist will soon began to give recommendations to your assessment. \n\n Thank you for choosing us!';
        } else if (currentStatus == "Report Generated") {
            body = 'Hello, Your assessment has been finished by the therapist. View your report so that you can make the changes according the therapist recommendations. \n\n Thank you for choosing us!';
        } else {
            body = "Hello, Assessor will soon informed with your assessment.\n\n Thank you for choosing us!";
        }

        var payload = {
            notification: {
                title: `Welcome to BHBS | Assessment of ${querySnapshotPatient.data()["firstName"]} ${querySnapshotPatient.data()["lastName"]} with therapist ${querySnapshot.data()["firstName"]} ${querySnapshot.data()["lastName"]} has been scheduled`,
                body: body,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            }
        };
        try {
            const response = await admin.messaging().sendToDevice(token, payload);
            console.log("Notification sent successfully");
            return response;
        } catch (error) {
            console.log();
        }

    });

exports.sendMessageToAssessor = functions.firestore
    .document('assessments/{id}')
    .onUpdate(async (snapshot, context) => {
        if (snapshot.empty) {
            console.log("No Assessments");
        }
        // const message = snapshot.data();
        // console.log(message); 

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
        var currentStatus = snapshot.after.data()["currentStatus"];
        var body;

        if (currentStatus == "Assessment Scheduled" && snapshot.data()["therapist"] != snapshot.data()["assessor"]) {
            body = 'Hello, You have been allocated as an assessor for the assessment. So, complete the assessment as soon as posible\n\n Thank You!!';
        } else {
            body = 'Thank You! to complete the assessment in time.';
        }

        var payload = {
            notification: {
                title: `BHBS | ${querySnapshot.data()["firstName"]} ${querySnapshot.data()["lastName"]}`,
                body: body,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            }
        };
        try {
            const response = await admin.messaging().sendToDevice(token, payload);
            console.log("Notification sent successfully");
            return response;
        } catch (error) {
            console.log();
        }
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

// exports.onUserCreate = functions.firestore.document("users/{userid}").onCreate(async (snap, context) => {
//     const values = snap.data();

//     await db.collection("logging").add({description: "Email was sent to user with username: ${values.username}"});
// });

