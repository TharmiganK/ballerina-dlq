import ballerina/http;
import ballerina/io;
import ballerinax/activemq.driver as _;
import ballerinax/java.jms;

listener jms:Listener mainListener = check new (
    connectionConfig = {
        initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl: "tcp://localhost:61616"
    },
    consumerOptions = {
        destination: {
            'type: jms:QUEUE,
            name: "orders.q"
        }
    }
);

service on mainListener {

    remote function onMessage(jms:Message message) returns error? {
        io:println("📦  Received message: " + message.toString());
        do {
            map<anydata> messageContent = check message["content"].cloneWithType();
            http:Client httpClient = check new ("http://localhost:8080/api/v1");
            anydata _ = check httpClient->/orders.post(messageContent);
        } on fail error err {
            jms:Connection connection = check new (
                initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
                providerUrl = "tcp://localhost:61616"
            );
            jms:Session session = check connection->createSession();
            jms:MessageProducer orderProducer = check session.createProducer({
                'type: jms:QUEUE,
                name: "my.dlq"
            });
            jms:TextMessage dlqMessage = {
                content: {
                    jmsMessage: message,
                    errMessage: err.message()
                }.toString()
            };
            check orderProducer->send(dlqMessage);
        }
    }
}
