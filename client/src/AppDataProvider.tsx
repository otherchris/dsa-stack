import React, { createContext, FC, useState } from "react";
import { AppData, AppType, MeetingData } from "./types";

const initMeetingData: MeetingData = {
  code: "IOXOX",
  participants: [
    {
      id: "PART_ID",
      displayName: "A. Guy",
      talkTimes: 0,
    },
  ],
  stacks: [
    {
      id: "s1",
      displayName: "a stack",
      participants: ["PART_ID"],
      state: "open",
    },
    {
      id: "s2",
      displayName: "an empty stack",
      participants: [],
      state: "pending",
    },
  ],
};

const initData: AppData = {
  appType: "init",
  participantId: "PART_ID",
  meetingData: initMeetingData,
};

interface AppDataFunctions {
  setAppType: (type: AppType) => void;
  setMeetingData: (md: MeetingData) => void;
  setParticipantId: (pid: string) => void;
}

export type AppDataContextType = AppData & AppDataFunctions;

export const AppDataContext = createContext<AppDataContextType>({
  ...initData,
  setAppType: () => {},
  setMeetingData: () => {},
  setParticipantId: () => {},
});

const AppDataProvider: FC = ({ children }) => {
  const [appType, setAppType] = useState<AppType>("init");
  const [participantId, setParticipantId] = useState<string>("");
  const [meetingData, setMeetingData] = useState<MeetingData>(initMeetingData);
  return (
    <AppDataContext.Provider
      value={{
        ...initData,
        meetingData,
        participantId,
        appType,
        setAppType,
        setMeetingData,
        setParticipantId,
      }}
    >
      {children}
    </AppDataContext.Provider>
  );
};

export default AppDataProvider;
