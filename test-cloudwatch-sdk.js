// test-cloudwatch-sdk.js
const { CloudWatchLogsClient, CreateLogGroupCommand, CreateLogStreamCommand, PutLogEventsCommand, DescribeLogStreamsCommand } = require("@aws-sdk/client-cloudwatch-logs");

const LOG_GROUP = "espasyo-frontend-dev";
const LOG_STREAM = "frontend-app";
const client = new CloudWatchLogsClient({
  region: "us-east-1",
  endpoint: "http://localhost:4566",
  credentials: { accessKeyId: "test", secretAccessKey: "test" },
});

async function main() {
  try {
    await client.send(new CreateLogGroupCommand({ logGroupName: LOG_GROUP }));
  } catch (e) {
    console.log("Log group exists or error:", e.name);
  }
  try {
    await client.send(new CreateLogStreamCommand({ logGroupName: LOG_GROUP, logStreamName: LOG_STREAM }));
  } catch (e) {
    console.log("Log stream exists or error:", e.name);
  }
  const describe = await client.send(new DescribeLogStreamsCommand({ logGroupName: LOG_GROUP }));
  const stream = describe.logStreams.find(s => s.logStreamName === LOG_STREAM);
  const sequenceToken = stream?.uploadSequenceToken;
  const event = {
    message: "Test event from Node.js SDK",
    timestamp: Date.now(),
  };
  const putRes = await client.send(new PutLogEventsCommand({
    logGroupName: LOG_GROUP,
    logStreamName: LOG_STREAM,
    logEvents: [event],
    sequenceToken,
  }));
  console.log("PutLogEvents result:", putRes);
}

main().catch(console.error);
