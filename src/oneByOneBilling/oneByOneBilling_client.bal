import ballerina/grpc;
import ballerina/io;

public function main (string... args) {

    BillingServerClient ep = new("http://localhost:9090");
    grpc:StreamingClient | grpc:Error streamClient = ep->oneByOneBilling(BillingServerMessageListener);
    if (streamClient is grpc:Error) {
        io:println("Error from Connector: " + streamClient.message() + " - "
                                           + <string>streamClient.detail()["message"]);
        return;
    } else {
        //Start sending messages to the server
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

        connErr = streamClient->complete();
        if (connErr is grpc:Error) {
            io:println("Error from Connector: " + connErr.message() + " - "
                                           + <string>connErr.detail()["message"]);            
        }
    }
}

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
        io:println("One by one billing completed");
    }
};

