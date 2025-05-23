import ballerinax/rabbitmq;

const string DLX = "my.dlx";
const string DLX_QUEUE = "my.dlq";
const string DLX_ROUTING = "dead-route";
const string MAIN_EXCH = "orders.x";
const string MAIN_QUEUE = "orders.q";
const string MAIN_ROUTING = "order.created";

function init() returns error? {
    // 1️⃣  Connect
    rabbitmq:Client clientEP = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);

    // 2️⃣  Declare DLX & DLQ
    check clientEP->exchangeDeclare(DLX, rabbitmq:DIRECT_EXCHANGE);
    check clientEP->queueDeclare(DLX_QUEUE, {durable: true});
    check clientEP->queueBind(DLX_QUEUE, DLX, DLX_ROUTING);
 
    // 3️⃣  Declare main exchange
    check clientEP->exchangeDeclare(MAIN_EXCH, rabbitmq:DIRECT_EXCHANGE);

    // 4️⃣  Declare main queue **with DLX arguments**
    map<anydata> dlxArgs = {
        "x-dead-letter-exchange": DLX,
        "x-dead-letter-routing-key": DLX_ROUTING
    };
    rabbitmq:QueueConfig qCfg = {
        durable: true,
        arguments: dlxArgs
    };
    check clientEP->queueDeclare(MAIN_QUEUE, qCfg);
    check clientEP->queueBind(MAIN_QUEUE, MAIN_EXCH, MAIN_ROUTING);
}
