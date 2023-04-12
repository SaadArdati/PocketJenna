import * as functions from "firebase-functions";


import * as admin from "firebase-admin";
import * as express from "express";

import cors = require("cors");


import {log} from "firebase-functions/logger";
import {Request, Response, NextFunction} from "express";

admin.initializeApp();

const app = express();

// Convert request body to JSON
app.use(express.json());

// Automatically allow cross-origin requests
app.use(cors({origin: true}));

// Make sure to verify firebase auth token for each request.
app.use((
  req: Request,
  res: Response,
  next: NextFunction) => {
  if (
    !req.headers.authorization ||
    !req.headers.authorization.startsWith("Bearer ")
  ) {
    res.status(403).send("Unauthorized. Malformed header.");
    return;
  }
  const idToken = req.headers.authorization.split("Bearer ")[1];

  log("Auth header found: [", req.headers.authorization + "]");
  log("id token part: [" + idToken + "]");
  log("req.body: [" + req.body + "]");
  log("req.body type: [" + typeof req.body + "]");
  admin
    .auth()
    .verifyIdToken(idToken)
    .then((decodedIdToken) => {
      req.headers.userID = decodedIdToken.uid;
      return next();
    })
    .catch((err) => {
      log("Error while verifying Firebase ID token:", err);
      res.status(403).send("Unauthorized. Bad token.");
    });
});

const db = admin.firestore();
const usersRef = db.collection("users");

app.post("/updateChat", async (
  req: Request,
  res: Response,
) => {
  const chat = req.body;
  const userID = req.headers.userID;

  if (!userID) {
    res.status(400).send("userID is required");
    return;
  }

  // check if is a string.
  if (typeof userID !== "string") {
    res.status(400).send("userID must be a string");
    return;
  }

  await usersRef.doc(userID).collection("chats").doc(chat.id).set(chat);

  res.status(200).send("OK");
});

app.get("/getChat", async (
  req: Request,
  res: Response,
) => {
  const userID = req.headers.userID;
  const chatId = req.query.chatID;

  if (!userID) {
    res.status(400).send("userID is required");
    return;
  }

  // check if is a string.
  if (typeof userID !== "string") {
    res.status(400).send("userID must be a string");
    return;
  }

  if (!chatId) {
    res.status(400).send("chatId is required");
    return;
  }

  // check if is a string.
  if (typeof chatId !== "string") {
    res.status(400).send("chatId must be a string");
    return;
  }

  const chat = await usersRef.doc(userID).collection("chats").doc(chatId).get();

  res.status(200).send(chat.data());
});

// Expose Express API as a single Cloud Function:
exports.widgets = functions.https.onRequest(app);
