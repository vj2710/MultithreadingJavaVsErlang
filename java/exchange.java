import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class exchange {

    static HashMap<String, Caller> caller = new HashMap<String, Caller>();
    static List<List<String>> mainList = new ArrayList<List<String>>();
    static long messageRecvdTime;
    public static void main(String[] args) throws IOException {

        exchange exchange = new exchange();
        BufferedReader reader = new BufferedReader(new FileReader("calls.txt"));
        String line = reader.readLine();

        System.out.println("** Calls to be made **");
        while(line!=null){
            String[] splitLine = line.split("\\W+");
            List<String> listString = new ArrayList<>();
            for(int i =1; i<splitLine.length; i++) {
                listString.add(splitLine[i]);
                if(i==1){
                    System.out.print(splitLine[i]+": [");
                }
                else if(i == (splitLine.length-1)){
                    System.out.print(splitLine[i]+"] \n");
                }
                else{
                    System.out.print(splitLine[i]+", ");
                }
            }
            mainList.add(listString);
            line = reader.readLine();
        }
        System.out.println();


        for(int i =0;i<mainList.size();i++){
            caller.put(mainList.get(i).get(0), new Caller(exchange.returnRecipList(i), mainList.get(i).get(0)));
        }

        try {
            Thread.sleep(100);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }


        for(int i =0;i<mainList.size();i++){
            caller.get(mainList.get(i).get(0)).start();
        }

        messageRecvdTime = System.currentTimeMillis();
        while(true){
            if((System.currentTimeMillis() - messageRecvdTime) > 1500){
                System.out.println();
                System.out.println("Master has received no replies for 1.5 seconds, ending...");
                break;
            }
        }

        reader.close();

    }

    public List<String> returnRecipList(int i){
        List<String> recipList = new ArrayList<>();
        for(int j =1; j<mainList.get(i).size(); j++){
            recipList.add(mainList.get(i).get(j));
        }
        return  recipList;
    }

    public static synchronized void printMessages(String type, String to, String from, long msgTime){
        messageRecvdTime = System.currentTimeMillis();
        if(type.equals("intro")){
            System.out.println(to + " received intro message from " + from + " ["+msgTime+"] ");
        }
        else if(type.equals("reply")){
            System.out.println(to + " received reply message from " + from + " ["+msgTime+"] ");
        }

    }
}
