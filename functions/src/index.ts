import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const express = require('express');
const cors = require('cors');

admin.initializeApp();

const app = express();

// Automatically allow cross-origin requests
app.use(cors({origin: true}));

// Make sure to verify firebase auth token for each request.
app.use((req, res, next) => {
    if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) {
        res.status(403).send('Unauthorized');
        return;
    }
    const idToken = req.headers.authorization.split('Bearer ')[1];
    admin.auth().verifyIdToken(idToken)
        .then((decodedIdToken) => {
            req.body.uid = decodedIdToken.uid;
            return next();
        })
        .catch(() => {
            res.status(403).send('Unauthorized');
        });
});

const db = admin.firestore();
const usersRef = db.collection('users');

app.post('/updateChat', async (req, res) => {
    const {chat} = req.body;
    const {uid} = req.body;

    await usersRef.doc(uid).collection('chats').doc(chat.id).set({
        id: chat.id,
        messages: chat.messages,
        type: chat.type
    });

    res.status(200).send('OK');
});

app.get('/getChat', async (req, res) => {
    const {chatId} = req.query;
    const {uid} = req.body;

    const chat = await usersRef.doc(uid).collection('chats').doc(chatId).get();

    res.status(200).send(chat.data());
});

// Expose Express API as a single Cloud Function:
exports.widgets = functions.https.onRequest(app);
