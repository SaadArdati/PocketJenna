export interface UserModel {
  id: string;
  tokens: number;
  chatSnippets: { [key: string]: ChatSnippet };
  updatedOn: number;
  createdOn: number;
  pinnedPrompts: string[];
  createdPrompts: string[];
}

export interface ChatSnippet {
  id: string;
  snippet: string;
  promptTitle: string;
  promptIcon: string;
  updatedOn: number;
}

export interface Chat {
  id: string;
  prompt: Prompt;
  messages: ChatMessage[];
  createdOn: Date;
  updatedOn: Date;
}

export interface ChatMessage {
  id: string;
  role: ChatMessageRole;
  timestamp: number;
  text: string;
  status: MessageStatus;
}

export enum ChatMessageRole {
  system = "system",
  user = "user",
  assistant = "assistant",
}

export enum MessageStatus {
  waiting,
  streaming,
  done,
  errored,
}

export interface Prompt {
  id: string;
  userID: string;
  prompts: string[];
  title: string;
  description: string;
  upvotes: string[];
  icon: string;
  createdOn: number;
  updatedOn: number;
  public: number;
}
