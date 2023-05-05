import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as express from "express";
import {NextFunction, Request, Response} from "express";
import {log, warn} from "firebase-functions/logger";
import {Chat, ChatMessage, ChatMessageRole, Prompt, UserModel} from "./models";
import {encode} from "gpt-3-encoder";
import {defineSecret} from "firebase-functions/params";
import cors = require("cors");

const openAIKey = defineSecret("OPEN_AI_KEY");

admin.initializeApp();

exports.onSignUp = functions.auth.user().onCreate((user) => {
  const userModel: UserModel = {
    id: user.uid,
    tokens: 50000,
    chatSnippets: {},
    updatedOn: new Date().getTime(),
    createdOn: new Date().getTime(),
    pinnedPrompts: [
      "default_general_chat",
      "default_email",
      "default_document_code",
      "default_twitter",
      "default_reddit",
    ],
  };

  return admin
    .firestore()
    .collection("users")
    .doc(user.uid)
    .set(userModel, {merge: true});
});

exports.onDeleteAccount = functions.auth.user().onDelete((user) => {
  return admin.firestore().collection("users").doc(user.uid).delete();
});

const app = express();

// Convert request body to JSON
app.use(express.json());

// Automatically allow cross-origin requests
app.use(cors({origin: true}));

// Make sure to verify firebase auth token for each request.
app.use((req: Request, res: Response, next: NextFunction) => {
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
const userCollection = db.collection("users");
const promptsCollection = db.collection("market");

app.get("/getOpenAIKey", async (req: Request, res: Response) => {
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
  const user = await userCollection.doc(userID).get();
  const userModel = user.data() as UserModel;

  if (userModel.tokens < 1) {
    return res.status(403).send("Not enough tokens");
  }

  return res.status(200).send(openAIKey.value());
});

app.post("/updateChat", async (req: Request, res: Response) => {
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
  const user = await userCollection.doc(userID).get();
  const userModel = user.data() as UserModel;

  log("CHAT: " + JSON.stringify(chat));
  log("USER: " + JSON.stringify(userModel));

  const lastMessage: ChatMessage = chat.messages[chat.messages.length - 1];

  if (userModel.tokens <= 0) {
    return res.status(403).send("Not enough tokens");
  }

  if (lastMessage.role === ChatMessageRole.assistant) {
    // A generated assistant message. Tokenize and subtract tokens from user.
    const encoded = encode(lastMessage.text);
    const tokens: number = encoded.length;
    log("Encoded: " + encoded);
    log("Tokens: " + tokens);
    log("User tokens: " + userModel.tokens);

    userModel.tokens -= tokens;

    log("User tokens after: " + userModel.tokens);
  }

  await userCollection.doc(userID).collection("chats").doc(chat.id).set(chat);

  if (!userModel.chatSnippets) {
    userModel.chatSnippets = {};
  }

  userModel.chatSnippets[chat.id] = {
    id: chat.id,
    snippet: (chat.messages && chat.messages[0].text) || "No messages",
    promptTitle: chat.prompt.title,
    promptIcon: chat.prompt.icon,
    updatedOn: new Date().getTime(),
  };
  userModel.updatedOn = new Date().getTime();

  log("User model: " + JSON.stringify(userModel));

  await userCollection.doc(userID).set(userModel, {merge: true});

  res.status(200).send("OK");
  return;
});

app.get("/getChat", async (req: Request, res: Response) => {
  const userID = req.headers.userID;
  const chatID = req.query.chatID;

  if (!userID) {
    res.status(400).send("userID is required");
    return;
  }

  // check if is a string.
  if (typeof userID !== "string") {
    res.status(400).send("userID must be a string");
    return;
  }

  if (!chatID) {
    res.status(400).send("chatID is required");
    return;
  }

  // check if is a string.
  if (typeof chatID !== "string") {
    res.status(400).send("chatID must be a string");
    return;
  }

  const chat = await userCollection
    .doc(userID)
    .collection("chats")
    .doc(chatID)
    .get();

  res.status(200).send(chat.data());
});

app.post("/registerUser", async (req: Request, res: Response) => {
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
  const user = await userCollection.doc(userID).get();
  if (user.exists) {
    const data: FirebaseFirestore.DocumentData | undefined = user.data();

    if (data) {
      try {
        const userModel: UserModel = data as UserModel;
        if (userModel.tokens) {
          return res.status(200).send("User already registered");
        }
      } catch (e) {
        /* empty */
      }
    }
  }

  const userModel: UserModel = {
    id: userID,
    tokens: 50000,
    chatSnippets: {},
    updatedOn: new Date().getTime(),
    createdOn: new Date().getTime(),
    pinnedPrompts: [
      "default_general_chat",
      "default_email",
      "default_document_code",
      "default_twitter",
      "default_reddit",
    ],
  };

  await userCollection.doc(userID).set(userModel, {merge: true});

  return res.status(200).send("OK");
});

app.post("/setPrompt", async (req: Request, res: Response) => {
  const userID = req.headers.userID;
  const promptID = req.body.promptID; // optional string
  const prompts = req.body.prompts; // required array of strings.
  const promptTitle = req.body.promptTitle; // required string
  const promptIcon = req.body.promptIcon; // optional string
  const promptDescription = req.body.promptDescription; // optional string
  const isPublic = req.body.isPublic; // optional boolean

  if (!userID) {
    res.status(400).send("userID is required");
    return;
  }

  // check if is a string.
  if (typeof userID !== "string") {
    res.status(400).send("userID must be a string");
    return;
  }

  if (!prompts) {
    res.status(400).send("prompts is required");
    return;
  }

  if (!Array.isArray(prompts)) {
    res.status(400).send("prompts must be an array");
    return;
  }

  // Check if it's an array of strings.
  if (!prompts.every((prompt) => typeof prompt === "string")) {
    res.status(400).send("prompts must be an array of strings");
    return;
  }

  // Check if every string is less than 5000 but more than 15 chars.
  if (
    !prompts.every((prompt) => prompt.length <= 5000 && prompt.length >= 15)
  ) {
    res.status(400).send("Prompt must be between 20 and 5000 characters");
    return;
  }

  // If the prompt already has a doc on firestore from its id,
  // update it, otherwise create a new one.
  if (promptID && typeof promptID == "string") {
    const promptRef = await promptsCollection.doc(promptID).get();
    if (promptRef.exists) {
      const serverUserID = promptRef.data()?.userID;
      if (serverUserID !== userID) {
        res.status(403).send("You do not have permission to edit this prompt");
        return;
      }

      // For each defined field, make sure they're of appropriate type.
      if (promptTitle) {
        if (typeof promptTitle !== "string") {
          res.status(400).send("promptTitle must be a string");
          return;
        }
        if (promptTitle.length > 50) {
          res.status(400).send("promptTitle must be less than 50 characters");
          return;
        }
        if (promptTitle.length < 4) {
          res.status(400).send("promptTitle must be greater than 4 characters");
          return;
        }
      }

      if (promptDescription) {
        if (typeof promptDescription !== "string") {
          res.status(400).send("promptDescription must be a string");
          return;
        }
        if (promptDescription.length > 200) {
          res
            .status(400)
            .send("promptDescription must be less than 200 " + "characters");
          return;
        }
      }

      if (promptIcon) {
        if (typeof promptIcon !== "string") {
          res.status(400).send("promptIcon must be a string");
          return;
        }

        if (!promptIcon.startsWith("https://")) {
          res.status(400).send("promptIcon must be a valid url");
          return;
        }
      }
      if (isPublic) {
        if (typeof isPublic !== "boolean") {
          res.status(400).send("isPublic must be a boolean");
          return;
        }
      }

      const promptUpdate = {
        prompts: prompts,
        title: promptTitle,
        icon: promptIcon,
        promptDescription: promptDescription,
        public: isPublic,
        updatedOn: new Date().getTime(),
      };

      await promptsCollection.doc(promptID).set(promptUpdate, {merge: true});

      const serverModel = await promptsCollection.doc(promptID).get();

      return res.status(200).send(serverModel.data());
    } else {
      res.status(400).send(`Prompt with id [${promptID}] does not exist`);
      return;
    }
  } else {
    if (!promptTitle) {
      res.status(400).send("promptTitle is required");
      return;
    }
    if (typeof promptTitle !== "string") {
      res.status(400).send("promptTitle must be a string");
      return;
    }
    if (promptTitle.length > 50) {
      res.status(400).send("promptTitle must be less than 50 characters");
      return;
    }
    if (promptTitle.length < 4) {
      res.status(400).send("promptTitle must be greater than 4 characters");
      return;
    }

    if (!promptDescription) {
      res.status(400).send("promptDescription is required");
      return;
    }
    if (typeof promptDescription !== "string") {
      res.status(400).send("promptDescription must be a string");
      return;
    }
    if (promptDescription.length > 200) {
      res
        .status(400)
        .send("promptDescription must be less than 200 " + "characters");
      return;
    }

    if (!promptIcon) {
      res.status(400).send("promptIcon is required");
      return;
    }
    if (typeof promptIcon !== "string") {
      res.status(400).send("promptIcon must be a string");
      return;
    }
    if (!promptIcon.startsWith("https://")) {
      res.status(400).send("promptIcon must be a valid url");
      return;
    }
    if (!isPublic) {
      res.status(400).send("isPublic is required");
      return;
    }
    if (typeof isPublic !== "boolean") {
      res.status(400).send("isPublic must be a boolean");
      return;
    }

    const promptModel = {
      userID: userID,
      prompts: prompts,
      title: promptTitle,
      icon: promptIcon,
      description: promptDescription,
      public: isPublic,
      updatedOn: new Date().getTime(),
      createdOn: new Date().getTime(),
      upvotes: [],
    };

    const doc: FirebaseFirestore.DocumentReference =
      await promptsCollection.add(promptModel);

    // Put the ID of the document into the document itself.
    await doc.set({id: doc.id}, {merge: true});

    await userCollection.doc(userID).update({
      pinnedPrompts: admin.firestore.FieldValue.arrayUnion(doc.id),
    });

    return res.status(200).send({id: doc.id, ...promptModel});
  }
});

app.post("/deletePrompt", async (req: Request, res: Response) => {
  const userID = req.headers.userID;
  const promptID = req.body.promptID;

  if (!userID) {
    res.status(400).send("userID is required");
    return;
  }

  if (typeof userID !== "string") {
    res.status(400).send("userID must be a string");
    return;
  }

  if (!promptID) {
    res.status(400).send("promptID is required");
    return;
  }

  if (typeof promptID !== "string") {
    res.status(400).send("promptID must be a string");
    return;
  }

  const promptRef = await promptsCollection.doc(promptID).get();

  if (promptRef.exists) {
    const serverUserID = promptRef.data()?.userID;
    if (serverUserID !== userID) {
      res.status(403).send("You do not have permission to delete this prompt");
      return;
    }

    await promptsCollection.doc(promptID).delete();

    await userCollection.doc(userID).update({
      createdPrompts: admin.firestore.FieldValue.arrayRemove(promptID),
    });

    return res.status(200).send("OK");
  } else {
    res.status(400).send(`Prompt with id [${promptID}] does not exist`);
    return;
  }
});

app.post("/getPrompt", async (req: Request, res: Response) => {
  const promptID = req.body.promptID;

  if (!promptID) {
    res.status(400).send("promptID is required");
    return;
  }

  if (typeof promptID !== "string") {
    res.status(400).send("promptID must be a string");
    return;
  }

  const promptRef = await promptsCollection.doc(promptID).get();

  if (promptRef.exists) {
    return res.status(200).send(promptRef.data());
  } else {
    res.status(400).send(`Prompt with id [${promptID}] does not exist`);
    return;
  }
});

app.post("/getPrompts", async (req: Request, res: Response) => {
  const userID = req.headers.userID;
  const promptIDs = req.body.promptIDs;

  if (!userID) {
    res.status(400).send("userID is required");
    return;
  }

  if (typeof userID !== "string") {
    res.status(400).send("userID must be a string");
    return;
  }

  if (!promptIDs) {
    res.status(400).send("promptIDs is required");
    return;
  }

  if (!Array.isArray(promptIDs)) {
    res.status(400).send("promptIDs must be an array");
    return;
  }

  // List of strings only.
  if (promptIDs.some((id) => typeof id !== "string")) {
    res.status(400).send("promptIDs must be an array of strings");
    return;
  }

  // Cannot be empty or exceed 100.
  if (promptIDs.length === 0 || promptIDs.length > 100) {
    res.status(400).send("promptIDs must be between 1 and 100 items");
    return;
  }

  const userRef = await userCollection.doc(userID).get();

  if (userRef.exists) {
    // collection query for id.
    const promptDocs = await promptsCollection
      .where("id", "in", promptIDs)
      .get();

    const prompts = promptDocs.docs.map((doc) => doc.data());

    return res.status(200).send(prompts);
  } else {
    res.status(400).send(`User with id [${userID}] does not exist`);
    return;
  }
});

app.post("/upvotePrompt", async (req: Request, res: Response) => {
  const userID = req.headers.userID;
  const promptID = req.body.promptID;

  if (!userID) {
    res.status(400).send("userID is required");
    return;
  }

  if (typeof userID !== "string") {
    res.status(400).send("userID must be a string");
    return;
  }

  if (!promptID) {
    res.status(400).send("promptID is required");
    return;
  }

  if (typeof promptID !== "string") {
    res.status(400).send("promptID must be a string");
    return;
  }

  const promptRef = await promptsCollection.doc(promptID).get();

  if (!promptRef.exists) {
    res.status(400).send(`Prompt with id [${promptID}] does not exist`);
    return;
  }

  const promptData: FirebaseFirestore.DocumentData | undefined =
    promptRef.data();
  const promptModel: Prompt = promptData as Prompt;

  if (promptModel.upvotes.includes(userID)) {
    res.status(400).send("You have already upvoted this prompt");
    return;
  }

  const promptUpdate = {
    upvotes: [...promptModel.upvotes, userID],
  };

  await promptsCollection.doc(promptID).set(promptUpdate, {merge: true});
});

app.post("/unUpvotePrompt", async (req: Request, res: Response) => {
  const userID = req.headers.userID;
  const promptID = req.body.promptID;

  if (!userID) {
    res.status(400).send("userID is required");
    return;
  }

  if (typeof userID !== "string") {
    res.status(400).send("userID must be a string");
    return;
  }

  if (!promptID) {
    res.status(400).send("promptID is required");
    return;
  }

  if (typeof promptID !== "string") {
    res.status(400).send("promptID must be a string");
    return;
  }

  const promptRef = await promptsCollection.doc(promptID).get();

  if (!promptRef.exists) {
    res.status(400).send(`Prompt with id [${promptID}] does not exist`);
    return;
  }

  const promptData: FirebaseFirestore.DocumentData | undefined =
    promptRef.data();
  const promptModel: Prompt = promptData as Prompt;

  if (!promptModel.upvotes.includes(userID)) {
    res.status(400).send("You have not upvoted this prompt");
    return;
  }

  const promptUpdate = {
    upvotes: promptModel.upvotes.filter((id) => id !== userID),
  };

  await promptsCollection.doc(promptID).set(promptUpdate, {merge: true});
});

app.post("/updatePinnedPrompts", async (req: Request, res: Response) => {
  const userID = req.headers.userID;
  const pinnedPrompts = req.body.pinnedPrompts; // array of prompts

  if (!userID) {
    res.status(400).send("userID is required");
    return;
  }

  if (typeof userID !== "string") {
    res.status(400).send("userID must be a string");
    return;
  }

  if (!pinnedPrompts) {
    res.status(400).send("prompts is required");
    return;
  }

  if (!Array.isArray(pinnedPrompts)) {
    res.status(400).send("prompts must be an array");
    return;
  }

  // Check if it's an array of strings.
  if (!pinnedPrompts.every((prompt) => typeof prompt === "string")) {
    res.status(400).send("prompts must be an array of strings");
    return;
  }
  // Check if every string is less than 5000 but more than 20 chars.
  if (
    !pinnedPrompts.every((prompt) => prompt.length < 5000 && prompt.length > 20)
  ) {
    res.status(400).send("Prompt must be between 20 and 5000 characters");
    return;
  }
  // Make sure the list is of unique elements.
  if (new Set(pinnedPrompts).size !== pinnedPrompts.length) {
    res.status(400).send("prompts must be a list of unique prompts");
    return;
  }

  const userDoc = await db.collection("users").doc(userID);

  await userDoc.set({pinnedPrompts: pinnedPrompts}, {merge: true});
});

// Expose Express API as a single Cloud Function:
exports.widgets = functions
  .runWith({secrets: ["OPEN_AI_KEY"]})
  .https.onRequest(app);
