
# Same things as ip v4. Here we juste block everything 
ip6tables -N FILTERS
ip6tables -F INPUT
ip6tables -F DOCKER-USER
ip6tables -F FILTERS
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -j FILTERS
ip6tables -A DOCKER-USER -i <public interface> -j FILTERS

ip6tables -A FILTERS -j DROP

# Flush some specifics rules. Not all of them or it might break some docker rules needed for forwarding or things like that
iptables -N FILTERS
iptables -F INPUT
iptables -F DOCKER-USER
iptables -F FILTERS

# Generic things
iptables -A INPUT -i lo -j ACCEPT

# Redirects anythings to the filter rules
iptables -A INPUT -j FILTERS
iptables -A DOCKER-USER -i <public interface> -j FILTERS

# Allow some IP or a an IP and a specific port
iptables -A FILTERS -s <ip> -j ACCEPT
iptables -A FILTERS -p tcp -s <ip> --dport 3306 -j ACCEPT

# Juste drop a few invalid things
iptables -A FILTERS -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FILTERS -m state --state INVALID -j DROP

# Allow some specific providers
for IP in $(curl -q https://www.cloudflare.com/ips-v4); do
        iptables -A FILTERS -s $IP -p tcp --dport 8443 -j ACCEPT
done

# Some other providers
for IP in $(curl -q https://tcpshield.com/v4/); do
        iptables -I FILTERS -s $IP -m tcp -p tcp --dport 25565 -j ACCEPT
done

# Range of port
iptables -I FILTERS -s <ip> -m tcp -p tcp --dport 25600:25690 -j ACCEPT

iptables -A FILTERS -j DROP
