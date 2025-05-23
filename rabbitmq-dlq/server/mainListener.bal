import ballerinax/rabbitmq;
import ballerina/io;

const string DLX = "my.dlx";
const string DLX_QUEUE = "my.dlq";
const string DLX_ROUTING = "dead-route";
const string MAIN_QUEUE = "orders.q";

// 6️⃣  Spin up a listener that **intentionally rejects** to show DLX flow
listener rabbitmq:Listener listenerEP = check new ("localhost", 5672);

@rabbitmq:ServiceConfig {
    queueName: MAIN_QUEUE,
    config: {
        durable: true,
        arguments: {
            "x-dead-letter-exchange": DLX,
            "x-dead-letter-routing-key": DLX_ROUTING
        }
    },
    autoAck: false
}
service on listenerEP {

    remote function onMessage(rabbitmq:BytesMessage message, rabbitmq:Caller caller) returns error? {
        io:println("📦  Received message: " + check string:fromBytes(message.content));
        // Pretend processing failed → reject without requeue
        check caller->basicNack(true, false);
    }
}
