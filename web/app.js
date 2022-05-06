const nodemailer = require('nodemailer');

var transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 465,
    secure: true,
    auth: {
        user: 'prismausam@gmail.com',
        pass: 'wpnxzrilzwuwdwpc'
    }
});


function mailer(mailText, toUser, androidGuide, iosGuide) {
    // const mailText = data.mailText;
    // const toUser = data.toUser;

    console.log('Entered to the mailer');

    const mailOptions = {
        from: 'Be Home Be Safe <prismausam@gmail.com>',
        to: toUser,
        subject: 'Prism Application (Trial)',
        html: mailText,
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

    return transporter.sendMail(mailOptions, (error, data) => {
        if (error) {
            console.log(error)
            return
        }
        console.log("Sent!")
    });
}