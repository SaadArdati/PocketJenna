import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as express from "express";
import {NextFunction, Request, Response} from "express";
import {warn} from "firebase-functions/logger";
import {Chat, ChatMessage, ChatMessageRole, Prompt, UserModel} from "./models";
import {encode} from "gpt-3-encoder";
import {defineSecret} from "firebase-functions/lib/params";
import cors = require("cors");

const openAIKey = defineSecret("OPEN_AI_KEY");

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
  admin
    .auth()
    .verifyIdToken(idToken)
    .then((decodedIdToken) => {
      req.headers.userID = decodedIdToken.uid;
      return next();
    })
    .catch((err) => {
      warn("Error while verifying Firebase ID token:", err);
      res.status(403).send("Unauthorized. Bad token.");
    });
});

const db = admin.firestore();
const usersRef = db.collection("users");

app.post("/updateChat", async (
  req: Request,
  res: Response,
) => {
  const chat = req.body as Chat;
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

  // update chatSnippets in user model.
  const user = await usersRef.doc(userID).get();
  const userModel = user.data() as UserModel;

  const lastMessage: undefined | ChatMessage =
    chat.messages && chat.messages[chat.messages.length - 1];

  if (userModel.tokens <= 0) {
    return res.status(403).send("Not enough tokens");
  }

  if (lastMessage && lastMessage.role == ChatMessageRole.assistant) {
    // A generated assistant message. Tokenize and subtract tokens from user.
    const tokens: number = encode(lastMessage.text).length;

    userModel.tokens -= tokens;
  }

  await usersRef.doc(userID).collection("chats").doc(chat.id).set(chat);

  userModel.chatSnippets[chat.id] = {
    id: chat.id,
    snippet: chat.messages && chat.messages[0].text ||
      "No messages",
    prompt: chat.prompt,
  };

  await usersRef.doc(userID).set(userModel);

  res.status(200).send("OK");
  return;
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

app.post("/registerUser", async (
  req: Request,
  res: Response,
) => {
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

  // Check if user is already registered.
  const user = await usersRef.doc(userID).get();
  if (user.exists) {
    const data: FirebaseFirestore.DocumentData | undefined = user.data();

    if (data) {
      try {
        const userModel: UserModel = data as UserModel;
        if (userModel.tokens) {
          return res.status(200).send("User already registered");
        }
      } catch (e) {/* empty */
      }
    }
  }

  const userModel: UserModel = {
    id: userID,
    tokens: 1000,
    chatSnippets: {},
    updatedOn: Date.now(),
    key: openAIKey.value(),
  };

  await usersRef.doc(userID).set(userModel);

  return res.status(200).send("OK");
});

app.post("/updatePrompt", async (req: Request, res: Response) => {
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

  // Check if user is already registered.
  const user = await usersRef.doc(userID).get();
  if (user.exists) {
    res.status(200).send("User already registered");
    return;
  }

  const prompt = req.body;

  // If the prompt already has a doc on firestore from its id,
  // update it, otherwise create a new one.
  const promptRef = await db.collection("prompts").doc(prompt.id).get();
  let promptModel: Prompt;
  if (promptRef.exists) {
    promptModel = {
      id: prompt.id,
      userID: userID,
      prompts: prompt.prompts,
      title: prompt.title,
      icon: prompt.icon,
      createdOn: prompt.createdOn,
      updatedOn: Date.now(),
    };
  } else {
    promptModel = {
      id: prompt.id,
      userID: userID,
      prompts: prompt.prompts,
      title: prompt.title,
      icon: prompt.icon,
      updatedOn: Date.now(),
      createdOn: Date.now(),
    };
  }

  await db.collection("prompts").doc(prompt.id).set(promptModel);
});

// Expose Express API as a single Cloud Function:
exports.widgets = functions.https.onRequest(app);
