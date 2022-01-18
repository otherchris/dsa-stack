import { AppDataContextType } from "./AppDataProvider";

export const messageHandler = (m: MessageEvent, a: AppDataContextType) => {
  const { "message-type": messageType, message } = JSON.parse(m.data);
  console.log(`Message: ${JSON.stringify(message)}`);
  console.log(`Message type: ${JSON.stringify(messageType)}`);
  switch (messageType) {
    case "meeting-data":
      console.log("doin it");
      a.setMeetingData(cleanMeetingData(JSON.stringify(message)));
      break;
    case "participant-id":
      a.setParticipantId(message["participant-id"]);
      break;
    default:
      break;
  }
};

export const startMeetingFunc = (s: WebSocket, a: AppDataContextType) => {
  const { setAppType } = a;
  if (s.readyState !== 1) {
    console.log(`tried to sendStartMeeting: readyState: ${s.readyState}`);
    return;
  }
  s.send(JSON.stringify({ command: "start-meeting" }));
  setAppType("admin");
};

export const joinMeetingFunc = (
  s: WebSocket,
  a: AppDataContextType,
  dn: string,
  mc: string
) => {
  const { setAppType } = a;
  if (s.readyState !== 1) {
    console.log(`tried to joinMeeting: readyState: ${s.readyState}`);
    return;
  }
  s.send(
    JSON.stringify({
      command: "join-meeting",
      payload: { "display-name": dn, "meeting-code": mc },
    })
  );
  setAppType("participant");
};

export const createStackFunc = (
  s: WebSocket,
  a: AppDataContextType,
  stackName: string
) => {
  const {
    meetingData: { code },
  } = a;
  if (s.readyState !== 1) {
    console.log(`tried to sendCreateStack: readyState: ${s.readyState}`);
    return;
  }
  s.send(
    JSON.stringify({
      command: "create-stack",
      payload: { "display-name": stackName, "meeting-code": code },
    })
  );
};

export const joinStackFunc = (
  s: WebSocket,
  a: AppDataContextType,
  stackId: string
) => {
  const {
    participantId,
    meetingData: { code },
  } = a;
  if (s.readyState !== 1) {
    console.log(`tried to joinStack: readyState: ${s.readyState}`);
    return;
  }
  s.send(
    JSON.stringify({
      command: "join-stack",
      payload: {
        "meeting-code": code,
        "stack-id": stackId,
        "participant-id": participantId,
      },
    })
  );
};

export const openStackFunc = (
  s: WebSocket,
  a: AppDataContextType,
  stackId: string
) => {
  if (s.readyState !== 1) {
    console.log(`tried to openStack: readyState: ${s.readyState}`);
    return;
  }
  const {
    meetingData: { code },
  } = a;
  s.send(
    JSON.stringify({
      command: "open-stack",
      payload: { "stack-id": stackId, "meeting-code": code },
    })
  );
};

export const closeStackFunc = (
  s: WebSocket,
  a: AppDataContextType,
  stackId: string
) => {
  if (s.readyState !== 1) {
    console.log(`tried to closeStack: readyState: ${s.readyState}`);
    return;
  }
  const {
    meetingData: { code },
  } = a;
  s.send(
    JSON.stringify({
      command: "close-stack",
      payload: { "stack-id": stackId, "meeting-code": code },
    })
  );
};

const cleanMeetingData = (meeting: string) => {
  const newString = meeting.replace(/display_name/g, "displayName");
  return JSON.parse(newString);
};
