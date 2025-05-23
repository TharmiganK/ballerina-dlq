import ballerinax/rabbitmq;

rabbitmq:Client clientEP = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);

const string MAIN_EXCH = "orders.x";
const string MAIN_QUEUE = "orders.q";
const string MAIN_ROUTING = "order.created";

public function main() returns error? {
    // 5️⃣  Publish a test message
    byte[] body = "Order 42".toBytes();
    check clientEP->publishMessage({
        exchange: MAIN_EXCH,
        routingKey: MAIN_ROUTING,
        content: body
    });
}
