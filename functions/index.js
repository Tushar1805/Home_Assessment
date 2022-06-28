const functions = require("firebase-functions");
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
const { google } = require('googleapis');

const CLIENT_ID = "606088699613-jeibdffbgbh08bdtfiqo8shtt23coci9.apps.googleusercontent.com";
const REFRESH_TOKEN = "1//043_S6keTe4OGCgYIARAAGAQSNwF-L9IrAFSmTDglkQ8whV9Xf6YdosPFalEuK3GBvNA0evYyhjdINrb7dVboO0W9hdaVXjysW1U";
const CLIENT_SECRET = "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";
const REDIRECT_URI = "https://developers.google.com/oauthplayground";

const oAuth2Client = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI);
oAuth2Client.setCredentials({ refresh_token: REFRESH_TOKEN });

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

exports.sendMail = functions.https.onCall(async (data, context) => {
    console.log("Entered");
    try {
        const CLIENT_ID = "606088699613-jeibdffbgbh08bdtfiqo8shtt23coci9.apps.googleusercontent.com";
        const REFRESH_TOKEN = "1//043_S6keTe4OGCgYIARAAGAQSNwF-L9IrAFSmTDglkQ8whV9Xf6YdosPFalEuK3GBvNA0evYyhjdINrb7dVboO0W9hdaVXjysW1U";
        const CLIENT_SECRET = "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";
        const REDIRECT_URI = "https://developers.google.com/oauthplayground";

        const oAuth2Client = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI);
        oAuth2Client.setCredentials({ refresh_token: REFRESH_TOKEN });
        const accessToken = await oAuth2Client.getAccessToken();
        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                type: "OAuth2",
                user: "prismausam@gmail.com",
                clientId: CLIENT_ID,
                clientSecret: CLIENT_SECRET,
                refreshToken: REFRESH_TOKEN,
                accessToken: accessToken,
            },
            // port: 465,
            // secure: true,
        });

        // const transporter = nodemailer.createTransport({
        //     service: gmail,
        //     auth: {
        //         user: 'tusharkalbhande18@gmail.com',
        //         pass: "TusharGoogle@18"
        //     }
        // })

        const mailOptions = {
            from: 'prismausam@gmail.com',
            to: data.toUser,
            subject: 'Prism Application (Trial)',
            // text: "Hello from tushar",
            html: data.mailText,
            attachments: [
                {   // file on disk as an attachment
                    filename: 'Android Guide',
                    path: 'https://firebasestorage.googleapis.com/v0/b/prachitest-96f1d.appspot.com/o/androidGuide.pdf?alt=media&token=70abad54-3d75-4ec8-abea-d288cacb9f3e' // stream this file
                },
                {   // file on disk as an attachment
                    filename: 'Apple Guide',
                    path: 'https://firebasestorage.googleapis.com/v0/b/prachitest-96f1d.appspot.com/o/appleGuide.pdf?alt=media&token=83d1c56b-e743-4270-a9dc-5e326d7408e2'// stream this file
                },
            ]
        };
        console.log("Arrived");
        const result = await transporter.sendMail(mailOptions);
        console.log("Executed");
        return result;
    } catch (error) {
        return error;
    }

});