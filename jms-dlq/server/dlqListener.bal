import ballerinax/java.jms;
import ballerina/io;

listener jms:Listener dlListener = check new (
    connectionConfig = {
        initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl: "tcp://localhost:61616"
    },
    consumerOptions = {
        destination: {
            'type: jms:QUEUE,
            name: "my.dlq"
        }
    }
);

service on dlListener {

    remote function onMessage(jms:Message message) returns error? {
        io:println("⚠️  Dead-letter received: " + message["content"].toString());
    }
}

