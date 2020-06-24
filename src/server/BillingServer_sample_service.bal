import ballerina/grpc;
import ballerina/log;

listener grpc:Listener ep = new (9090);

service BillingServer on ep {

    // Client streaming resource
    resource function quickBilling(grpc:Caller caller, stream<InputValue,error> clientStream) {
        int totalNumber = 0;
        float totalBill = 0;
        log:printInfo("Starting Quick Billing Service");

        //Iterating through streamed messages here
        error? e = clientStream.forEach(function(InputValue value) {
        	log:printInfo("Item:" + value.itemName + " Quantity:" + value.quantity.toString() + " Price:" + value.price.toString());
            totalNumber += value.quantity;            
            totalBill += (value.quantity * value.price);
        });

        //Once the client completes stream, a grpc:EOS error is returned to indicate it
        if (e is grpc:EOS) {
            Bill finalBill = {
                billType: "Final Bill",
                totalQuantity: totalNumber,
                totalPrice: totalBill
            };
            //Sending the total bill to the client
            grpc:Error? result = caller->send(finalBill);
            if (result is grpc:Error) {
                log:printError("Error occured when sending the bill: " + result.message() + " - " + <string>result.detail()["message"]);
            } else {
                log:printInfo ("Sending Final Bill Total: " + finalBill.totalPrice.toString() + 
                                            " for " + finalBill.totalQuantity.toString() + " items");
            }
            result = caller->complete();
            if (result is grpc:Error) {
                log:printError("Error occured when closing the connection: " + result.message() +
                                            " - " + <string>result.detail()["message"]);
            }
        }
        //If the client sends an error instead it can be handled here
        else if (e is grpc:Error) {
            log:printError("An unexpected error occured: " + e.message() + " - " + <string>e.detail()["message"]);
        }

    }

    // Bi-directional streaming resource
    resource function oneByOneBilling(grpc:Caller caller, stream<InputValue,error> clientStream) {
        int totalNumber = 0;
        float totalBill = 0;
        log:printInfo("Starting One by One Billing Service");
        //Iterating through streamed messages here
        error? e = clientStream.forEach(function(InputValue value) {
        	log:printInfo("Item:" + value.itemName + " Quantity:" + value.quantity.toString() + " Price:" + value.price.toString());
            totalNumber += value.quantity;            
            totalBill += (value.quantity * value.price);
            
            Bill tempBill = {
                billType: "Interim Bill",
                totalQuantity: totalNumber,
                totalPrice: totalBill
            };
            //Sending the interim bill to the client
            grpc:Error? result = caller->send(tempBill);
            if (result is grpc:Error) {
                log:printError("Error occured when sending the bill: " + result.message() + " - " + <string>result.detail()["message"]);
            } else {
                log:printInfo ("Sending Interim Bill Total: " + tempBill.totalPrice.toString() +
                                                " for " + tempBill.totalQuantity.toString() + " items");
            }
        });

        //Once the client completes stream, a grpc:EOS error is returned to indicate it
        if (e is grpc:EOS) {
            Bill finalBill = {
                billType: "Final Bill",
                totalQuantity: totalNumber,
                totalPrice: totalBill
            };
            //Sending the total bill to the client
            grpc:Error? result = caller->send(finalBill);
            if (result is grpc:Error) {
                log:printError("Error occured when sending the bill: " + result.message() + " - " + <string>result.detail()["message"]);
            } else {
                log:printInfo ("Sending Final Bill Total: " + finalBill.totalPrice.toString() + 
                                            " for " + finalBill.totalQuantity.toString() + " items");
            }
            result = caller->complete();
            if (result is grpc:Error) {
                log:printError("Error occured when closing the connection: " + result.message() +
                                            " - " + <string>result.detail()["message"]);
            }
        }
        //If the client sends an error instead it can be handled here
        else if (e is grpc:Error) {
            log:printError("An unexpected error occured: " + e.message() + " - " + <string>e.detail()["message"]);
        }
    }
}

public type InputValue record {|
    string itemName = "";
    int quantity = 0;
    float price = 0.0;
    
|};

public type Bill record {|
    string billType = "";
    int totalQuantity = 0;
    float totalPrice = 0.0;
    
|};


const string ROOT_DESCRIPTOR = "0A0A737475622E70726F746F120773657276696365225A0A0A496E70757456616C7565121A0A086974656D4E616D6518012001280952086974656D4E616D65121A0A087175616E7469747918022001280352087175616E7469747912140A0570726963651803200128025205707269636522680A0442696C6C121A0A0862696C6C54797065180120012809520862696C6C5479706512240A0D746F74616C5175616E74697479180220012803520D746F74616C5175616E74697479121E0A0A746F74616C5072696365180320012802520A746F74616C50726963653280010A0D42696C6C696E6753657276657212340A0C717569636B42696C6C696E6712132E736572766963652E496E70757456616C75651A0D2E736572766963652E42696C6C280112390A0F6F6E6542794F6E6542696C6C696E6712132E736572766963652E496E70757456616C75651A0D2E736572766963652E42696C6C28013001620670726F746F33";
function getDescriptorMap() returns map<string> {
    return {
        "stub.proto":"0A0A737475622E70726F746F120773657276696365225A0A0A496E70757456616C7565121A0A086974656D4E616D6518012001280952086974656D4E616D65121A0A087175616E7469747918022001280352087175616E7469747912140A0570726963651803200128025205707269636522680A0442696C6C121A0A0862696C6C54797065180120012809520862696C6C5479706512240A0D746F74616C5175616E74697479180220012803520D746F74616C5175616E74697479121E0A0A746F74616C5072696365180320012802520A746F74616C50726963653280010A0D42696C6C696E6753657276657212340A0C717569636B42696C6C696E6712132E736572766963652E496E70757456616C75651A0D2E736572766963652E42696C6C280112390A0F6F6E6542794F6E6542696C6C696E6712132E736572766963652E496E70757456616C75651A0D2E736572766963652E42696C6C28013001620670726F746F33"
        
    };
}

