#!/bin/bash

# shows a graph of all user's CPU use on circe as a function of time
# collects data from yell_log.log which is written by my yell alias
# in ~/.bashrc

xmgstr=""

#mode="spacecadets"
mode="all"

if [[ "$mode" == "spacecadets" ]]; then
    user_str="#########DFRANZ  adamhogan btudor tpham4 kaforres zdyott scc karl6 zofiamarie ssuepaul"
elif [[ "$mode" == "all" ]]; then
    user_str="#########DFRANZ  braenne makbenjamind ozsel zofiamarie nclough shuangming arabia sna codyjohnson zfthenakis samuelm jiez pekoz ssuepaul asiddiqui dmaiti tpham4 lindarose blakemichael yashkin mwilliamson2 pablos rshoy hongnguyen ningma nalvi gmgray2 uluturki leonhardy kaforres hparikh rch zdyott scc karl6 adamhogan"
fi


echo "user         isthere       cpus";
echo ""
for user in $user_str; do

    rm $user;
    cpus=$(cat yell_log.log | grep "$user" | awk {'print $2'}) 

    isthere=$(echo $cpus | grep -c "") # doesnt work rn but whatev
    echo $user" "$isthere" "$cpus

    if [[ "$isthere" -eq "0" ]]; then
        echo "0" >> $user;
    else
        for x in $cpus; do echo $x >> $user; done 
    fi
    echo "" >> $user
    xmgstr=$xmgstr" "$user


done

if [[ "$mode" == "spacecadets" ]]; then
xmgrace  $xmgstr
elif [[ "$mode" == "all" ]]; then
xmgrace -par all_users.par $xmgstr
fi



