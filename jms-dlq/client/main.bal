import ballerinax/activemq.driver as _;
import ballerinax/java.jms;

public function main() returns error? {
    jms:Connection connection = check new (
        initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl = "tcp://localhost:61616"
    );
    jms:Session session = check connection->createSession();
    jms:MessageProducer orderProducer = check session.createProducer({
        'type: jms:QUEUE,
        name: "orders.q"
    });
    jms:MapMessage message = {content: {"orderId": 1234, "item": "Laptop", "quantity": 1}};
    check orderProducer->send(message);
}
