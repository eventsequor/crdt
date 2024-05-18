# Crdt
@autor Eder Leandro Carbonero Baquero

## Content
- [Description](#Description)
- [Example of use](#Example-of-use)
- [How to use it?](#How-to-use-it?)
- [Getting Started](#Getting-Started)

## Description
This implementation uses a CRDT to manage a chat room, the idea is that all participants can contribute or post messages to the chat room and if the user eventually disconnects, their messages will be only in his CRDT, but we he return on the network they has to sync his message again the all message of the rest of the nodes connected.

Base on the requeriment we implement a chat room only using four general interfaces.
- insert(msg)
- delete(pos_id)
- print_all_messages()
- print_actual()

The module is called Chat and behind there is a treedoc that save the message into his buffer as
is describe by "A commutative replicated data type for cooperative editing" paper

## Example of use

In this example we are going to use a couple of nodes, at the begining they are going to be connected

### Step 1 - Check node network connection
Check they are in the same network, please check [Getting Started](#Getting-Started) if you can see the nodes in network

**Node 1**
The node one has the name **nerves@192.168.0.6**
``` elixir
iex(nerves@192.168.0.6)5> Node.list
[:"Node2@192.168.0.6"]
``` 

**Node 2**
The node one has the name **nerves@192.168.0.6**
``` elixir
iex(Node2@192.168.0.6)2> Node.list
[:"nerves@192.168.0.6"]
```

### Step 2 - Write message

In this case you will see a scalar number to describe the order in which the message was written over time. This gives you an idea of how the order of messages should look when you print them via the Chat.print_all_messages function.
Follow the same order to test the system.

**Node 1**
``` elixir
iex(nerves@192.168.0.6)7> Chat.insert "Mesage 1"
{:ok, "1716050462541_nerves"}
```

**Node 2**
``` elixir
iex(Node2@192.168.0.6)4> Chat.insert "Message 2"
{:ok, "1716050477581_Node2"}
```

**Node 1**
``` elixir
iex(nerves@192.168.0.6)8> Chat.insert "Mesage 3"
{:ok, "1716050546981_nerves"}
```

**Node 2**
``` elixir
iex(Node2@192.168.0.6)5> Chat.insert "Message 4"
{:ok, "1716050554206_Node2"}
```

Now you have four messages and they were written in the following order in time

- Message 1
- Message 2
- Message 3
- Message 4

### Step 3 - Check all nodes has the same message in the correct order

**Node 1**
``` elixir
iex(nerves@192.168.0.6)10> Chat.print_all_messages
"PosID: 1716050462541_nerves - Message: Mesage 1"
"PosID: 1716050477581_Node2 - Message: Message 2"
"PosID: 1716050546981_nerves - Message: Mesage 3"
"PosID: 1716050554206_Node2 - Message: Message 4"
```

**Node 2**
``` elixir
iex(Node2@192.168.0.6)7> Chat.print_all_messages
"PosID: 1716050462541_nerves - Message: Mesage 1"
"PosID: 1716050477581_Node2 - Message: Message 2"
"PosID: 1716050546981_nerves - Message: Mesage 3"
"PosID: 1716050554206_Node2 - Message: Message 4"
:ok
```
As you can see all message are in the both nodes in the same order

### Step 4 - Disconnect the nodes and append more messages

**Node 1**
``` elixir
iex(nerves@192.168.0.6)11> Node.disconnect :"Node2@192.168.0.6"
true
iex(nerves@192.168.0.6)12> Node.list
[]
```
Now there are not a connection between the nodes.

It is time to insert new messages

**Node 1**
``` elixir
iex(nerves@192.168.0.6)15> Chat.insert "Message 5"
{:ok, "1716051382961_nerves"}
``` 

**Node 2**
``` elixir
iex(Node2@192.168.0.6)9> Chat.insert "Message 6"
{:ok, "1716051394679_Node2"}
``` 

At this point, both Crdt have inconsistencies.

### Step 5 - Print both CRDT 
In this point we have a couple of CRDT with inconsistencies, because they has not a connection

**Node 1**
``` elixir
iex(nerves@192.168.0.6)16> Chat.print_all_messages
"PosID: 1716050462541_nerves - Message: Mesage 1"
"PosID: 1716050477581_Node2 - Message: Message 2"
"PosID: 1716050546981_nerves - Message: Mesage 3"
"PosID: 1716050554206_Node2 - Message: Message 4"
"PosID: 1716051382961_nerves - Message: Message 5"
``` 

**Node 2**
``` elixir
iex(Node2@192.168.0.6)10> Chat.print_all_messages
"PosID: 1716050462541_nerves - Message: Mesage 1"
"PosID: 1716050477581_Node2 - Message: Message 2"
"PosID: 1716050546981_nerves - Message: Mesage 3"
"PosID: 1716050554206_Node2 - Message: Message 4"
"PosID: 1716051394679_Node2 - Message: Message 6"
``` 

As you can see there are message that are not present in both nodes.

### Step 6 - Delete one of the message in a node disconnected

For this select the node one or two, they are disconnected to each other, select one of the message that are present in both nodes, delete it, and print only the active message, the check the other node has the same message active.

**Node 1**
The message selecte is the node with pos_id = 1716050477581_Node2, with value "Message 2"

``` elixir
iex(nerves@192.168.0.6)18> Chat.delete "1716050477581_Node2"
{:ok, "1716050477581_Node2"}
``` 

In this point the node 1 has one message delete, to confirm this we have to print only the message active or no deleted, the next sentence shows that.

``` elixir
iex(nerves@192.168.0.6)19> Chat.print_actual
"PosID: 1716050462541_nerves - Message: Mesage 1"
"PosID: 1716050546981_nerves - Message: Mesage 3"
"PosID: 1716050554206_Node2 - Message: Message 4"
"PosID: 1716051382961_nerves - Message: Message 5"
:ok
``` 

To make sure there is not an impact in the node 2 we will print the message, in the second node all message should be present.

**Node 2**

``` elixir
iex(Node2@192.168.0.6)12> Chat.print_actual
"PosID: 1716050462541_nerves - Message: Mesage 1"
"PosID: 1716050477581_Node2 - Message: Message 2"
"PosID: 1716050546981_nerves - Message: Mesage 3"
"PosID: 1716050554206_Node2 - Message: Message 4"
"PosID: 1716051394679_Node2 - Message: Message 6"
:ok
``` 

As you can see in the node number two the message "Messsage 2" is active

### Step 7 - Reconnection of node an auto update of CRDTs

In this point we are going to connect the nodes to each other and the system automatically has to update the messages even the messages were delete and show it in the same order

**Node 2**

``` elixir
iex(Node2@192.168.0.6)13> Node.connect :"nerves@192.168.0.6"
true
iex(Node2@192.168.0.6)14> Node.list
[:"nerves@192.168.0.6"]
```

Now that we have connected both nodes, we next need to confirm that the CRDTs are consistent.
For this first we have to print all message and then the message there were not deleted

**Node 2**

``` elixir
iex(Node2@192.168.0.6)16> Chat.print_all_messages
"PosID: 1716050462541_nerves - Message: Mesage 1"
"PosID: 1716050477581_Node2 - Message: Message 2"
"PosID: 1716050546981_nerves - Message: Mesage 3"
"PosID: 1716050554206_Node2 - Message: Message 4"
"PosID: 1716051382961_nerves - Message: Message 5"
"PosID: 1716051394679_Node2 - Message: Message 6"
```

**Node 1**

``` elixir
iex(nerves@192.168.0.6)21> Chat.print_all_messages
"PosID: 1716050462541_nerves - Message: Mesage 1"
"PosID: 1716050477581_Node2 - Message: Message 2"
"PosID: 1716050546981_nerves - Message: Mesage 3"
"PosID: 1716050554206_Node2 - Message: Message 4"
"PosID: 1716051382961_nerves - Message: Message 5"
"PosID: 1716051394679_Node2 - Message: Message 6"
```

We this we confirm both CRDTs has de same message.

The next part is to verify that the deleted messages are the same.

**Node 1**

``` elixir
iex(nerves@192.168.0.6)23> Chat.print_actual
"PosID: 1716050462541_nerves - Message: Mesage 1"
"PosID: 1716050546981_nerves - Message: Mesage 3"
"PosID: 1716050554206_Node2 - Message: Message 4"
"PosID: 1716051382961_nerves - Message: Message 5"
"PosID: 1716051394679_Node2 - Message: Message 6"
```

**Node 2**

``` elixir
iex(Node2@192.168.0.6)17> Chat.print_actual
"PosID: 1716050462541_nerves - Message: Mesage 1"
"PosID: 1716050546981_nerves - Message: Mesage 3"
"PosID: 1716050554206_Node2 - Message: Message 4"
"PosID: 1716051382961_nerves - Message: Message 5"
"PosID: 1716051394679_Node2 - Message: Message 6"
```
 ### Conclusion

 With this example we can conclude that we can make use of a CRDT on different nodes and eventually make it consistent when the nodes are connected, or make it completely consistent while the connection remains active.

## How to use it?
Init the application if you don't know how to make it please check [Getting Started](#Getting-Started)
each user can use the Chat module to get accest to general interfaces

### Insert a new message
There are four ways to insert a message
``` elixir
# RECOMMENDED WAY TO INSERT MANUAL MESSAGES
# Way one to insert a message
# Insert a new message, only write the message
# The system is going to set a pos_id automatically
iex> Chat.insert("new message")

# RECOMMENDED WAY TO INSERT MANUAL MESSAGES
# Way one to insert a message
# Insert a new message, only write the message
# The system is going to set a pos_id automatically
# Throught the function new_message
iex> message_tuple = Chat.new_message("Your message")
iex> Chat.insert(message_tuple)
{:ok, "1716044539486_nerves"}

# NO RECOMMENDED
# Way three to insert a message
# Set the post id and message, each one is a parameter
# This way is not recommended because the pos_id loses its order in the chat room
iex> pos_id = 1
iex> message = "New message"
iex> Chat.insert(pos_id, message)
{:ok, "1_nerves"}

# NO RECOMMENDED
# Way four to insert a message
# Set the post id and message into a tuple
# This way is not recommended because the pos_id loses its order in the chat room
iex> pos_id = 2
iex> message = "New message"
iex> Chat.insert({pos_id, message})
{:ok, "1_nerves"}

# IF THE POS_ID EXIST 
# If the pos_id exist the system it will not allow to insert your message
iex> pos_id = 2
iex> message = "existing message"
iex> Chat.insert({pos_id, message})
{:it_already_exists, "1716044543349_nerves"}
```

### print_all_messages
This function is going to show all Crdt messages

``` elixir
# This method is going to print all messages save including the deleted message
iex> Chat.print_all_messages()
"PosID: 1716041933514_nerves - Message: message 1"
"PosID: 1716041935900_nerves - Message: message 2"
"PosID: 1716041939074_nerves - Message: message 3"
"PosID: 1716041952213_nerves2 - Message: message 4"
"PosID: 1716041961015_nerves - Message: message 5"
```

### delete(pos_id)
To delete a message you have to know previously the pos_id you can look at printing the message in the CRDT

``` elixir
# If exist the pos_id
iex> Chat.delete "1716046456275_nerves"
{:ok, "1716046456275_nerves"}

# If do not exist
iex> Chat.delete "1716046456275_not_exist"
{:not_exists, "1716046456275_not_exist"}
```

### print_actual()
This is going to print only the message there were not deleted

``` elixir
# Before to print I will show you the status of message
iex> IO.inspect Crdt.TreeDoc.get_tree_doc
%{
  "1716046021586_nerves" => {:active, "Eder"},
  "1716046454391_nerves" => {:active, "message 2"},
  "1716046456275_nerves" => {:delete, "message 3"},
  "1716046464589_nerves2" => {:active, "message 4"},
  "1716046467418_nerves2" => {:active, "message 5"}
}

# As you can see the message "message 3" is deleted then it should not be present when we print the actual message
iex> Chat.print_actual
"PosID: 1716046021586_nerves - Message: Eder"
"PosID: 1716046454391_nerves - Message: message 2"
"PosID: 1716046464589_nerves2 - Message: message 4"
"PosID: 1716046467418_nerves2 - Message: message 5"
```


## Targets

Nerves applications produce images for hardware targets based on the
`MIX_TARGET` environment variable. If `MIX_TARGET` is unset, `mix` builds an
image that runs on the host (e.g., your laptop). This is useful for executing
logic tests, running utilities, and debugging. Other targets are represented by
a short name like `rpi4` that maps to a Nerves system image for that platform.
All of this logic is in the generated `mix.exs` and may be customized. For more
information about targets see:

https://hexdocs.pm/nerves/supported-targets.html

## Getting Started

### Local node or node into the personal computer

To start your Nerves app:
  * Go to the folder root of the repository with the implementation
  * `export NODE_NAME=your_node_name` if you don't set the name by default is nerves
  * `export REFERENCE_NODE=reference_node` This is helpful if you want the node automatically connect to other one that should be active, example: `export REFERENCE_NODE="nodeX@172.10.10.1"`
  
   If you don't set this value by default it will try with `:"nerves@192.168.0.6"` It is possible that this node does not exist on your network.
  * Compile your app in your local promp, remember you have to be in the root of your project and execute the following sentences. `mix clean` then, `mix deps.get` 
  * Start the app, execute `mix deps.get` with this you will be ready

### Raspberry pi node configuration


To start your Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi4`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix burn`
  * Insert the SD card to your raspberry pi
  * Connect to electric power
  * Then you can connect it using a monitor and keyboard or through a ssh connection

**Note**
In the raspberry pi the name of node is the name of the raspberry pi, the node configuration is automatically and when you tour on you raspberry pi it will setup the node

### Node interconnection

To connect to other nodes use `Node.connect your_target_node` example `Node.connect :"Node2@192.168.0.6"`

If you stop your node and you want to start it again then we have two ways to perform it

**REALY IMPORTANT**
You have to set the same cookie for all the nodes you want to be contributors.
`Node.set_cookie(:your_atom_cookie)`

**Way one**

Execute `Cluster.NodeCluster.setup_node()` this help you setting the node

**Way two**

Execute manually 
``` elixir
iex> System.cmd("epmd", ["-daemon"])
# The node name has the name and has the dns or your ip connection, replace de values :"your_node_name@your_ip"
iex> node_name = :"nerves@192.168.0.1" 
iex> Node.start(node_name)
# The cookie has to be the same for all nodes that you want to bellow at the CRDT Network
iex> cookie = :cookie
iex> Node.set_cookie(cookie)

```

## Learn more

  * Official docs: https://hexdocs.pm/nerves/getting-started.html
  * Official website: https://nerves-project.org/
  * Forum: https://elixirforum.com/c/nerves-forum
  * Elixir Slack #nerves channel: https://elixir-slack.community/
  * Elixir Discord #nerves channel: https://discord.gg/elixir
  * Source: https://github.com/nerves-project/nerves
