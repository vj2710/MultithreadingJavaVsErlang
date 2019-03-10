import java.util.*;
import java.util.Collections;

public class Caller extends Thread {

    String myName;
    List<String> recipients;
    List<Messages> messages;
    long entryTime;
    Random rand = new Random();

    public void run(){

        this.entryTime = System.currentTimeMillis();
        for (String obj : recipients) {
            String recipientName = obj;
            Caller recipientObj = exchange.caller.get(recipientName);
            Messages msg = new Messages("intro", myName, 0);
            recipientObj.messages.add(msg);
        }

        while(true) {
            if(messages.size()>0) {
                this.entryTime = System.currentTimeMillis();
                try {
                    Messages recentMessage = messages.remove(0);
                    if (recentMessage.messageType.equals("intro")) {
                        Thread.sleep(rand.nextInt(100)+1);
                        long msgTime = System.currentTimeMillis();
                        exchange.printMessages("intro", myName, recentMessage.fromName, msgTime );
                        Caller responseObj = exchange.caller.get(recentMessage.fromName);
                        Messages msg = new Messages("reply", myName, msgTime);
                        responseObj.messages.add(msg);

                    } else if (recentMessage.messageType.equals("reply")) {
                        Thread.sleep(rand.nextInt(100)+1);
                        exchange.printMessages("reply", myName, recentMessage.fromName, recentMessage.msgTime);
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            if((System.currentTimeMillis() - this.entryTime) > 1000 ){
                System.out.println();
                System.out.println("Process "+ myName +" has received no calls for 1 second, ending...");
                break;
            }

        }
    }

    Caller(List<String> recipList, String name){
        this.messages = Collections.synchronizedList(new ArrayList<Messages>());
        this.myName = name;
        this.recipients = recipList;
    }
}
