const nodemailer = require('nodemailer');
const { google } = require('googleapis');

const CLIENT_ID = "606088699613-f61rti9020oggt95a30iv1q98morrneg.apps.googleusercontent.com";
const REFRESH_TOKEN = "1//04U3yT8hrAhNlCgYIARAAGAQSNwF-L9Ir3iXQTC2cAN6OckhfuMGsbKmTa_PTqUCiWwRaSsE-F9IfEv5cIQxR4Ei1ORf6D_8Wpzc";
const CLIENT_SECRET = "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";
const REDIRECT_URI = "https://developers.google.com/oauthplayground";

const oAuth2Client = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI);
oAuth2Client.setCredentials({ refresh_token: REFRESH_TOKEN });


async function mailer(mailText, toUser, androidGuide, iosGuide) {

    debugPrint("Entered");

    try {
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

        const mailOptions = {
            from: 'prismausam@gmail.com',
            to: toUser,
            subject: 'Prism Application (Trial)',
            text: mailText,
            // html: mailText,
            attachments: [
                {   // file on disk as an attachment
                    filename: 'Android Guide',
                    path: androidGuide.path // stream this file
                },
                {   // file on disk as an attachment
                    filename: 'Apple Guide',
                    path: iosGuide.path // stream this file
                },
            ]
        };
        debugPrint("Arrived");
        const result = await transporter.sendMail(mailOptions);
        debugPrint("Executed");
        return result;
    } catch (error) {
        console.log(error);
    }

}

mailer().then((result) => console.log("Enail Sent....", result)).catch((error) => console.log(error.message));

// function add(a, b) {
//     var res = a + b;
//     return `Result: ${res}`;
// }