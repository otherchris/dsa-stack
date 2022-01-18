type StackState = "pending" | "open" | "closed";
export type AppType = "init" | "participant" | "admin";

export interface Stack {
  id: string;
  displayName: string;
  participants: Array<string>;
  state: StackState;
}

export interface Participant {
  id: string;
  displayName: string;
  talkTimes: number;
}

export interface MeetingData {
  code: string;
  participants: Array<Participant>;
  stacks: Array<Stack>;
}

export interface AppData {
  appType: AppType;
  participantId: string;
  meetingData: MeetingData;
}
