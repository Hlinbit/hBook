# Common Commands 

How to obtain the local network IP?

```
ifconfig | grep -E 'inet\b'
```

How to Check Port Occupancy？

```
lsof -i:<port>
```
or display all specific using ports.
```
netstat -tunlp
    -t: Show only TCP-related options. 
    -u: Show only UDP-related options.
    -n: Refuse to display aliases and display all numbers as numeric form. 
    -l: List only services in the Listen state (excluding other states, not including ports in the Listen state!!!). 
    -p: Display the program name associated with the established connections. 
```

How to test the network speed?

`iperf` can establish the connection between two hosts and report the network speed in specific format.
``` bash
# server
iperf -s -i 1 -f  m
```

``` bash
# client
# '-i' means interval of 1 second between each report.
# '-t' means the test duration.
# -f m flag specifies that the output should be displayed in megabits per second (Mbps) format.
iperf -c <server_ip> -i 1 -t 30 -f m
```

# Limit the network speed

The first step is:
```
tc qdisc del dev lo root
```
The purpose of this command is to delete the configured root queuing discipline on the `lo` interface.

`tc` is the short for `Traffic Control`, a linux command.
`qdisc` is the short for `Queueing Discipline`.
`del` is the instruction to be executed.
`dev lo` specifies the network interface for deleting the queuing discipline. You can modify the network interface according to you own host and requirements.

The second step is:

```
tc qdisc add dev lo root handle 1:0 htb default 1 
```
The command is used to configure a hierarchical token bucket (HTB) queuing discipline on the `lo` interface with a specific rule configuration.

`root`: Specifies that the queuing discipline is the root (top-level) of the hierarchy.

`handle 1:0:` Assigns a unique identifier (handle) to the queuing discipline, in this case, 1:0.

`htb`: Specifies the queuing discipline type as hierarchical token bucket (HTB).

`default 1`: Sets the default class to 1 for packets that do not match any other rules.

The third step is:

```
tc class add dev lo parent 1:0 classid 1:1 htb rate 10000Mbit
```

The command is used to add a class with a specified rate to the hierarchical token bucket (HTB) queuing discipline on the `lo` interface. 

`parent 1:0`: Specifies the parent class under which this new class will be added. 1:0 refers to the handle of the parent class.

`classid 1:1`: Assigns a unique identifier (classid) to the new class, in this case, 1:1.

`htb`: Specifies the queuing discipline type as hierarchical token bucket (HTB).

`rate 10000Mbit`: Sets the rate (bandwidth) limit for the class to 10000 Mbps (megabits per second).

The fourth step is:

```
tc class add dev lo parent 1:1 classid 1:10 htb rate 100Mbit ceil 100Mbit
```

The command is used to add a child class with rate and ceiling rate limits to an existing parent class within the hierarchical token bucket (HTB) queuing discipline on the `lo` interface.

`parent 1:1`: Specifies the parent class under which this new class will be added. 1:1 refers to the handle of the parent class.

`classid 1:10`: Assigns a unique identifier (classid) to the new class, in this case, 1:10.

`htb`: Specifies the queuing discipline type as hierarchical token bucket (HTB).

`rate 100Mbit`: Sets the rate (bandwidth) limit for the class to 100 Mbps (megabits per second).

`ceil 100Mbit`: Sets the ceiling rate (maximum burst rate) for the class to 100 Mbps.

The fifth step is:

```
tc qdisc add dev lo parent 1:10 handle 10: sfq perturb 10 
```

The command is used to add a Stochastic Fairness Queueing (SFQ) queuing discipline to the child class within the hierarchical token bucket (HTB) queuing discipline on the `lo` interface. In order to prevent one session from occupying the bandwidth indefinitely, add a Stochastic Fairness Queueing (SFQ) queue.

`parent 1:10`: Specifies the parent class under which this new queuing discipline will be added. `1:10` refers to the handle of the parent class.

`handle 10:`: Assigns a unique identifier (handle) to the queuing discipline, in this case, `10:`.

`sfq`: Specifies the queuing discipline type as Stochastic Fairness Queueing (SFQ).

`perturb 10`: Sets the perturbation value to 10, which determines the interleaving of packets in the queue to enhance fairness.

The sixth step is:


```
tc filter add dev lo parent 1:0 protocol ip prio 1 handle 10 fw classid 1:10
```

`parent 1:0`: Specifies the parent class to which this filter rule will be added. 1:0 refers to the handle of the parent class.

`protocol ip`: Specifies that the filter rule is applied to IP packets.
prio 1: Sets the priority of the filter rule to 1. Lower values indicate higher priority.

`handle 10`: Assigns a unique identifier (handle) to the filter rule, in this case, 10.

`fw`: Indicates that the filter rule uses firewall classification.

`classid 1:10`: Specifies the classid of the child class to which the matching packets will be directed. In this case, it is 1:10.


```
iptables -A OUTPUT -t mangle -p tcp --sport 46320 -j MARK --set-mark 10
```

The command is used to add a rule to the OUTPUT chain of the mangle table in the iptables firewall configuration.

This command adds a rule to the OUTPUT chain of the mangle table. It matches TCP packets originating from the source port number 46320 and performs the action of setting the packet mark to 10 using the MARK target.

`iptables`: The command-line tool for configuring firewall rules in Linux.

`-A OUTPUT`: Specifies that the rule is added to the OUTPUT chain.

`-t mangle`: Specifies that the rule is added to the mangle table, which is used for specialized packet alteration.

`-p tcp`: Matches packets with the TCP protocol.

`--sport 46320`: Matches packets originating from the source port number 46320.

`-j MARK`: Specifies the action to be taken if the packet matches the conditions. In this case, it is MARK.

`--set-mark 10`: Sets the packet mark value to 10.
