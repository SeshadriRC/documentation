1.  EC2 instance and its use cases 

For interview short answers, you can say:

| EC2 Instance Type                            | Use Case                                                             |
| -------------------------------------------- | -------------------------------------------------------------------- |
| **General Purpose (T series, M series)**     | Balanced CPU + Memory → web servers, small apps, development         |
| **Compute Optimized (C series)**             | High CPU workloads → batch jobs, gaming servers, application servers |
| **Memory Optimized (R series, X series)**    | Large RAM → databases, Redis, SAP, analytics                         |
| **Storage Optimized (I series, D series)**   | High disk I/O → big data, data warehousing, NoSQL                    |
| **Accelerated Computing (P, G, Inf series)** | GPU / AI / ML / video processing                                     |

Quick examples:

* t3.micro → Small testing, low-cost servers
* m5.large → General application hosting
* c5.large → CPU intensive apps
* r5.large → Database workloads
* i3.large → Fast storage workloads
* p3.2xlarge → AI / ML training

Interview one-liner:

> **T → Burstable, M → Balanced, C → CPU intensive, R → Memory intensive, I → Storage intensive, P/G → GPU workloads**
---

2. S3 storage classes

Ah, you mean **S3 storage classes** (not bucket types). For interviews, this is the expected answer.

| S3 Storage Class                                          | Use Case                                                                                   |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| **Standard**                                              | Frequently accessed data → websites, applications, active files                            |
| **Standard-IA (Infrequent Access)**                       | Accessed less often but should be available immediately → backups, DR                      |
| **One Zone-IA**                                           | Infrequent access stored in one AZ → non-critical backups                                  |
| **Intelligent-Tiering**                                   | AWS automatically moves data between tiers based on access → unpredictable access patterns |
| **Glacier Instant Retrieval**                             | Rare access but milliseconds retrieval → medical images, archives                          |
| **Glacier Flexible Retrieval**                            | Archive storage with retrieval in minutes/hours → backup archives                          |
| **Glacier Deep Archive**                                  | Cheapest storage, retrieval in hours → long-term retention, compliance                     |
| **Reduced Redundancy (RRS)** *(legacy / not recommended)* | Earlier low-cost option, mostly replaced                                                   |

Interview one-liner:

> **Standard → frequent access, IA → less frequent, Intelligent Tiering → auto optimize, Glacier → archival, Deep Archive → lowest cost long-term storage.**

Simple memory trick:

```text
Hot data      → Standard
Warm data     → Standard-IA
Unknown usage → Intelligent-Tiering
Cold data     → Glacier
Very cold     → Deep Archive
```

---

3. What is Transit Gateway 

**Transit Gateway (TGW)** in AWS is a **central hub to connect multiple VPCs and on-premises networks together**.

Without Transit Gateway:

```text
VPC1 ↔ VPC2
VPC1 ↔ VPC3
VPC2 ↔ VPC3
```

Many peering connections → difficult to manage.

With Transit Gateway:

```text
         Transit Gateway
          /    |    \
       VPC1  VPC2  VPC3
             |
         On-Prem
```

### Use cases:

* Connect **multiple VPCs**
* Connect **AWS ↔ On-Prem** using VPN / Direct Connect
* Centralized network management
* Hub-and-spoke architecture

Interview one-liner:

> **Transit Gateway acts like a network router that centrally connects multiple VPCs and on-premises networks without creating many VPC peering connections.**

---

4. NACL and SG

[refer](https://github.com/SeshadriRC/Devops-Learnings/blob/main/My-Learnings/Networking/Security-Group-and-NACL.md)


---
