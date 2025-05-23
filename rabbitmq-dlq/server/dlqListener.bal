import ballerina/io;
import ballerinax/rabbitmq;

const string DLX_QUEUE = "my.dlq";

listener rabbitmq:Listener dlListener = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);

@rabbitmq:ServiceConfig {
    queueName: DLX_QUEUE,
    config: {
        durable: true
    }
}
service on dlListener {

    remote function onMessage(rabbitmq:BytesMessage m, rabbitmq:Caller caller) returns error? {
        string deadPayload = check string:fromBytes(m.content);
        // …decide whether to retry, log, alert, etc.
        io:println("⚠️  Dead-letter received: " + deadPayload);
    }
}
