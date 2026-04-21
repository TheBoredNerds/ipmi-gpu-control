# ipmi-gpu-control
This is a simple script for adjusting fan speeds with ipmi in a proxomox host based on the temperature of a GPU in PCI-pass through to a VM. 

Use Case: Using a deshrouded consumer graphics card (RTX3060) in a Dell PowerEdge r720. The fans in most consumer graphics cards will "compete" with the case fans of a rack server which will disrupt the airflow design of the case and trap hot air rather than reject it. The solution is to remove the shroud and fans of the card and let the server manage the heat. However, when the GPU is passed through to a virtual machine, the host cannot read the temperature of the GPU anymore. 

This script pings the VM for the GPU temperature, reports it to the host, adjusts the fans accordingly via IPMI, and then writes the temperature and fan speed to a log.

Depending on your loads, you may want to change the behavior of your fans further. My core loads are fairly low, but the GPU can get quite hot. My GPU is on Riser 3 directly behind CPU 1. This script ramps up fan 2 while keeping the rest at ilde (20%).

