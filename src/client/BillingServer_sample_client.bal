import ballerina/grpc;
import ballerina/io;

string opMode = "";

public function main (string mode) {

    BillingServerClient ep = new("http://localhost:9090");

    grpc:StreamingClient | grpc:Error streamClient;

    if (mode == "quick") {
        opMode = "Quick";
        // Initialize call with quickBilling resource
        streamClient = ep->quickBilling(BillingServerMessageListener);
    } else if (mode == "oneByOne") {
        opMode = "One by one";
        // Initialize call with oneByOneBilling resource
        streamClient = ep->oneByOneBilling(BillingServerMessageListener);
    } else {
        io:println("Unsupported operation mode entered!");
        return;
    }

    if (streamClient is grpc:Error) {
        io:println("Error from Connector: " + streamClient.message() + " - "
                                           + <string>streamClient.detail()["message"]);
        return;
    } else {
        //Start sending messages to the server
        io:println("Starting " + opMode + " billing service");
        // Sending first message
        InputValue item = {
            itemName: "Apples",
            quantity: 4,
            price: 30.50
        };
        grpc:Error? connErr = streamClient->send(item);
        if (connErr is grpc:Error) {
            io:println("Error from Connector: " + connErr.message() + " - "
                                           + <string>connErr.detail()["message"]);            
        } else {
            io:println("Sent item: " + item.itemName + " Quantity: " + item.quantity.toString() +
                                        " Price: " + item.price.toString());
        }

        // Sending second message
        item = {
            itemName: "Oranges",
            quantity: 6,
            price: 43.4
        };
        connErr = streamClient->send(item);
        if (connErr is grpc:Error) {
            io:println("Error from Connector: " + connErr.message() + " - "
                                           + <string>connErr.detail()["message"]);            
        } else {
            io:println("Sent item: " + item.itemName + " Quantity: " + item.quantity.toString() + 
                                        " Price: " + item.price.toString());
        }

        // Sending third message
        item = {
            itemName: "Grapes",
            quantity: 20,
            price: 11.5
        };
        connErr = streamClient->send(item);
        if (connErr is grpc:Error) {
            io:println("Error from Connector: " + connErr.message() + " - "
                                           + <string>connErr.detail()["message"]);            
        } else {
            io:println("Sent item: " + item.itemName + " Quantity: " + item.quantity.toString() + 
                                        " Price: " + item.price.toString());
        }

        // Sending complete signal
        connErr = streamClient->complete();
        if (connErr is grpc:Error) {
            io:println("Error from Connector: " + connErr.message() + " - "
                                           + <string>connErr.detail()["message"]);            
        }
    }
}

// Message listener for incoming messages
service BillingServerMessageListener = service {

    resource function onMessage(Bill message) {
        io:println("Recieved " + message.billType  + "Total: " + message.totalPrice.toString() +
                                                " for " + message.totalQuantity.toString() + " items" );
    }

    resource function onError(error err) {
        io:println("Error reported from server: " + err.message() + " - "
                                           + <string>err.detail()["message"]);
    }

    resource function onComplete() {
        io:println(opMode +" billing completed");
    }
};
