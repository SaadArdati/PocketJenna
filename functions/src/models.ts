export interface Chat {
  id: string;
  prompt: Prompt;
  messages?: ChatMessage[];
  createdOn?: Date;
  updatedOn?: Date;

  toFullChat: () => ChatMessage[];
}

export interface ChatMessage {
  id: string;
  role: ChatMessageRole;
  timestamp: number;
  text: string;
  status: MessageStatus;
}

export enum ChatMessageRole { system, user, assistant }

// The network status of a message.
export enum MessageStatus {
  // The message is waiting for a network response.
  waiting,

  // The message is being streamed actively from the network.
  streaming,

  // The message has been completely received, either instantly or after being
  // streamed.
  done,

  // The message had an error occur at some point.
  errored,
}

// class Prompt with EquatableMixin{
//   final String id;
//   final List<String> prompts;
//   final String title;
//   final String icon;

export interface Prompt {
  id: string;
  prompts: string[];
  title: string;
  icon: string;
}
