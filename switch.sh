#!/bin/bash

#monitor=dev:/dev/i2c-1
#output=3
devices=(046d:c07d 046d:c339)
vmname=$(virsh list | sed -n '3p' | sed -nr 's/ *[0-9]+ +(.*) +running/\1/p')

if [ -z ${vmname} ]; then
	echo "no running vm found '${vmname}'. exiting..."
	exit 1
fi

attachDetach() {
  vmname=$1
  device=(${2//:/ })
  action=$3
  tmpXMLFile=$(mktemp --suffix=sks)

  echo "" > ${tmpXMLFile}
  echo "<hostdev mode='subsystem' type='usb'>"     >> ${tmpXMLFile}
  echo "  <source>"                                >> ${tmpXMLFile}
  echo "          <vendor id='0x${device[0]}'/>"   >> ${tmpXMLFile}
  echo "          <product id='0x${device[1]}'/>"  >> ${tmpXMLFile}
  echo "  </source>"                               >> ${tmpXMLFile}
  echo "</hostdev>"                                >> ${tmpXMLFile}
  virsh $action-device ${vmname} ${tmpXMLFile}

}

if [ "$1" == "attach" ]; then
  for dev in "${devices[@]}"; do
    attachDetach "${vmname}" $dev attach
  done
  #ddccontrol -r 0x60 -w $output $monitor
  #ddcutil -r 0x60 -w $output $monitor
else
  for dev in "${devices[@]}"; do
    attachDetach "${vmname}" $dev detach
  done
fi
