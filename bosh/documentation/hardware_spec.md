# Harware requirement for Cloud Foundry Installation #

In this section we list the recommended hardware requirement for installing BOSH and Cloud Foundry.

## Hardware Components ##

+    Physical servers to install ESXi and vCenter
+    Storage servers
+    L3 switch to create a Private network
+    Firewall for Routing and Security

## Physical servers ##

The hardware requirement depends on the size of the RAM and CPUs allocated for each of the VMs. values below are only indicative.

### ESXi host servers : Server 1 and 2 ###

Note : configuration is for each of the machines

##### Min spec

+    4 CPUs: Intel Xeon E5620 @ 2.40 GHz, 2 cores per CPU
+    Atleast 4 NIC cards
+    60 GB RAM

##### Recommended Spec

+     8 CPUs Intel Xeon E5620 @ 2.40 GHz, 2 cores per CPU
+     Atleast 4 NIC cards or Dual HBA Cards for Fiber Channel per Host
+     80 GB RAM running in Tri-Channel Memory Support (Multiples of 6)

Server Brand : vSphere 5.0 compliant please refer to VMware certified hardware list.

### vCenter Server ###

This could run Windows natively or on top of a ESXi host in a VM.

##### Min Spec
+   1 CPUs Intel Xeon E5620, 4 cores per CPU
+   8 GB RAM
+   256 GB hard disk

Server Brand : vSphere 5.0 compliant

##### Recommeded Spec
+   2 CPUs Intel Xeon E5620, 4 cores per CPU
+   8 GB RAM
+   2 x 256 GB hard disk

### Storage ###

Min 1 TB of Network storage - this could be SAN based storage or EMC VNX based storage.
Ethernet of Fiber Channel, Should support Jumbo Frames

### Switch ###

##### Min Spec
+   L2 switch with 24 ports.

##### Recommended Spec

+   L3 switch with 48 ports and 100 GB RAM
+   12 CPUs Intel Xeon E5649 @ 2.53 GHz
+   Brand : Cisco or Dell
