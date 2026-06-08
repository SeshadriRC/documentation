- Suppose we create a PVC requesting **1 GB** of storage, and there is a PV available with **2 GB** capacity. The PVC will successfully bind to that PV because the PV capacity is greater than the requested size.

- Suppose we create a PVC requesting **1 GB** of storage, but the available PV has only **500 MB** capacity. In this case, the PVC will remain in the **Pending** state and will not bind to the PV because the PV does not meet the requested storage requirement.
