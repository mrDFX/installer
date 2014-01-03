#!/bin/bash
cd /tmp
# LOGICAL DISKS
if [[ "$1" == "logical" ]]; then
        optimal=0
	failed=0
	for logical in `sudo /opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -LALL -aALL -nolog | grep "State"|awk '{print $3}'`;do
		if [[ "$logical" == "Optimal" ]]; then
			let optimal=$optimal+1	 
		fi
		
		if [[ "$logical" != "Optimal" ]]; then
                        let failed=$failed+1
                fi
	done
	
	# slygods.perc.logical.normal
	if [[ "$2" == "normal" ]]; then
		echo $optimal
	fi
	
	# slygods.perc.logical.fail
	if [[ "$2" == "fail" ]]; then
		echo $failed
	fi
	
	exit 0
fi

# PHYSICAL DISKS
if [[ "$1" == "physical" ]]; then
        optimal=0
        failed=0
        for physical in `sudo /opt/MegaRAID/MegaCli/MegaCli64 -PDList -aALL -nolog | grep "Firmware state"|awk '{print $3}'|sed 's/,//g'`;do
                if [[ "$physical" == "Online" ]]; then
                        let optimal=$optimal+1
                fi

                if [[ "$physical" != "Online" ]]; then
                        let failed=$failed+1
                fi
        done

        # slygods.perc.physical.normal
        if [[ "$2" == "normal" ]]; then
                echo $optimal
        fi

        # slygods.perc.physical.fail
        if [[ "$2" == "fail" ]]; then
                echo $failed
        fi

        exit 0
fi


